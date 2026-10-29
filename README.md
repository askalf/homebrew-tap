# askalf/homebrew-tap

Homebrew formulae for [dario](https://github.com/askalf/dario), the local endpoint that runs the AI coding tools you own on your Claude and ChatGPT subscriptions.

```sh
brew install askalf/tap/dario
```

Then:

```sh
dario login      # your Claude plan; `dario login --manual` for SSH / headless
dario proxy      # leave it running, then point any tool at http://localhost:3456 with key `dario`
```

Upgrade with `brew upgrade dario`. The formula installs the same package as `npm install -g @askalf/dario`, built from the tarball on the npm registry, so `dario --version` matches the npm release. It depends on Homebrew's `node`.

## How the formula stays current

`bump.yml` runs every six hours. It reads the latest version from the npm registry, downloads that tarball, checks its sha512 against the registry's integrity field, verifies its signed npm provenance (built by dario's `cc-drift-auto-release.yml` on `master`, on a GitHub-hosted runner, with `gh attestation verify`), writes the new `url` and `sha256` into `Formula/dario.rb`, installs and tests the rewritten formula on the runner, and commits only if all of that passed. A release published to npm any other way is never picked up. `tests.yml` installs the formula from source on macOS and Linux on every push and pull request, then runs `brew test`, `brew audit --strict --online` and `brew style`, and checks that the tarball the formula pins carries the same provenance.

## Problems

Formula or install problems: open an issue here. Problems with dario itself once it runs: [askalf/dario](https://github.com/askalf/dario/issues), and `dario doctor` prints the report to paste.
