#!/usr/bin/env node

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawn } = require("child_process");

const ROOT_DIR = path.resolve(__dirname, "..");
const BUILD_SCRIPT = path.join(ROOT_DIR, "tools", "build_web_native_emcc.sh");
const SITE_SCRIPT = path.join(ROOT_DIR, "tools", "prepare_web_games_site.sh");
const SPECIAL_RULES_PATH = path.join(ROOT_DIR, "tools", "web_games.special.js");

const DEFAULT_OUT_ROOT = path.join(ROOT_DIR, "_build", "web");
const DEFAULT_SITE_OUT = path.join(ROOT_DIR, "_build", "web_pages_site");

function usage() {
  const text = `Usage:
  tools/build_web_games.sh [options] [filter_regex]

Options:
  -j, --jobs N           Parallel build jobs (default: CPU count)
  -f, --filter REGEX     Build games whose package name matches regex
      --game NAME        Add a single game package to build (repeatable)
      --games CSV        Add multiple game packages (comma-separated)
      --out-root DIR     Output root for emcc bundles (default: _build/web)
      --site-out DIR     Output directory for generated homepage site
                         (default: _build/web_pages_site)
      --no-site          Skip homepage/site generation step
      --strict           Exit non-zero if any selected game fails to build
      --list             Print selected games and exit
  -h, --help             Show this help

Behavior:
  - Build failures are skipped by default so other games continue building.
  - A failure report is written to <out-root>/BUILD_FAILURES.md.
  - Use --strict if you want CI-style hard failure on any build error.

Examples:
  tools/build_web_games.sh --jobs 8
  tools/build_web_games.sh --filter 'tank|fighter'
  tools/build_web_games.sh --games raylib_tank_1990,raylib_fighter_97_lite -j 2`;
  console.log(text);
}

function fail(message) {
  console.error(`error: ${message}`);
  process.exit(1);
}

function parseArgs(argv) {
  const opts = {
    jobs: Math.max(1, os.cpus().length || 1),
    filter: "",
    requestedGames: [],
    outRoot: DEFAULT_OUT_ROOT,
    siteOut: DEFAULT_SITE_OUT,
    noSite: false,
    strict: false,
    listOnly: false,
  };

  const args = [...argv];
  while (args.length > 0) {
    const arg = args.shift();

    if (arg === "-h" || arg === "--help") {
      usage();
      process.exit(0);
    }

    if (arg === "-j" || arg === "--jobs") {
      if (args.length === 0) fail("--jobs requires a value");
      const n = Number(args.shift());
      if (!Number.isInteger(n) || n <= 0) fail(`--jobs must be a positive integer, got: ${n}`);
      opts.jobs = n;
      continue;
    }

    if (arg === "-f" || arg === "--filter") {
      if (args.length === 0) fail("--filter requires a value");
      opts.filter = args.shift();
      continue;
    }

    if (arg === "--game") {
      if (args.length === 0) fail("--game requires a value");
      opts.requestedGames.push(args.shift());
      continue;
    }

    if (arg === "--games") {
      if (args.length === 0) fail("--games requires a value");
      const csv = args.shift();
      for (const name of csv.split(",")) {
        const trimmed = name.trim();
        if (trimmed.length > 0) opts.requestedGames.push(trimmed);
      }
      continue;
    }

    if (arg === "--out-root") {
      if (args.length === 0) fail("--out-root requires a value");
      opts.outRoot = path.resolve(ROOT_DIR, args.shift());
      continue;
    }

    if (arg === "--site-out") {
      if (args.length === 0) fail("--site-out requires a value");
      opts.siteOut = path.resolve(ROOT_DIR, args.shift());
      continue;
    }

    if (arg === "--no-site") {
      opts.noSite = true;
      continue;
    }

    if (arg === "--strict") {
      opts.strict = true;
      continue;
    }

    if (arg === "--list") {
      opts.listOnly = true;
      continue;
    }

    if (arg.startsWith("-")) {
      fail(`unknown option: ${arg}`);
    }

    if (opts.filter.length > 0) {
      fail(`multiple positional filters provided: '${opts.filter}' and '${arg}'`);
    }
    opts.filter = arg;
  }

  return opts;
}

function discoverGames() {
  const entries = fs.readdirSync(ROOT_DIR, { withFileTypes: true });
  const games = [];
  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    if (!entry.name.startsWith("raylib_")) continue;
    const gameDir = path.join(ROOT_DIR, entry.name);
    if (fs.existsSync(path.join(gameDir, "moon.pkg")) && fs.existsSync(path.join(gameDir, "main.mbt"))) {
      games.push(entry.name);
    }
  }
  games.sort();
  return games;
}

function loadSpecialRules() {
  if (!fs.existsSync(SPECIAL_RULES_PATH)) {
    return { games: {}, resolveGame: undefined };
  }

  try {
    delete require.cache[require.resolve(SPECIAL_RULES_PATH)];
    const mod = require(SPECIAL_RULES_PATH);
    if (!mod || typeof mod !== "object") {
      fail(`special rules must export an object: ${SPECIAL_RULES_PATH}`);
    }
    if (mod.games && typeof mod.games !== "object") {
      fail(`special rules 'games' must be an object: ${SPECIAL_RULES_PATH}`);
    }
    if (mod.resolveGame && typeof mod.resolveGame !== "function") {
      fail(`special rules 'resolveGame' must be a function: ${SPECIAL_RULES_PATH}`);
    }
    return {
      games: mod.games || {},
      resolveGame: mod.resolveGame,
    };
  } catch (err) {
    fail(`failed to load ${SPECIAL_RULES_PATH}: ${err.message}`);
  }
}

function buildPlans(selectedGames, outRoot, specialRules) {
  const plans = [];
  const skippedByRules = [];

  for (const game of selectedGames) {
    let plan = {
      game,
      pkgPath: game,
      outDir: path.join(outRoot, game),
      extraArgs: [],
      skip: false,
      skipReason: "",
    };

    const override = specialRules.games[game];
    if (override && typeof override === "object") {
      if (override.skip === true) {
        plan.skip = true;
        if (typeof override.reason === "string" && override.reason.length > 0) {
          plan.skipReason = override.reason;
        }
      }
      if (typeof override.pkgPath === "string" && override.pkgPath.length > 0) {
        plan.pkgPath = override.pkgPath;
      }
      if (typeof override.outDirName === "string" && override.outDirName.length > 0) {
        plan.outDir = path.join(outRoot, override.outDirName);
      }
      if (typeof override.outDir === "string" && override.outDir.length > 0) {
        plan.outDir = path.isAbsolute(override.outDir)
          ? override.outDir
          : path.resolve(ROOT_DIR, override.outDir);
      }
      if (Array.isArray(override.extraArgs)) {
        plan.extraArgs = override.extraArgs.map(String);
      }
      if (typeof override.skipReason === "string" && override.skipReason.length > 0) {
        plan.skipReason = override.skipReason;
      }
    }

    if (typeof specialRules.resolveGame === "function") {
      const resolved = specialRules.resolveGame(game, { ...plan });
      if (resolved && typeof resolved === "object") {
        plan = {
          ...plan,
          ...resolved,
          game,
          extraArgs: Array.isArray(resolved.extraArgs)
            ? resolved.extraArgs.map(String)
            : plan.extraArgs,
        };
      }
    }

    if (plan.skip) {
      skippedByRules.push({
        game: plan.game,
        reason: plan.skipReason || "special rule",
      });
      continue;
    }

    plans.push(plan);
  }

  return { plans, skippedByRules };
}

function spawnCommand(command, args, label) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: ROOT_DIR,
      stdio: "inherit",
    });

    child.on("error", (err) => {
      reject(new Error(`${label}: ${err.message}`));
    });

    child.on("close", (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`${label} failed with exit code ${code}`));
      }
    });
  });
}

async function runBuilds(plans, jobs) {
  const successes = [];
  const failures = [];
  let nextIndex = 0;

  async function worker() {
    while (nextIndex < plans.length) {
      const index = nextIndex;
      nextIndex += 1;
      const plan = plans[index];

      console.log(`[${index + 1}/${plans.length}] build ${plan.game}`);

      fs.rmSync(plan.outDir, { recursive: true, force: true });

      const args = [plan.pkgPath, plan.outDir, ...plan.extraArgs];
      try {
        await spawnCommand(BUILD_SCRIPT, args, `build ${plan.game}`);
        successes.push(plan);
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : String(err);
        failures.push({ game: plan.game, error: errorMessage });
        console.error(`[skip] ${plan.game}: ${errorMessage}`);
      }
    }
  }

  const workerCount = Math.min(jobs, plans.length);
  const workers = [];
  for (let i = 0; i < workerCount; i += 1) {
    workers.push(worker());
  }
  await Promise.all(workers);

  successes.sort((a, b) => a.game.localeCompare(b.game));
  failures.sort((a, b) => a.game.localeCompare(b.game));

  return { successes, failures };
}

function uniqueGames(list) {
  return Array.from(new Set(list));
}

function writeFailureReport(reportPath, skippedByRules, failures) {
  if (skippedByRules.length === 0 && failures.length === 0) {
    fs.rmSync(reportPath, { force: true });
    return;
  }

  const lines = [];
  lines.push("# Web Build Skips and Failures");
  lines.push("");
  lines.push(`Generated: ${new Date().toISOString()}`);
  lines.push("");

  if (skippedByRules.length > 0) {
    lines.push("## Skipped By Special Rules");
    lines.push("");
    for (const item of skippedByRules) {
      lines.push(`- FIXME(${item.game}): ${item.reason}`);
    }
    lines.push("");
  }

  if (failures.length > 0) {
    lines.push("## Failed During Build (Auto-Skipped)");
    lines.push("");
    lines.push("These packages failed in this run and were omitted from the generated site.");
    lines.push("");
    for (const item of failures) {
      lines.push(`- FIXME(${item.game}): ${item.error}`);
    }
    lines.push("");
  }

  lines.push("## Next Step");
  lines.push("");
  lines.push("If a package is expected to stay unsupported on web, add `skip: true` in `tools/web_games.special.js`.");
  lines.push("");

  fs.mkdirSync(path.dirname(reportPath), { recursive: true });
  fs.writeFileSync(reportPath, `${lines.join("\n")}\n`, "utf8");
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));

  if (!fs.existsSync(BUILD_SCRIPT)) fail(`missing build script: ${BUILD_SCRIPT}`);
  if (!fs.existsSync(SITE_SCRIPT)) fail(`missing site script: ${SITE_SCRIPT}`);

  const discovered = discoverGames();
  if (discovered.length === 0) {
    fail("no buildable raylib game packages found in repo root");
  }

  const discoveredSet = new Set(discovered);

  let selected = discovered;
  if (opts.requestedGames.length > 0) {
    selected = [];
    for (const game of uniqueGames(opts.requestedGames)) {
      if (!discoveredSet.has(game)) {
        fail(`unknown or non-buildable game package: ${game}`);
      }
      selected.push(game);
    }
  }

  if (opts.filter.length > 0) {
    let regex;
    try {
      regex = new RegExp(opts.filter);
    } catch (err) {
      fail(`invalid regex for --filter: ${err.message}`);
    }
    selected = selected.filter((game) => regex.test(game));
  }

  if (selected.length === 0) {
    fail("no games selected after applying filters");
  }

  selected.sort();

  const specialRules = loadSpecialRules();
  const { plans, skippedByRules } = buildPlans(selected, opts.outRoot, specialRules);

  if (opts.listOnly) {
    for (const plan of plans) {
      console.log(plan.game);
    }
    return;
  }

  if (plans.length === 0) {
    fail("all selected games are skipped by special rules");
  }

  fs.mkdirSync(opts.outRoot, { recursive: true });

  console.log(`Selected ${plans.length} game(s). Parallel jobs: ${opts.jobs}`);
  console.log(`Web output root: ${opts.outRoot}`);
  if (!opts.noSite) {
    console.log(`Site output: ${opts.siteOut}`);
  }
  if (skippedByRules.length > 0) {
    console.log(`[skip] ${skippedByRules.length} game(s) skipped by special rules.`);
  }

  const { successes, failures } = await runBuilds(plans, opts.jobs);

  const failureReportPath = path.join(opts.outRoot, "BUILD_FAILURES.md");
  writeFailureReport(failureReportPath, skippedByRules, failures);

  console.log(`Built ${successes.length}/${plans.length} web bundle(s).`);

  if (failures.length > 0 || skippedByRules.length > 0) {
    console.log(`Failure/skip report: ${failureReportPath}`);
  }

  if (successes.length === 0) {
    fail("all selected games failed to build or were skipped");
  }

  if (!opts.noSite) {
    await spawnCommand(SITE_SCRIPT, [opts.outRoot, opts.siteOut], "prepare web site");
  }

  if (opts.strict && failures.length > 0) {
    fail(`strict mode: ${failures.length} game(s) failed to build`);
  }
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
