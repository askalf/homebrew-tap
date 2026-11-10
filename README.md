# askalf/homebrew-tap

[![CI measured](https://img.shields.io/endpoint?url=https%3A%2F%2Fpitlane.askalf.org%2Fbadge.json)](https://pitlane.askalf.org/)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/askalf/homebrew-tap/badge)](https://scorecard.dev/viewer/?uri=github.com/askalf/homebrew-tap)

Homebrew formulae for [dario](https://github.com/askalf/dario), the local endpoint that runs the AI coding tools you own on your Claude and ChatGPT subscriptions.

```sh
brew install askalf/tap/dario
```

Then:

```sh
dario login --no-proxy   # your Claude plan (Pro, Max 5x or Max 20x); add --manual for SSH / headless
dario proxy              # leave it running, then point any tool at http://localhost:3456 with key `dario`
```

When a valid Claude login is already on the machine (Claude Code's, for example), `dario login` on its own goes straight to starting the proxy; `--no-proxy` keeps it to the sign-in, so the two steps stay apart. `dario add altman` adds your ChatGPT plan as a second seat. Everything after that is in [dario's README](https://github.com/askalf/dario#start-in-60-seconds), with [per-tool setup](https://github.com/askalf/dario/blob/master/docs/tools.md).

Upgrade with `brew upgrade dario`. The formula installs the same package as `npm install -g @askalf/dario`, built from the tarball on the npm registry, so `dario --version` matches the npm release. It depends on Homebrew's `node`.

## How the formula stays current

`bump.yml` runs when dario ships a release (dario's release workflow sends this repository a `dario-release` event), every six hours whether or not that event arrived, and when started by hand. A run reads the latest version from the npm registry, and when the formula already names that version it has nothing to bump. Otherwise it:

1. Downloads that version's tarball, retrying for about a minute, because the registry can answer 404 for a release published seconds earlier.
2. Checks the tarball's sha512 against the registry's integrity field.
3. Verifies its signed npm provenance with `gh attestation verify`: built by dario's `cc-drift-auto-release.yml` on `master`, on a GitHub-hosted runner.
4. Writes the new `url` and `sha256` into `Formula/dario.rb`, then installs, tests and audits the rewritten formula on the runner.
5. Only if all of that passed, opens a pull request from a `bot/dario-<version>` branch, unless one for that version is already open.

Cleanup is separate and best effort: every run that read the latest version and was not cancelled closes each open bump pull request for any other version. That happens when `main` already has the latest version, and also when a later step of the run failed, so it does not depend on the checks above.

`main` takes a change only through a pull request whose checks and review passed. A release published to npm any other way is never picked up.

`tests.yml` runs on every pull request and every push to `main`:

- It installs the formula from source on macOS and Linux, runs `brew test`, `brew audit --strict --online` and `brew style`, and checks that the installed `dario --version` is the version the formula names.
- It checks that the tarball the formula pins carries the same provenance the bump verified.
- On a pull request it checks that the formula's version stays the same or moves forward to the latest npm release, so `main` never goes back to an older dario.
- It tests the download script against a local server that answers 404 before it serves the tarball.

## Problems

Formula or install problems: open an issue here. Problems with dario itself once it runs: [askalf/dario](https://github.com/askalf/dario/issues), and `dario doctor` prints the report to paste.

Security reports: please do not open a public issue. [SECURITY.md](SECURITY.md) has the private channels and what is in scope.
