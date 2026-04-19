local audio = {
    sources = {},
    buses = { master = 1, music = 1, sfx = 1 },
}

local function clamp(value)
    if type(value) ~= "number" then return 1 end
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

local function syncFromSettings()
    if type(AUDIO_VOLUMES) ~= "table" then return end
    audio.buses.master = clamp(AUDIO_VOLUMES.master or 1)
    audio.buses.music  = clamp(AUDIO_VOLUMES.music or 1)
    audio.buses.sfx    = clamp(AUDIO_VOLUMES.sfx or 1)
end

local function effectiveVolume(entry)
    local busValue = audio.buses[entry.bus] or 1
    return clamp(entry.baseVolume) * audio.buses.master * busValue
end

local function applyEntry(entry)
    if entry.source and entry.source.setVolume then
        entry.source:setVolume(effectiveVolume(entry))
    end
end

function audio.newSource(path, sourceType, bus)
    syncFromSettings()

    local source = love.audio.newSource(path, sourceType)
    local entry = {
        source = source,
        bus = bus or "sfx",
        baseVolume = 1,
    }
    local wrapper = {}

    function wrapper:setVolume(value)
        entry.baseVolume = clamp(value)
        applyEntry(entry)
    end

    function wrapper:getVolume()
        return entry.baseVolume
    end

    setmetatable(wrapper, {
        __index = function(_, key)
            local value = entry.source[key]
            if type(value) == "function" then
                return function(_, ...)
                    return value(entry.source, ...)
                end
            end
            return value
        end,
    })

    entry.wrapper = wrapper
    table.insert(audio.sources, entry)
    applyEntry(entry)
    return wrapper
end

function audio.setBus(name, value)
    if name ~= "master" and name ~= "music" and name ~= "sfx" then return end
    audio.buses[name] = clamp(value)
    for _, entry in ipairs(audio.sources) do
        applyEntry(entry)
    end
end

function audio.apply()
    syncFromSettings()
    for _, entry in ipairs(audio.sources) do
        applyEntry(entry)
    end
end

return audio