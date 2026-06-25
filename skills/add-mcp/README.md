# add-mcp

Scaffolds a new domain MCP server in the org `mcps` monorepo.

**Invoke:** `/add-mcp <domain>` (e.g. `/add-mcp jira`)

**Tools used:** Bash, Read, Write, Edit, Glob

## What it does

1. Copies `templates/new-server/` → `servers/<domain>/`
2. Renames the Python package to `<domain>_mcp`
3. Updates all placeholder strings in `pyproject.toml`, `server.py`, `Dockerfile`
4. Runs `uv sync` to register the new workspace member
5. Validates the import works
6. Guides the user on next steps

## Requirements

- Must be run from the `mcps` monorepo root
- `uv` must be installed
