#!/usr/bin/env python3
"""Remote skill registry helpers for adam_auto_skill."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any


def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


def remotes_file() -> Path:
    return repo_root() / "config" / "remotes.json"


def skills_dir() -> Path:
    return repo_root() / "skills"


def manifest_file() -> Path:
    return skills_dir() / "manifest.json"


def load_remotes() -> dict[str, Any]:
    path = remotes_file()
    if not path.exists():
        return {"version": "1.0.0", "remotes": []}
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)
    data.setdefault("remotes", [])
    return data


def save_remotes(data: dict[str, Any]) -> None:
    path = remotes_file()
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=4)
        handle.write("\n")


def find_remote(name: str) -> dict[str, Any] | None:
    for remote in load_remotes().get("remotes", []):
        if remote.get("name") == name:
            return remote
    return None


def parse_pull_target(target: str) -> tuple[str, str]:
    if "/" not in target:
        raise ValueError(f"Invalid pull target '{target}'. Use <remote>/<skill-name>.")
    remote_name, skill_name = target.split("/", 1)
    if not remote_name or not skill_name:
        raise ValueError(f"Invalid pull target '{target}'.")
    return remote_name, skill_name


def extract_description(skill_md: Path) -> str:
    text = skill_md.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return ""
    parts = text.split("---", 2)
    if len(parts) < 3:
        return ""
    frontmatter = parts[1]
    for line in frontmatter.splitlines():
        stripped = line.strip()
        if stripped.startswith("description:"):
            value = stripped.split(":", 1)[1].strip()
            if value in {">-", ">"}:
                continue
            return value.strip("'\"")
    return ""


def update_manifest_entry(
    skill_name: str,
    *,
    description: str = "",
    tags: list[str] | None = None,
    source: dict[str, Any] | None = None,
    install_type: str = "local",
) -> None:
    path = manifest_file()
    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)

    skills = data.setdefault("skills", [])
    skills = [item for item in skills if item.get("name") != skill_name]
    entry: dict[str, Any] = {
        "name": skill_name,
        "description": description or f"Imported skill: {skill_name}",
        "tags": tags or ["imported"],
        "version": "1.0.0",
        "install_type": install_type,
    }
    if source:
        entry["source"] = source
    skills.append(entry)
    skills.sort(key=lambda item: item.get("name", ""))
    data["skills"] = skills

    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=4)
        handle.write("\n")


def git_clone_skill(remote: dict[str, Any], skill_name: str, destination: Path, force: bool) -> None:
    url = remote["url"]
    branch = remote.get("branch", "main")
    skills_path = remote.get("skills_path", "skills").strip("/")

    if destination.exists():
        if not force:
            raise FileExistsError(f"Skill already exists: {destination}. Use --force to overwrite.")
        if destination.is_symlink():
            destination.unlink()
        else:
            import shutil

            shutil.rmtree(destination)

    with tempfile.TemporaryDirectory(prefix="adam-skill-pull-") as tmp:
        repo_dir = Path(tmp) / "repo"
        subprocess.run(
            [
                "git",
                "clone",
                "--depth",
                "1",
                "--branch",
                branch,
                url,
                str(repo_dir),
            ],
            check=True,
            capture_output=True,
            text=True,
        )

        source_dir = repo_dir / skills_path / skill_name
        if not source_dir.is_dir():
            raise FileNotFoundError(
                f"Skill '{skill_name}' not found at {skills_path}/{skill_name} in {url}"
            )
        if not (source_dir / "SKILL.md").is_file():
            raise FileNotFoundError(f"Missing SKILL.md in pulled skill: {source_dir}")

        import shutil

        shutil.copytree(source_dir, destination)


def cmd_list(_: argparse.Namespace) -> int:
    data = load_remotes()
    remotes = data.get("remotes", [])
    if not remotes:
        print("No remotes configured. Add one with: ./bin/skill remote add <name> <url>")
        return 0
    for remote in remotes:
        print(
            f"{remote.get('name')}\t{remote.get('url')}\t"
            f"branch={remote.get('branch', 'main')}\t"
            f"path={remote.get('skills_path', 'skills')}"
        )
    return 0


def cmd_add(args: argparse.Namespace) -> int:
    data = load_remotes()
    remotes = data.setdefault("remotes", [])
    if any(item.get("name") == args.name for item in remotes):
        print(f"Remote already exists: {args.name}", file=sys.stderr)
        return 1
    remotes.append(
        {
            "name": args.name,
            "url": args.url,
            "branch": args.branch,
            "skills_path": args.skills_path,
        }
    )
    remotes.sort(key=lambda item: item.get("name", ""))
    save_remotes(data)
    print(f"Added remote: {args.name}")
    return 0


def cmd_pull(args: argparse.Namespace) -> int:
    remote_name, skill_name = parse_pull_target(args.target)
    remote = find_remote(remote_name)
    if remote is None:
        print(f"Remote not found: {remote_name}", file=sys.stderr)
        return 1

    destination = skills_dir() / skill_name
    try:
        git_clone_skill(remote, skill_name, destination, args.force)
    except subprocess.CalledProcessError as exc:
        print(exc.stderr or exc, file=sys.stderr)
        return 1
    except (FileNotFoundError, FileExistsError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 1

    if not args.no_update_manifest:
        description = extract_description(destination / "SKILL.md")
        update_manifest_entry(
            skill_name,
            description=description,
            tags=["imported", remote_name],
            source={
                "remote": remote_name,
                "url": remote["url"],
                "branch": remote.get("branch", "main"),
                "skills_path": remote.get("skills_path", "skills"),
            },
            install_type="imported",
        )

    print(f"Pulled skill: {skill_name} from remote '{remote_name}'")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    list_parser = subparsers.add_parser("list")
    list_parser.set_defaults(func=cmd_list)

    add_parser = subparsers.add_parser("add")
    add_parser.add_argument("name")
    add_parser.add_argument("url")
    add_parser.add_argument("--branch", default="main")
    add_parser.add_argument("--skills-path", default="skills")
    add_parser.set_defaults(func=cmd_add)

    pull_parser = subparsers.add_parser("pull")
    pull_parser.add_argument("target", help="Format: <remote>/<skill-name>")
    pull_parser.add_argument("--force", action="store_true")
    pull_parser.add_argument("--no-update-manifest", action="store_true")
    pull_parser.set_defaults(func=cmd_pull)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
