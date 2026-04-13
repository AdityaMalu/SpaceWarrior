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
    "PLAYER_SCORES",  -- N-player score table (index = player ID)

    -- N-player config (set in main.lua, read by weapons/players)
    "MAX_PLAYERS",

    -- Dynamic key bindings (set in main.lua, mutated by SettingsState)
    "KEY_BINDINGS",

    -- States
    "SettingsState",

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

    -- ── Legacy / partially-used globals ─────────────────────────────────────
    -- count2: referenced in ScoreState:render() (state not reached in gameplay)
    "count2",
    -- sounds: referenced in Player:takeDamage() (function not called currently)
    "sounds",
    -- class_commons / common: cross-class-system compatibility shim in class.lua
    "class_commons",
    "common",
}

-- ── Exclusions ────────────────────────────────────────────────────────────────
-- Do not lint vendored / third-party files that live outside libraries/.
exclude_files = {
    "libraries/**",
    "push.lua",   -- third-party: push screen-management library
    "class.lua",  -- third-party: Matthias Richter's OOP helper
}

-- ── Warning suppressions ──────────────────────────────────────────────────────
-- 212: unused argument  — LÖVE callbacks have fixed signatures (dt, key, etc.)
-- 213: unused loop variable — common pattern in pairs() iterations
ignore = {
    "212",
    "213",
}

-- ── Style settings ────────────────────────────────────────────────────────────
-- Line-length is not enforced: LÖVE draw calls are naturally verbose.
max_line_length = false
