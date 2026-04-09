-- =============================================================================
-- .luacheckrc — luacheck configuration for SpaceWarrior
-- Run: luacheck . (from the SpaceWarrior/ directory)
-- =============================================================================

-- ── Globals ──────────────────────────────────────────────────────────────────
-- All identifiers that are intentionally global in this project.
globals = {
    -- LÖVE 2D framework
    "love",

    -- Window / resolution globals (set in main.lua)
    "WINDOW_WIDTH",
    "WINDOW_HEIGHT",

    -- Score globals (set in main.lua, mutated in PlayState)
    "PLAYER1_SCORE",
    "PLAYER2_SCORE",

    -- Physics world (set in PlayState:init, shared globally)
    "world",

    -- Active state machine instance
    "gStateMachine",

    -- Third-party libraries required in main.lua
    "push",   -- push.lua  – resolution/window management
    "Class",  -- class.lua – OOP helper
    "wf",     -- windfield – Box2D wrapper

    -- ── State machine & base state ──────────────────────────────────────────
    "StateMachine",
    "BaseState",

    -- ── Game states ─────────────────────────────────────────────────────────
    "TitleState",
    "PlayState",
    "EndState",
    "ScoreState",
    "NewScoreState",   -- defined in states/harsh_scoreState.lua
    "RuleBook",

    -- ── Game module classes ──────────────────────────────────────────────────
    "Player",
    "bullets",
    "Laser",
    "Bomb",
    "ScatterShot",
    "powersuplier",
    "Maps",
}

-- ── Exclusions ────────────────────────────────────────────────────────────────
-- Do not lint vendored third-party libraries.
exclude_files = {
    "libraries/**",
}

-- ── Warning suppressions ──────────────────────────────────────────────────────
-- 212: unused argument  — LÖVE callbacks have fixed signatures (dt, key, etc.)
-- 213: unused loop variable — common pattern in pairs() iterations
ignore = {
    "212",
    "213",
}

-- ── Style settings ────────────────────────────────────────────────────────────
max_line_length = 120
