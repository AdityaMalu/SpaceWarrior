# Release Checklist

Checklist for cutting a versioned SpaceWarrior release. The `Release (Tagged)`
workflow (`.github/workflows/release.yml`) fires automatically on any pushed
tag matching `v*.*.*` and publishes a non-pre-release with four attached
artefacts. The beta pipeline on `main` is independent and keeps running.

- [ ] Confirm `main` is green: latest PR checks pass and the most recent beta
      build on GitHub Releases succeeded.
- [ ] Open a PR that promotes the `[Unreleased]` entry in `CHANGELOG.md` to
      `[X.Y.Z] - YYYY-MM-DD` and refreshes the compare-link footer.
- [ ] Merge the CHANGELOG PR to `main`.
- [ ] Tag the release commit on `main`:
      `git checkout main && git pull`
      `git tag -a vX.Y.Z -m "SpaceWarrior vX.Y.Z"`
- [ ] Push the tag: `git push origin vX.Y.Z` (or `git push --tags`).
- [ ] Watch the `Release (Tagged)` workflow finish on GitHub Actions.
- [ ] Verify the GitHub Release `vX.Y.Z`:
      - Marked as latest, not pre-release.
      - Attached assets: `SpaceWarrior-vX.Y.Z.love`,
        `SpaceWarrior-vX.Y.Z-windows-x64.zip`,
        `SpaceWarrior-vX.Y.Z-macos.zip`,
        `SpaceWarrior-vX.Y.Z-linux-x86_64.AppImage`.
- [ ] Smoke-test at least one platform binary locally.
- [ ] Announce the release as needed (README links, social, etc.).
