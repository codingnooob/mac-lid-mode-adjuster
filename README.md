# lidmode

A macOS command-line tool to inspect and adjust lid-close (clamshell) sleep behavior.

`lidmode status` reads the current power settings with `pmset -g`. `lidmode lid`
and `lidmode idle` change settings by running `sudo pmset`.

## Requirements

- macOS 13 or later
- Swift 6.4 or later to build from source
- Root access to change settings (`pmset` only modifies settings when run as root)

## Build and test

```sh
make build   # swift build
make test    # swift run lidmodeTests
make run     # swift run lidmode
```

Install the binary:

```sh
sudo make install   # copies .build/debug/lidmode to /usr/local/bin
```

## Usage

```sh
lidmode status
lidmode lid <sleep|awake> [--scope all|battery|charger] [--dry-run]
lidmode idle <never|minutes> [--scope all|battery|charger] [--dry-run]
```

Examples:

```sh
lidmode status
lidmode lid awake --scope battery --dry-run   # prints: sudo /usr/bin/pmset -b disablesleep 1
lidmode lid awake --scope battery             # actually changes the setting
lidmode idle never
```

## How it works

- `status` parses `pmset -g` output. `disablesleep` is omitted when it is 0, so
  absence means "sleep when the lid closes".
- `lid` sets `disablesleep` to `0` (sleep on close) or `1` (stay awake, clamshell).
- `idle` sets the `sleep` timer in minutes; `never` means `0`.
- `--scope` maps to `pmset`'s `-a` (all), `-b` (battery), and `-c` (charger) flags.

## Notes

- Changing settings requires `sudo`, which needs a TTY to prompt for a password.
  Run `lidmode` from a terminal, not from a background process.
- `disablesleep` applies to laptops; `pmset` may reject it on desktops.
- Tests use a small in-repo assertion harness (`Tests/lidmodeTests`) instead of
  XCTest or Swift Testing. The Command Line Tools on macOS ship no usable
  XCTest.framework, and the Swift Testing macro plugin does not match the
  installed driver, so `swift test` cannot build this package.
