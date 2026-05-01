# Dotfiles Refactor Plan

This plan converts the current flat dotfiles repo into a modular, maintainable Stow-based layout while keeping behavior stable.

## Phase 1 - Baseline and Safety Rails [completed]

- [x] Remove user-specific absolute paths where possible.
- [x] Remove duplicated shell init entries and obvious config drift.
- [x] Move git identity into local, untracked config include.
- [x] Eliminate obviously host-specific tracked files (example: GTK bookmarks).
- [x] Make monitor/night mode script robust for multi-monitor setups.

Outcome:
- Current setup is more portable and less tied to a single username/host.

## Phase 2 - Restructure into Modular Stow Packages [completed]

- [x] Create package directories (initial target):
  - `zsh/`
  - `git/`
  - `i3/`
  - `polybar/`
  - `alacritty/`
  - `rofi/`
  - `picom/`
  - `gtk/`
  - `fontconfig/`
  - `x11/`
  - `scripts/`
- [x] Move files from flat layout into package-scoped paths.
- [x] Ensure each package stows cleanly and independently.
- [x] Verify no path collisions or accidental overwrites.

Outcome:
- Repo can be installed selectively (`stow zsh git i3 ...`) instead of all-or-nothing `stow .`.

## Phase 3 - Shared vs Local Configuration Boundaries [completed]

- [x] Introduce local include files (untracked) with tracked examples:
  - `~/.zshrc.local` + `.zshrc.local.example` [done]
  - `~/.gitconfig.local` + `.gitconfig.local.example` [done]
  - optional `~/.config/i3/local.conf` + example include path [example added]
- [x] Move personal aliases, machine-specific env vars, and host quirks into local files.
- [x] Keep committed defaults minimal and portable.

Outcome:
- Shared repo stays clean; per-machine customization remains easy.

## Phase 4 - Installer/Profile Split [completed]

- [x] Replace monolithic installer behavior with explicit scripts:
  - `bootstrap.sh` (minimum prerequisites)
  - `packages.sh` (profile-based package install)
  - optional `services.sh` (explicit service enablement)
- [x] Define install profiles, for example:
  - `core`
  - `desktop`
  - `dev`
  - `media`
- [x] Keep hardware detection (CPU microcode/GPU) explicit and testable.
- [x] Avoid forcing display manager choice by default.

Outcome:
- Installation is safer, clearer, and easier to adapt across machines.

## Phase 5 - Documentation and Onboarding [pending]

- [ ] Rewrite `README.md` around modular workflow.
- [ ] Document recommended install paths:
  - minimal setup
  - full desktop setup
  - per-package stow examples
- [ ] Document local config setup step clearly.
- [ ] Add troubleshooting notes for i3/polybar/picom/startup ordering.

Outcome:
- New machine setup becomes predictable and reproducible.

## Phase 6 - Validation and Regression Checks [pending]

- [ ] Add a lightweight `check.sh` for sanity checks (paths, required binaries, shell syntax).
- [ ] Validate key configs after stow:
  - `zsh -n ~/.zshrc`
  - `i3-msg reload` (if i3 is running)
  - `polybar` launch script smoke test
- [ ] Confirm no unintended tracked local state files.

Outcome:
- Changes are safer to evolve over time with quick confidence checks.

## Execution Notes

- Preserve existing behavior first; then refine defaults.
- Avoid hacks/workarounds; if a design decision becomes unclear, stop and resolve before proceeding.
- Keep each phase reviewable as a standalone set of changes.
