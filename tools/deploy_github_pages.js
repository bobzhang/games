#!/usr/bin/env node

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { spawnSync } = require("child_process");

const ROOT_DIR = path.resolve(__dirname, "..");

function usage() {
  console.log(`Usage:
  tools/deploy_github_pages.sh [options]

Options:
  --site-dir DIR         Directory to publish (default: _build/web_pages_site)
  --remote NAME          Git remote name (default: origin)
  --branch NAME          Pages branch name (default: gh-pages)
  --message MSG          Commit message for deployment
  --dry-run              Prepare branch in temp worktree but do not push
  -h, --help             Show help

Examples:
  tools/deploy_github_pages.sh --site-dir _build/web_pages_site_full_skip
  tools/deploy_github_pages.sh --site-dir _build/web_pages_site --message "Deploy web games"
`);
}

function fail(message, code = 1) {
  console.error(`error: ${message}`);
  process.exit(code);
}

function run(cmd, args, options = {}) {
  const result = spawnSync(cmd, args, {
    cwd: ROOT_DIR,
    stdio: "pipe",
    encoding: "utf8",
    ...options,
  });

  if (result.error) {
    fail(`${cmd} failed: ${result.error.message}`);
  }

  if (result.status !== 0) {
    const stderr = (result.stderr || "").trim();
    const stdout = (result.stdout || "").trim();
    const detail = stderr || stdout || `exit code ${result.status}`;
    fail(`${cmd} ${args.join(" ")} failed: ${detail}`);
  }

  return result.stdout ? result.stdout.trim() : "";
}

function runIn(cwd, cmd, args, options = {}) {
  const result = spawnSync(cmd, args, {
    cwd,
    stdio: "pipe",
    encoding: "utf8",
    ...options,
  });

  if (result.error) {
    fail(`${cmd} failed: ${result.error.message}`);
  }

  if (result.status !== 0) {
    const stderr = (result.stderr || "").trim();
    const stdout = (result.stdout || "").trim();
    const detail = stderr || stdout || `exit code ${result.status}`;
    fail(`${cmd} ${args.join(" ")} failed in ${cwd}: ${detail}`);
  }

  return result.stdout ? result.stdout.trim() : "";
}

function parseArgs(argv) {
  const opts = {
    siteDir: path.join(ROOT_DIR, "_build", "web_pages_site"),
    remote: "origin",
    branch: "gh-pages",
    message: `Deploy web games site (${new Date().toISOString()})`,
    dryRun: false,
  };

  const args = [...argv];
  while (args.length > 0) {
    const arg = args.shift();

    if (arg === "-h" || arg === "--help") {
      usage();
      process.exit(0);
    }

    if (arg === "--site-dir") {
      if (args.length === 0) fail("--site-dir requires a value");
      opts.siteDir = path.resolve(ROOT_DIR, args.shift());
      continue;
    }

    if (arg === "--remote") {
      if (args.length === 0) fail("--remote requires a value");
      opts.remote = args.shift();
      continue;
    }

    if (arg === "--branch") {
      if (args.length === 0) fail("--branch requires a value");
      opts.branch = args.shift();
      continue;
    }

    if (arg === "--message") {
      if (args.length === 0) fail("--message requires a value");
      opts.message = args.shift();
      continue;
    }

    if (arg === "--dry-run") {
      opts.dryRun = true;
      continue;
    }

    fail(`unknown option: ${arg}`);
  }

  return opts;
}

function ensurePrereqs(opts) {
  if (!fs.existsSync(opts.siteDir)) {
    fail(`site directory not found: ${opts.siteDir}`);
  }

  if (!fs.existsSync(path.join(opts.siteDir, "index.html"))) {
    fail(`site directory missing index.html: ${opts.siteDir}`);
  }

  const remotes = run("git", ["remote"]).split("\n").map((s) => s.trim()).filter(Boolean);
  if (!remotes.includes(opts.remote)) {
    fail(`remote not found: ${opts.remote}`);
  }
}

function copySiteToWorktree(siteDir, worktreeDir) {
  // Remove everything except .git
  for (const entry of fs.readdirSync(worktreeDir, { withFileTypes: true })) {
    if (entry.name === ".git") continue;
    const target = path.join(worktreeDir, entry.name);
    fs.rmSync(target, { recursive: true, force: true });
  }

  for (const entry of fs.readdirSync(siteDir, { withFileTypes: true })) {
    const src = path.join(siteDir, entry.name);
    const dst = path.join(worktreeDir, entry.name);
    fs.cpSync(src, dst, { recursive: true });
  }

  const noJekyllPath = path.join(worktreeDir, ".nojekyll");
  if (!fs.existsSync(noJekyllPath)) {
    fs.writeFileSync(noJekyllPath, "", "utf8");
  }
}

function remoteBranchExists(remote, branch) {
  const result = spawnSync("git", ["ls-remote", "--heads", remote, branch], {
    cwd: ROOT_DIR,
    stdio: "pipe",
    encoding: "utf8",
  });

  if (result.error) {
    fail(`git ls-remote failed: ${result.error.message}`);
  }

  if (result.status !== 0) {
    fail(`git ls-remote --heads ${remote} ${branch} failed`);
  }

  return (result.stdout || "").trim().length > 0;
}

function localBranchExists(branch) {
  const result = spawnSync("git", ["show-ref", "--verify", "--quiet", `refs/heads/${branch}`], {
    cwd: ROOT_DIR,
    stdio: "ignore",
  });
  return result.status === 0;
}

function main() {
  const opts = parseArgs(process.argv.slice(2));
  ensurePrereqs(opts);

  const tempBase = fs.mkdtempSync(path.join(os.tmpdir(), "games-gh-pages-"));
  const worktreeDir = path.join(tempBase, "worktree");
  fs.mkdirSync(worktreeDir, { recursive: true });

  const existsRemotely = remoteBranchExists(opts.remote, opts.branch);
  const existsLocally = localBranchExists(opts.branch);
  let worktreeAdded = false;

  try {
    if (existsRemotely) {
      run("git", ["worktree", "add", worktreeDir, `${opts.remote}/${opts.branch}`]);
      worktreeAdded = true;
    } else if (existsLocally) {
      run("git", ["worktree", "add", worktreeDir, opts.branch]);
      worktreeAdded = true;
    } else {
      run("git", ["worktree", "add", "--detach", worktreeDir]);
      worktreeAdded = true;
      runIn(worktreeDir, "git", ["checkout", "--orphan", opts.branch]);
    }

    copySiteToWorktree(opts.siteDir, worktreeDir);

    runIn(worktreeDir, "git", ["add", "-A"]);

    const status = runIn(worktreeDir, "git", ["status", "--porcelain"]);
    if (!status) {
      if (opts.dryRun) {
        console.log(`No changes to deploy on ${opts.branch}.`);
        return;
      }

      if (!existsRemotely) {
        runIn(worktreeDir, "git", ["push", opts.remote, `HEAD:${opts.branch}`]);
        console.log(`Published existing ${opts.branch} branch to ${opts.remote}/${opts.branch}.`);
      } else {
        console.log(`No changes to deploy on ${opts.branch}.`);
      }
      return;
    }

    runIn(worktreeDir, "git", ["commit", "-m", opts.message]);

    if (opts.dryRun) {
      const head = runIn(worktreeDir, "git", ["rev-parse", "--short", "HEAD"]);
      console.log(`Dry run complete. Prepared commit ${head} for ${opts.branch} (not pushed).`);
      return;
    }

    runIn(worktreeDir, "git", ["push", opts.remote, `HEAD:${opts.branch}`]);
    console.log(`Deployed ${opts.siteDir} to ${opts.remote}/${opts.branch}.`);
  } finally {
    if (worktreeAdded) {
      spawnSync("git", ["worktree", "remove", "--force", worktreeDir], {
        cwd: ROOT_DIR,
        stdio: "ignore",
      });
    }
    fs.rmSync(tempBase, { recursive: true, force: true });
  }
}

main();
