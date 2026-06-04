#!/usr/bin/env python3
"""Install manifest helpers for adam_auto_skill."""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def default_manifest(repo_root: str) -> dict[str, Any]:
    return {
        "version": "1.0.0",
        "repo_root": repo_root,
        "updated_at": None,
        "skills": {},
    }


def read_manifest(path: Path, repo_root: str) -> dict[str, Any]:
    if not path.exists():
        return default_manifest(repo_root)

    with path.open(encoding="utf-8") as handle:
        data = json.load(handle)

    data.setdefault("version", "1.0.0")
    data.setdefault("repo_root", repo_root)
    data.setdefault("skills", {})
    return data


def write_manifest(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data["updated_at"] = utc_now()
    with path.open("w", encoding="utf-8") as handle:
        json.dump(data, handle, indent=4)
        handle.write("\n")


def cmd_read(args: argparse.Namespace) -> int:
    data = read_manifest(Path(args.manifest), args.repo_root)
    json.dump(data, sys.stdout)
    return 0


def cmd_record(args: argparse.Namespace) -> int:
    path = Path(args.manifest)
    data = read_manifest(path, args.repo_root)
    data.setdefault("skills", {})[args.skill_name] = {
        "mode": args.mode,
        "source": args.source,
        "installed_at": utc_now(),
    }
    write_manifest(path, data)
    return 0


def cmd_remove(args: argparse.Namespace) -> int:
    path = Path(args.manifest)
    data = read_manifest(path, args.repo_root)
    data.get("skills", {}).pop(args.skill_name, None)
    write_manifest(path, data)
    return 0


def cmd_list(args: argparse.Namespace) -> int:
    data = read_manifest(Path(args.manifest), args.repo_root)
    for name in sorted(data.get("skills", {})):
        print(name)
    return 0


def cmd_get_mode(args: argparse.Namespace) -> int:
    data = read_manifest(Path(args.manifest), args.repo_root)
    mode = data.get("skills", {}).get(args.skill_name, {}).get("mode", "")
    print(mode)
    return 0


def cmd_get_entry(args: argparse.Namespace) -> int:
    data = read_manifest(Path(args.manifest), args.repo_root)
    entry = data.get("skills", {}).get(args.skill_name, {})
    mode = entry.get("mode", "unknown")
    installed_at = entry.get("installed_at", "")
    print(f"{mode}\t{installed_at}")
    return 0


def cmd_get_details(args: argparse.Namespace) -> int:
    data = read_manifest(Path(args.manifest), args.repo_root)
    entry = data.get("skills", {}).get(args.skill_name, {})
    if entry:
        print(f"Installed at:            {entry.get('installed_at', 'n/a')}")
        print(f"Source:                  {entry.get('source', 'n/a')}")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", required=True)
    subparsers = parser.add_subparsers(dest="command", required=True)

    read_parser = subparsers.add_parser("read")
    read_parser.add_argument("--manifest", required=True)
    read_parser.set_defaults(func=cmd_read)

    record_parser = subparsers.add_parser("record")
    record_parser.add_argument("--manifest", required=True)
    record_parser.add_argument("--skill-name", required=True)
    record_parser.add_argument("--mode", required=True)
    record_parser.add_argument("--source", required=True)
    record_parser.set_defaults(func=cmd_record)

    remove_parser = subparsers.add_parser("remove")
    remove_parser.add_argument("--manifest", required=True)
    remove_parser.add_argument("--skill-name", required=True)
    remove_parser.set_defaults(func=cmd_remove)

    list_parser = subparsers.add_parser("list")
    list_parser.add_argument("--manifest", required=True)
    list_parser.set_defaults(func=cmd_list)

    mode_parser = subparsers.add_parser("get-mode")
    mode_parser.add_argument("--manifest", required=True)
    mode_parser.add_argument("--skill-name", required=True)
    mode_parser.set_defaults(func=cmd_get_mode)

    entry_parser = subparsers.add_parser("get-entry")
    entry_parser.add_argument("--manifest", required=True)
    entry_parser.add_argument("--skill-name", required=True)
    entry_parser.set_defaults(func=cmd_get_entry)

    details_parser = subparsers.add_parser("get-details")
    details_parser.add_argument("--manifest", required=True)
    details_parser.add_argument("--skill-name", required=True)
    details_parser.set_defaults(func=cmd_get_details)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
