#!/usr/bin/env python3
"""
Generates .mcp.json for the Senzing MCP server.
Run from the repo root:  python scripts/setup_mcp.py
"""

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


def find_executable(name: str) -> str | None:
    """Find an executable, checking version-manager locations on top of PATH."""
    # Extend PATH with common Node version-manager locations before searching
    extra_dirs = []
    home = Path.home()

    # nvm (Linux/macOS)
    nvm_dir = Path(os.environ.get("NVM_DIR", home / ".nvm"))
    nvm_versions = nvm_dir / "versions" / "node"
    if nvm_versions.is_dir():
        # Pick the highest installed version
        versions = sorted(nvm_versions.iterdir(), reverse=True)
        for v in versions:
            bin_dir = v / "bin"
            if bin_dir.is_dir():
                extra_dirs.append(str(bin_dir))
                break

    # fnm (Linux/macOS)
    fnm_dir = home / ".local" / "share" / "fnm" / "node-versions"
    if fnm_dir.is_dir():
        versions = sorted(fnm_dir.iterdir(), reverse=True)
        for v in versions:
            bin_dir = v / "installation" / "bin"
            if bin_dir.is_dir():
                extra_dirs.append(str(bin_dir))
                break

    # volta (Linux/macOS/Windows)
    volta_dir = home / ".volta" / "bin"
    if volta_dir.is_dir():
        extra_dirs.append(str(volta_dir))

    # nvm-windows puts node on PATH already, but check the typical location
    nvm_win = Path(os.environ.get("NVM_HOME", home / "AppData" / "Roaming" / "nvm"))
    nvm_symlink = Path(os.environ.get("NVM_SYMLINK", r"C:\Program Files\nodejs"))
    for d in [nvm_symlink, nvm_win]:
        if d.is_dir():
            extra_dirs.append(str(d))

    # Homebrew common paths (macOS)
    for brew in ["/usr/local/bin", "/opt/homebrew/bin"]:
        if Path(brew).is_dir():
            extra_dirs.append(brew)

    # Build an augmented PATH for the search
    augmented_path = os.pathsep.join(extra_dirs) + os.pathsep + os.environ.get("PATH", "")
    return shutil.which(name, path=augmented_path)


def get_node_version(node_bin: str) -> str:
    result = subprocess.run(
        [node_bin, "--version"], capture_output=True, text=True, check=True
    )
    return result.stdout.strip()  # e.g. "v22.22.0"


def main():
    # --- Locate Node / npx ------------------------------------------------
    node_bin = find_executable("node")
    if not node_bin:
        print("ERROR: Could not find 'node'.")
        print("Install Node.js (v18+) and make sure 'node' is available in your shell.")
        sys.exit(1)

    npx_bin = find_executable("npx")
    if not npx_bin:
        print("ERROR: Could not find 'npx'.")
        print("npx ships with npm — make sure npm is installed alongside Node.")
        sys.exit(1)

    # Resolve symlinks for node (the actual binary), but keep npx as the
    # stable wrapper path -- resolving it lands on an internal npm file
    # (npx-cli.js) whose location can change between npm versions.
    node_bin = str(Path(node_bin).resolve())
    npx_bin = str(Path(npx_bin))
    node_dir = str(Path(node_bin).parent)

    # Sanity-check: require Node 18+
    version_str = get_node_version(node_bin)
    major = int(version_str.lstrip("v").split(".")[0])
    if major < 18:
        print(f"ERROR: Node.js v18+ is required (found {version_str}).")
        sys.exit(1)

    # --- Determine output path --------------------------------------------
    repo_root = Path(__file__).resolve().parent.parent
    output = repo_root / ".mcp.json"

    if output.exists():
        confirm = input(f"WARNING: {output} already exists. Overwrite? [y/N] ").strip()
        if confirm.lower() != "y":
            print("Aborted.")
            sys.exit(0)

    # --- Build PATH env ---------------------------------------------------
    # Include the Node bin dir plus standard system directories
    if sys.platform == "win32":
        system_path = r"C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem"
    else:
        system_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

    env_path = os.pathsep.join([node_dir, system_path])

    # --- Write .mcp.json --------------------------------------------------
    config = {
        "mcpServers": {
            "Senzing": {
                "command": node_bin,
                "args": [npx_bin, "-y", "mcp-remote", "https://sz-mcp-coworker.fly.dev/mcp"],
                "env": {"PATH": env_path},
            }
        }
    }

    output.write_text(json.dumps(config, indent=2) + "\n")

    print(f"Created {output}")
    print(f"  Node:  {node_bin} ({version_str})")
    print(f"  npx:   {npx_bin}")


if __name__ == "__main__":
    main()
