#!/usr/bin/env python3
"""Generate high-quality docs for web game packages."""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Iterable


def canonical_game_names_from_build_scripts(root: Path) -> list[str]:
    scripts = sorted((root / "tools").glob("build_web_*.sh"))
    games: list[str] = []
    for script in scripts:
        if script.name == "build_web_native_emcc.sh":
            continue
        stem = script.stem
        if not stem.startswith("build_web_"):
            continue
        games.append(f"raylib_{stem[len('build_web_'):]}")
    return games


def slug_to_title(game_dir_name: str) -> str:
    slug = game_dir_name
    if slug.startswith("raylib_"):
        slug = slug[len("raylib_") :]
    return " ".join(part.capitalize() for part in slug.split("_"))


def read_games_from_file(path: Path) -> list[str]:
    items: list[str] = []
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        items.append(line)
    return items


def trim_blank_edges(lines: list[str]) -> list[str]:
    start = 0
    end = len(lines)
    while start < end and not lines[start].strip():
        start += 1
    while end > start and not lines[end - 1].strip():
        end -= 1
    return lines[start:end]


def parse_markdown_sections(text: str) -> tuple[str | None, list[str], dict[str, list[str]], list[str]]:
    lines = text.splitlines()
    title: str | None = None
    preamble: list[str] = []
    sections: dict[str, list[str]] = {}
    section_order: list[str] = []
    current_section: str | None = None
    current_content: list[str] = []
    in_fence = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence

        if title is None and line.startswith("# "):
            title = line[2:].strip()
            continue

        sec_match = None if in_fence else re.match(r"^##\s+(.+?)\s*$", line)
        if sec_match:
            if current_section is None:
                preamble = trim_blank_edges(current_content)
            else:
                sections[current_section] = trim_blank_edges(current_content)
                section_order.append(current_section)
            current_section = sec_match.group(1).strip()
            current_content = []
            continue

        current_content.append(line)

    if current_section is None:
        preamble = trim_blank_edges(current_content)
    else:
        sections[current_section] = trim_blank_edges(current_content)
        section_order.append(current_section)

    return title, preamble, sections, section_order


def first_paragraph(lines: list[str]) -> str:
    in_fence = False
    block: list[str] = []
    blocks: list[list[str]] = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        if not stripped:
            if block:
                blocks.append(block)
                block = []
            continue
        if stripped.startswith("#"):
            continue
        block.append(stripped)
    if block:
        blocks.append(block)
    return " ".join(blocks[0]).strip() if blocks else ""


def find_section(sections: dict[str, list[str]], keywords: Iterable[str]) -> list[str] | None:
    lowered = [(name, name.lower()) for name in sections]
    for key in keywords:
        for name, lname in lowered:
            if key in lname:
                content = sections.get(name, [])
                if content:
                    return content
    return None


def parse_mbti(path: Path) -> tuple[str, dict[str, list[str]]]:
    package = ""
    known_sections = ["Values", "Errors", "Types and methods", "Type aliases", "Traits"]
    data: dict[str, list[str]] = {name: [] for name in known_sections}
    current: str | None = None
    in_import_block = False

    for raw in path.read_text().splitlines():
        line = raw.rstrip()
        package_match = re.match(r'^package\s+"([^"]+)"$', line)
        if package_match:
            package = package_match.group(1)
            continue

        if line.startswith("import {"):
            in_import_block = True
            continue
        if in_import_block:
            if line.strip() in {"}", "},"}:
                in_import_block = False
            continue

        sec_match = re.match(r"^//\s*(.+?)\s*$", line)
        if sec_match:
            sec_name = sec_match.group(1)
            current = sec_name if sec_name in data else None
            continue

        stripped = line.strip()
        if stripped == "":
            if current and data[current] and data[current][-1] != "":
                data[current].append("")
            continue
        if current:
            data[current].append(line)

    for sec_name in known_sections:
        data[sec_name] = trim_blank_edges(data[sec_name])
    return package, data


def export_counts(export_lines: list[str]) -> tuple[int, int, int, int]:
    values = 0
    types = 0
    aliases = 0
    traits = 0
    for line in export_lines:
        s = line.strip()
        if not s:
            continue
        if s.startswith("pub fn") or s.startswith("pub let") or s.startswith("pub const"):
            values += 1
        elif s.startswith("type "):
            types += 1
        elif s.startswith("trait "):
            traits += 1
        elif s.startswith("typealias ") or s.startswith("pub typealias ") or s.startswith("subtype "):
            aliases += 1
    return values, types, aliases, traits


def section_heading(name: str, body: list[str]) -> list[str]:
    if not body:
        return []
    return [f"## {name}", ""] + trim_blank_edges(body) + [""]


def build_default_build_section(game_dir_name: str) -> list[str]:
    return [
        "```bash",
        f"moon build --target native {game_dir_name}/",
        f"moon run --target native {game_dir_name}/",
        "```",
    ]


def build_api_section(game_dir: Path, package_title: str) -> list[str]:
    mbti_files = sorted(game_dir.glob("**/pkg.generated.mbti"))
    lines: list[str] = [
        "The API surface below is generated from `pkg.generated.mbti` files to stay aligned with the compiled public interface.",
        "",
    ]
    if not mbti_files:
        lines.append("- No `pkg.generated.mbti` files were found for this game package.")
        return lines

    for mbti in mbti_files:
        package_name, data = parse_mbti(mbti)
        rel = mbti.relative_to(game_dir).as_posix()
        export_lines: list[str] = []
        for sec in ["Values", "Types and methods", "Type aliases", "Traits"]:
            if data[sec]:
                if export_lines and export_lines[-1] != "":
                    export_lines.append("")
                export_lines.extend(data[sec])
        export_lines = trim_blank_edges(export_lines)
        values, types, aliases, traits = export_counts(export_lines)

        lines.append(f"### Package `{package_name or package_title}`")
        lines.append(f"- Source: `{rel}`")
        if not export_lines:
            lines.append("- Export summary: no exported values/types/traits in this package.")
            lines.append("")
            continue

        lines.append(
            f"- Export summary: {values} values, {types} types, {aliases} type aliases, {traits} traits."
        )
        lines.append("```mbti")
        lines.extend(export_lines)
        lines.append("```")
        lines.append("")

    return trim_blank_edges(lines)


def build_architecture_section(game_dir: Path) -> list[str]:
    internal_root = game_dir / "internal"
    if not internal_root.is_dir():
        return [
            "This game uses a single-package architecture with the main loop and rendering logic defined in `main.mbt`.",
            "- `main.mbt`: bootstraps the raylib window, owns game state, updates simulation, and renders each frame.",
            "- Data and logic cohesion is currently package-local, which keeps the executable simple and easy to run.",
        ]

    subdirs = sorted([d.name for d in internal_root.iterdir() if d.is_dir()])
    lines: list[str] = [
        "This game follows a layered runtime loop: initialize state, update simulation, then render a frame.",
        "- Root package (`main.mbt`): application bootstrap and frame orchestration.",
    ]

    if "game" in subdirs:
        lines.append("- `internal/game`: gameplay rules, input handling, and state transitions.")
    if "render" in subdirs:
        lines.append("- `internal/render`: drawing pipeline and UI presentation.")
    if "types" in subdirs:
        lines.append("- `internal/types`: shared types, constants, and utility helpers.")
    if "levels" in subdirs:
        lines.append("- `internal/levels`: stage layout/profile data and progression setup.")
    if "world" in subdirs:
        lines.append("- `internal/world`: world/map simulation and spatial helpers.")
    if "particles" in subdirs:
        lines.append("- `internal/particles`: particle and transient visual effects.")
    if "score" in subdirs:
        lines.append("- `internal/score`: scoring rules and progression bookkeeping.")
    if "effects" in subdirs:
        lines.append("- `internal/effects`: post-processing or gameplay effect orchestration.")

    covered = {"game", "render", "types", "levels", "world", "particles", "score", "effects"}
    for name in subdirs:
        if name not in covered:
            lines.append(f"- `internal/{name}`: package-specific responsibilities for this game variant.")
    return lines


def build_refinement_plan(game_dir: Path) -> list[str]:
    internal_root = game_dir / "internal"
    subdirs = sorted([d.name for d in internal_root.iterdir() if d.is_dir()]) if internal_root.is_dir() else []

    plan: list[str] = [
        '- Keep `warnings = "+missing_doc"` enabled in all package `moon.pkg` files and treat warnings as part of CI quality gates.',
    ]

    if "game" in subdirs:
        plan.append("- Add deterministic simulation tests for core update logic (fixed seeds and replayable frame steps).")
    else:
        plan.append("- Extract update logic into dedicated helper functions to make rule changes easier to validate with tests.")

    if "render" in subdirs:
        plan.append("- Introduce render profiling counters (draw calls, frame time buckets) and optimize heavy scenes.")
    else:
        plan.append("- Separate rendering from state mutation to simplify future visual iterations.")

    if "types" in subdirs:
        plan.append("- Split balancing constants into tunable config groups to reduce rebalance risk during gameplay tweaks.")
    else:
        plan.append("- Introduce explicit state structs and constant groups to improve readability and maintenance.")

    if "levels" in subdirs:
        plan.append("- Move stage/mission definitions to data-driven descriptors for faster content iteration.")
    elif "world" in subdirs:
        plan.append("- Add world-state integrity checks to catch invalid map/object states early.")
    else:
        plan.append("- Add scenario-based tests that cover early, mid, and late-game difficulty behavior.")

    return plan[:5]


def ensure_missing_doc_warning(pkg_file: Path) -> bool:
    text = pkg_file.read_text()
    if "missing_doc" in text:
        return False

    warning_line_re = re.compile(r'(?m)^(\s*warnings\s*=\s*)"([^"]*)"\s*$')
    match = warning_line_re.search(text)
    if match:
        existing = match.group(2).strip()
        merged = f"{existing} +missing_doc".strip()
        updated = text[: match.start(2)] + merged + text[match.end(2) :]
        pkg_file.write_text(updated)
        return True

    suffix = ""
    if text and not text.endswith("\n"):
        suffix = "\n"
    suffix += "\nwarnings = \"+missing_doc\"\n"
    pkg_file.write_text(text + suffix)
    return True


def build_readme(game_dir: Path) -> str:
    readme_path = game_dir / "README.mbt.md"
    existing_text = readme_path.read_text() if readme_path.exists() else ""
    title, preamble, sections, order = parse_markdown_sections(existing_text)
    final_title = title or slug_to_title(game_dir.name)

    intro_section = find_section(sections, ["introduction", "overview", "intro"])
    intro_text = first_paragraph(intro_section if intro_section else preamble)
    if not intro_text:
        intro_text = (
            f"{final_title} is a raylib game package in this repository. "
            "This README documents its gameplay intent, public API surface, "
            "architecture, and a practical refinement plan."
        )

    build_section = find_section(sections, ["build and run", "build & run", "build", "run"])
    controls_section = find_section(sections, ["controls"])
    play_section = find_section(sections, ["how to play", "gameplay", "play"])

    if not build_section:
        build_section = build_default_build_section(game_dir.name)
    if not controls_section:
        controls_section = ["- Refer to the in-game UI for the current control mapping."]
    if not play_section:
        play_section = [
            "Start a run, learn enemy and obstacle patterns, and optimize movement plus timing to maximize score and survival."
        ]

    ignore_keywords = [
        "introduction",
        "overview",
        "intro",
        "build",
        "run",
        "controls",
        "how to play",
        "gameplay",
        "public api",
        "architecture",
        "improvement",
        "refinement",
    ]
    extra_sections: list[tuple[str, list[str]]] = []
    for sec_name in order:
        lname = sec_name.lower()
        if any(key in lname for key in ignore_keywords):
            continue
        content = sections.get(sec_name, [])
        if content:
            extra_sections.append((sec_name, content))

    api_section = build_api_section(game_dir, final_title)
    arch_section = build_architecture_section(game_dir)
    plan_section = build_refinement_plan(game_dir)

    out: list[str] = [f"# {final_title}", ""]
    out += section_heading("Introduction to the Game", [intro_text])
    out += section_heading("Build and Run", build_section)
    out += section_heading("Controls", controls_section)
    out += section_heading("How to Play", play_section)

    for sec_name, sec_body in extra_sections:
        out += section_heading(sec_name, sec_body)

    out += section_heading("Public API Documentation", api_section)
    out += section_heading("Architecture", arch_section)
    out += section_heading("Improvement and Refinement Plan", [f"- {line.lstrip('- ').strip()}" for line in plan_section])

    return "\n".join(trim_blank_edges(out)) + "\n"


def process_game(root: Path, game_name: str) -> tuple[bool, int]:
    game_dir = root / game_name
    if not game_dir.is_dir():
        print(f"[warn] skipping missing game directory: {game_name}")
        return False, 0

    readme_path = game_dir / "README.mbt.md"
    new_readme = build_readme(game_dir)
    readme_changed = (not readme_path.exists()) or (readme_path.read_text() != new_readme)
    if readme_changed:
        readme_path.write_text(new_readme)

    warning_changes = 0
    for pkg_file in sorted(game_dir.glob("**/moon.pkg")):
        if ensure_missing_doc_warning(pkg_file):
            warning_changes += 1

    return readme_changed, warning_changes


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate docs for raylib game packages.")
    parser.add_argument("--game", action="append", default=[], help="Game directory name (repeatable).")
    parser.add_argument("--games-file", type=Path, help="File with one game directory per line.")
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    games: list[str] = []
    games.extend(args.game)
    if args.games_file:
        games.extend(read_games_from_file(args.games_file))
    if not games:
        games = canonical_game_names_from_build_scripts(root)

    # Keep deterministic order while preserving de-duplication.
    deduped: list[str] = []
    seen: set[str] = set()
    for game in games:
        if game not in seen:
            deduped.append(game)
            seen.add(game)

    changed_readmes = 0
    changed_warnings = 0
    for game in deduped:
        readme_changed, warning_changes = process_game(root, game)
        if readme_changed:
            changed_readmes += 1
        changed_warnings += warning_changes

    print(
        f"Processed {len(deduped)} games: "
        f"updated_readmes={changed_readmes}, updated_warning_entries={changed_warnings}"
    )


if __name__ == "__main__":
    main()
