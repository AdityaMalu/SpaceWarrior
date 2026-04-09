# SpaceWarrior

A local multiplayer 2D space combat game built with [LÖVE](https://love2d.org/) (Lua), inspired by Astro Party.
Two players battle in a physics-driven arena using lasers, bombs, and scatter shots.

---

## Playing the Game

**Requirements:** [LÖVE 11.5](https://love2d.org/) installed.

```bash
# Run from the project root
love SpaceWarrior/
```

| Action | Player 1 | Player 2 |
|--------|----------|----------|
| Rotate | `A` / `D` | `←` / `→` |
| Thrust | `W` | `↑` |
| Shoot  | `S` | `↓` |

---

## Contributing

### Branching Strategy

All work **must** go through a Pull Request — direct commits to `main` are not allowed.

| Branch type | Naming convention | Example |
|-------------|-------------------|---------|
| New feature | `feature/<short-description>` | `feature/scatter-shot-animation` |
| Bug fix     | `fix/<short-description>`     | `fix/player2-collider-reset`     |
| Chore / docs | `chore/<short-description>`  | `chore/update-readme`            |

**Workflow:**

```
1.  git checkout main && git pull
2.  git checkout -b feature/my-change
3.  # … make changes, commit often …
4.  git push origin feature/my-change
5.  Open a Pull Request → main on GitHub
6.  Wait for all CI checks to pass ✅
7.  Request a review, then merge via GitHub UI
```

> Squash-merge is preferred to keep the `main` history clean.

---

## CI/CD Pipeline

Two GitHub Actions workflows automate quality checks and releases.

### 1 · PR Checks (`.github/workflows/pr-checks.yml`)

Triggered on every **Pull Request to `main`**. All three jobs must pass before merging.

| Job | Tool | What it checks |
|-----|------|----------------|
| **Lint** | `luacheck` | Code style, undefined globals, unused variables |
| **Syntax** | `luac5.4 -p` | Parse-level errors in every `.lua` source file |
| **Package** | `zip` + Python | Game can be zipped into a valid `.love` file containing `main.lua` |

The packaged `.love` file is uploaded as a workflow artifact (kept 7 days) so reviewers can download and test the PR build directly.

### 2 · Build & Release (`.github/workflows/build-release.yml`)

Triggered on every **push (merge) to `main`**. Produces a **Beta pre-release** on GitHub.

| Job | What it does |
|-----|--------------|
| **package-love** | Zips game sources → `SpaceWarrior.love` |
| **build-binaries** | Downloads LÖVE 11.5 and produces platform executables |
| **release** | Creates a GitHub pre-release tagged `beta-<run_number>` with all assets attached |

**Distributed artefacts:**

| File | Platform |
|------|----------|
| `SpaceWarrior-windows-x64.zip` | Windows — extract and run `SpaceWarrior.exe` |
| `SpaceWarrior-macos.zip` | macOS — extract and open `SpaceWarrior.app` |
| `SpaceWarrior-linux-x86_64.AppImage` | Linux — `chmod +x` then run |
| `SpaceWarrior.love` | Any OS with LÖVE 11.5 installed |

### Running checks locally

```bash
# Install luacheck (macOS)
brew install luacheck

# Install luacheck (Ubuntu/Debian)
sudo apt-get install luacheck

# Lint (run from SpaceWarrior/ directory)
cd SpaceWarrior
luacheck .

# Syntax-check all source files
find . -name "*.lua" ! -path "*/libraries/*" -exec luac -p {} \;

# Package the game
cd SpaceWarrior && zip -9 -r ../SpaceWarrior.love . --exclude "*.git*"
```

---

## Project Structure

```
SpaceWarrior/
├── main.lua            # Entry point (love.load / love.update / love.draw)
├── StateMachine.lua    # Generic state machine
├── push.lua            # Resolution management
├── class.lua           # OOP helper
├── states/             # Game states (Title, Play, End, Score, RuleBook…)
├── modules/            # Game objects (Player, bullets, powerups, maps…)
├── assets/             # Images, sounds, fonts
└── libraries/          # Vendored third-party libs (windfield, STI, anim8)
```

