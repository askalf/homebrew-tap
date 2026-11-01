# Security Policy

This tap installs dario from the tarball the npm registry publishes, and only after the tarball's
hash and signed provenance check out. A report that gets a different tarball, or a tarball nobody
built from dario's own release workflow, past those checks gets priority.

## Reporting a vulnerability

Please **do not open a public issue** for security reports.

- **Preferred:** [GitHub private vulnerability reporting](https://github.com/askalf/homebrew-tap/security/advisories/new),
  which opens a private advisory only the maintainers see.
- **Email:** support@askalf.org with `homebrew-tap security` in the subject.

You'll get an acknowledgement within 72 hours. Please include a minimal reproduction where you can.

A vulnerability in dario itself belongs to [dario's security policy](https://github.com/askalf/dario/security/policy).

## Supported versions

The formula on `main` tracks the latest dario release on npm. Only `main` receives fixes; there are
no release branches.

## In scope

- The formula fetching anything but the tarball the npm registry names for the version it pins,
  or installing a tarball whose `sha256` does not match
- The provenance check accepting a tarball that was not built by dario's release workflow on its
  default branch
- The bump workflow writing a version, URL or hash it did not read from the registry, or opening a
  pull request from input a third party controls
- A token or credential of the bump workflow reaching a log, a run page or a pull request

## Out of scope

- What dario does once installed (report that to dario)
- Homebrew itself and the `node` formula it depends on
- Findings that need write access to this repository already
