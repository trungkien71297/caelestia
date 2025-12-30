# AGENTS.md

Guidelines for AI agents working on **Caelestia** - a Hyprland desktop environment
with Fish shell configs, browser extensions, and editor theming.

## Repository Overview

| Path | Description |
|------|-------------|
| `hypr/` | Hyprland WM configs (`.conf` files) |
| `fish/` | Fish shell config and functions |
| `vscode/` | VSCode settings + TypeScript theme extension |
| `zen/` | Zen Browser extension (TypeScript + Fish native app) |
| `install.fish` | Main installer script |

## Build / Lint / Test Commands

### VSCode Extension (`vscode/caelestia-vscode-integration/`)

```bash
cd vscode/caelestia-vscode-integration
npm install
npx tsc -p ./              # Compile TypeScript
npx vsce package           # Package VSIX
```

### Zen Browser Extension (`zen/caelestia-firefox-integration/`)

```bash
cd zen/caelestia-firefox-integration
npm install
npx tsc                    # Compile TypeScript
npx web-ext run            # Test in temp Firefox profile
```

### Fish Scripts

```bash
fish -n install.fish       # Syntax check
```

No automated tests exist; rely on `tsc --strict` for type checking.

## Code Style Guidelines

### General

- **No trailing whitespace**
- **4-space indentation** (TypeScript, JSON)
- **120 char line length** max

### TypeScript

**Compiler Settings**: `strict: true`, ES2022 target (VSCode) / ES6 (Zen)

**Imports**
- Named imports with destructuring
- Type-only imports: `import type { ... }`
- Organize imports on save

**Formatting** (Prettier)
- `tabWidth: 4`, `printWidth: 120`, `arrowParens: "avoid"`
- Arrow functions; omit parens for single params: `x => x + 1`

**Naming**
- `camelCase` for variables/functions
- `PascalCase` for types/interfaces/classes

**Error Handling**
- Log to `console.log`/`console.error`
- Catch startup errors in `activate()` functions

### Fish Shell

- Shebang: `#!/usr/bin/env fish`
- Local vars: `set -l`; existence check: `set -q`
- Prefer `test` over `[` for conditionals
- Double-quote variables: `"$var"`
- Function names: `snake_case` or hyphenated

### Hyprland Configs (`.conf`)

- Variables: `$camelCase` (`$terminal`, `$kbGoToWs`)
- Comments: `#`; section headers: `# ## Section`
- Keybinds: follow `$kb*` naming pattern
- Use `app2unit` for launching apps

### JSON/JSONC

- 4-space indent, `camelCase` keys

### CSS

- CSS custom properties for theming
- 4-space indent; avoid deep nesting

## Commit Convention

```
module: short description
```

Examples:
```
hypr: add pip keybind for picture-in-picture
vscode: update theme colours for better contrast
fish: add git abbreviations
```

## Testing Changes

```bash
./install.fish --help      # Check installer
hyprctl reload             # Reload Hyprland config
caelestia shell -d         # Restart shell integration
```

## Environment

| Variable | Default |
|----------|---------|
| `XDG_CONFIG_HOME` | `~/.config` |
| `XDG_STATE_HOME` | `~/.local/state` |

Runtime scheme: `$XDG_STATE_HOME/caelestia/scheme.json`

## Pull Request Guidelines

From `.github/CONTRIBUTING.md`:

1. **Test your PRs** before submitting
2. Describe what the PR does and how to use it
3. Note any breaking changes or side effects
4. No AI-generated documentation slop

## Key Files Reference

| File | Purpose |
|------|---------|
| `hypr/hyprland/keybinds.conf` | All keyboard shortcuts |
| `hypr/variables.conf` | Shared variables ($terminal, $browser, etc.) |
| `hypr/scheme/current.conf` | Active color scheme (generated) |
| `vscode/.../src/theme.ts` | VSCode theme color mappings |
| `zen/.../src/extension.ts` | Browser theme integration |

## Notes for AI Agents

- This repo is **config files**, not a traditional codebase
- TypeScript extensions are small; focus on theme generation logic
- Fish scripts use `argparse` for CLI parsing
- Hyprland config is modular: edit the right file in `hypr/hyprland/`
- Colors come from Material Design 3 tokens; don't hardcode hex values
- When modifying keybinds, check `hypr/variables.conf` for existing `$kb*` vars
- The installer (`install.fish`) symlinks configs; don't move the repo after install
