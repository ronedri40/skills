---
name: Add MCP Server
description: Scaffolds a new domain MCP server in the org mcps monorepo following org conventions
version: 1.0.0
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
---

# Add MCP Server

## When to use

Invoke with `/add-mcp <domain>` inside the `mcps` monorepo to scaffold a new MCP server.

Example: `/add-mcp jira`

The domain name becomes both the directory name (`servers/jira/`) and the Python package (`jira_mcp`).

## Instructions

1. Read `$ARGUMENTS` as the domain name (e.g. `jira`). If empty, ask the user for it.
2. Verify you are in the mcps repo root — check that `pyproject.toml` contains `[tool.uv.workspace]`. If not, stop and tell the user.
3. Check `servers/<domain>/` does not already exist. If it does, stop.
4. Copy the template:
   ```bash
   cp -r templates/new-server servers/<domain>
   ```
5. Rename the Python package directory:
   ```bash
   mv servers/<domain>/src/server_name_mcp servers/<domain>/src/<domain>_mcp
   ```
6. In `servers/<domain>/pyproject.toml`:
   - Set `name = "<domain>-mcp"`
   - Set `description = "MCP server for <domain>"`
   - Update the script entry point to `<domain>-mcp = "<domain>_mcp.server:main"`
7. In `servers/<domain>/src/<domain>_mcp/server.py`:
   - Replace every `server_name_mcp` import with `<domain>_mcp`
   - Replace `DOMAIN MCP` display name with a properly capitalised version
8. In `servers/<domain>/Dockerfile`:
   - Replace every `DOMAIN` placeholder with the actual domain name
9. In `servers/<domain>/src/<domain>_mcp/tools/example_tools.py`,
   `resources/example_resources.py`, `prompts/example_prompts.py`:
   - Replace `server_name_mcp` imports with `<domain>_mcp`
10. Run `uv sync` to register the new workspace member.
11. Validate the install:
    ```bash
    uv run --package <domain>-mcp python -c "from <domain>_mcp.server import mcp; print(mcp)"
    ```
12. Tell the user what they need to do next:
    - Implement tools in `servers/<domain>/src/<domain>_mcp/tools/`
    - Add their team to `.github/CODEOWNERS`
    - Add the server to `docker-compose.yml`
    - Run `uv run pytest servers/<domain>/tests/ -v` after implementation
