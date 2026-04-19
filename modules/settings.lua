-- modules/settings.lua
--
-- Persist user settings (key bindings, audio volumes, fullscreen preference)
-- to love.filesystem.getSaveDirectory()/settings.json.
--
-- Schema (version 1):
--   {
--     "version":      1,
--     "keyBindings":  { [playerId] = { rotate=, shoot=, usepower= }, ... },
--     "audioVolumes": { "master"=1.0, "music"=0.5, "sfx"=0.5 },
--     "fullscreen":   true
--   }
--
-- Forward-compatible: unknown top-level keys are ignored; missing keys fall
-- back to current in-memory defaults (KEY_BINDINGS, AUDIO_VOLUMES,
-- FULLSCREEN_PREF declared in main.lua).

local json = require 'libraries.json.json'

local settings = {}

settings.FILE    = "settings.json"
settings.VERSION = 1

-- Append a line to the crash/diagnostic log used by the stability task.
-- We fall back silently if love.filesystem is not available (unit-test context).
local function logError(msg)
    if love and love.filesystem and love.filesystem.append then
        local line = string.format("[settings] %s %s\n", os.date("%Y-%m-%dT%H:%M:%S"), msg)
        pcall(love.filesystem.append, "crash.log", line)
    end
end

-- Shallow-merge src into dst for known keys only. Used so a malformed or
-- partial file can't delete valid defaults.
local function mergeBindings(dst, src)
    if type(src) ~= "table" then return end
    for playerId, actions in pairs(src) do
        local pid = tonumber(playerId) or playerId
        if type(actions) == "table" and dst[pid] then
            for _, field in ipairs({"rotate", "shoot", "usepower"}) do
                if type(actions[field]) == "string" and #actions[field] > 0 then
                    dst[pid][field] = actions[field]
                end
            end
        end
    end
end

local function mergeVolumes(dst, src)
    if type(src) ~= "table" then return end
    for _, field in ipairs({"master", "music", "sfx"}) do
        local v = src[field]
        if type(v) == "number" and v >= 0 and v <= 1 then
            dst[field] = v
        end
    end
end

-- Build the JSON-serialisable snapshot from the current in-memory globals.
local function snapshot()
    return {
        version      = settings.VERSION,
        keyBindings  = KEY_BINDINGS,
        audioVolumes = AUDIO_VOLUMES,
        fullscreen   = FULLSCREEN_PREF and true or false,
    }
end

-- Write current globals to disk. Returns true on success, false + err on failure.
function settings.save()
    if not (love and love.filesystem) then
        return false, "love.filesystem unavailable"
    end
    local ok, encoded = pcall(json.encode, snapshot())
    if not ok then
        logError("encode failed: " .. tostring(encoded))
        return false, encoded
    end
    local wrote, err = love.filesystem.write(settings.FILE, encoded)
    if not wrote then
        logError("write failed: " .. tostring(err))
        return false, err
    end
    return true
end

-- Load settings from disk, merging over existing defaults. Safe to call when
-- no file exists (writes defaults) or when file is malformed (logs + falls
-- back to defaults, overwriting the bad file).
function settings.load()
    if not (love and love.filesystem) then
        return false, "love.filesystem unavailable"
    end

    if not love.filesystem.getInfo(settings.FILE) then
        -- First launch: seed the file with current defaults.
        return settings.save()
    end

    local contents, readErr = love.filesystem.read(settings.FILE)
    if not contents then
        logError("read failed: " .. tostring(readErr))
        return settings.save()
    end

    local ok, decoded = pcall(json.decode, contents)
    if not ok or type(decoded) ~= "table" then
        logError("decode failed, resetting to defaults: " .. tostring(decoded))
        return settings.save()
    end

    mergeBindings(KEY_BINDINGS, decoded.keyBindings)
    mergeVolumes(AUDIO_VOLUMES, decoded.audioVolumes)
    if type(decoded.fullscreen) == "boolean" then
        FULLSCREEN_PREF = decoded.fullscreen
    end
    return true
end

return settings
