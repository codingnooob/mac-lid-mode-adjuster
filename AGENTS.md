# AGENTS.md

`lidmode` is a macOS command-line tool that inspects and adjusts lid-close
(clamshell) sleep behavior. It reads `pmset -g` and changes settings by running
`sudo pmset`. Swift Package Manager, no external dependencies.

## Layout

- `Sources/lidmodeCore/` — library target: `PMSetSettings` (parses `pmset -g`),
  `LidSleepMode`, `PMSet`/`PMSetScope`/`PMSetError`, `LidModeController`.
- `Sources/lidmode/lidmode.swift` — executable target; CLI parsing and output only.
- `Tests/lidmodeTests/` — executable test runner (`@testable import lidmodeCore`).
- `Makefile`, `README.md`, `Package.swift`.

## Build & test

```sh
make build      # swift build
make test       # swift run lidmodeTests (exits non-zero on failure)
make run        # swift run lidmode (prints usage)
```

Direct invocations:

```sh
swift run lidmode status
swift run lidmode lid awake --scope battery --dry-run
swift run lidmode idle never --dry-run
```

`make install` copies `.build/debug/lidmode` to `/usr/local/bin` (needs sudo).
`make clean` runs `swift package clean`. `PREFIX` overrides the install prefix.

## Conventions

- Swift 6, `swift-tools-version: 6.4`; every target enables
  `ApproachableConcurrency`.
- Keep the executable target thin: behavior lives in `lidmodeCore`, which is
  `public` and imported normally. Tests use `@testable import lidmodeCore`.
- I/O is behind the `PMSetReading` / `PMSetWriting` protocols so tests inject
  fakes (`FakeReader`, `FakeWriter`). `SystemPMSet` is the only real implementation.
- Errors are `PMSetError: LocalizedError`; the CLI prints
  `error.localizedDescription` to stderr and exits 1. Usage errors print usage
  to stderr and exit 2.
- `pmset` keys are normalized (lowercased, whitespace stripped) before lookup;
  keys may contain spaces (e.g. `Sleep On Power Button`).
- Dry-run output comes from `DryRunPMSet`, never from the real writer.

## Pitfalls

- `swift test` does NOT work here: Command Line Tools ship no usable
  `XCTest.framework`, and the Swift Testing macro plugin is ABI-incompatible
  with the installed driver. Always use `make test` / `swift run lidmodeTests`.
- `disablesleep` is omitted from `pmset -g` when it is 0; absence means
  "sleep when the lid closes".
- Changing settings requires root and a TTY for the sudo password; run from a
  terminal, not a background process. Use `--dry-run` to preview the command.
- `disablesleep` is laptop-only; `pmset` may reject it on desktops.
- This directory is a linked Git worktree on branch `add-agents-md`. The main
  worktree is `/Users/clawctopus/orca/projects/mac-lid-mode-adjuster` on `main`;
  Git metadata is shared, so do not run `git worktree remove`/repair from here.
- `.build/` is gitignored; never commit it.
