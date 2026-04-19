WINDOW_WIDTH  = 1200
WINDOW_HEIGHT = 700
MAX_PLAYERS   = 4   -- engine supports up to this many; lobby sets the actual count

-- Per-player scores (index = player ID).  Legacy globals kept for score states.
PLAYER_SCORES  = {0, 0, 0, 0}
PLAYER1_SCORE  = 0
PLAYER2_SCORE  = 0

-- Default key bindings for each player slot.
-- SettingsState lets any player change these at runtime.
KEY_BINDINGS = {
    [1] = { rotate = 'a',    shoot = 's',  usepower = 'd'     },
    [2] = { rotate = 'left', shoot = 'up', usepower = 'right' },
    [3] = { rotate = 'i',    shoot = 'o',  usepower = 'p'     },
    [4] = { rotate = 'z',    shoot = 'x',  usepower = 'c'     },
}

-- Network state (set by LobbyState before entering play/netclient)
NET = {
    mode    = nil,      -- 'host' | 'client' | nil  (nil = local play)
    localId = 1,        -- which player slot is on this machine
    host    = nil,      -- enet host object
    peer    = nil,      -- enet peer to communicate with
    port    = 22122,
}

push = require 'push'
Class = require 'Class'
require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states.TitleState'
require 'states.EndState'
require 'states.ScoreState'
require 'states.harsh_scoreState'
require 'states.RuleBook'
require 'states.SettingsState'
require 'states.LobbyState'
require 'states.NetClientState'
wf = require 'libraries.windfield.windfield'
--Anima = require("libraries/anim8/anim8")

function love.load()
    --Animation = Anima:init()
    push:setupScreen(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        vsync = true,
        resizable = true,
        stretched = true
    })

    gStateMachine = StateMachine{
        ['title']     = function () return TitleState() end,
        ['play']      = function () return PlayState() end,
        ['end']       = function () return EndState() end,
        ['score']     = function () return ScoreState() end,
        ['newScore']  = function () return NewScoreState() end,
        ['intro']     = function () return RuleBook() end,
        ['settings']  = function () return SettingsState() end,
        ['lobby']     = function () return LobbyState() end,
        ['netclient'] = function () return NetClientState() end,
    }

    gStateMachine:change('title')


    PLAYER1_SCORE = 0
    PLAYER2_SCORE = 0

    love.window.setTitle("Space Warrior")

end

world = wf.newWorld(0, 0, false)

-- Register player collision classes and all weapon classes for MAX_PLAYERS players
local mapsIgnores = {}
for i = 1, MAX_PLAYERS do
    world:addCollisionClass('player'..i)
    world:addCollisionClass('laser'..i..'P',       {ignores = {'player'..i}})
    world:addCollisionClass('Bomb'..i..'P',         {ignores = {'player'..i}})
    world:addCollisionClass('ScatterShot'..i..'P',  {ignores = {'player'..i}})
    world:addCollisionClass('bullets'..i..'P',      {ignores = {'player'..i}})
    table.insert(mapsIgnores, 'laser'..i..'P')
    table.insert(mapsIgnores, 'Bomb'..i..'P')
end
world:addCollisionClass('powersuplier')
world:addCollisionClass('maps', {ignores = mapsIgnores})

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- F11 toggles fullscreen at any time
    if key == 'f11' then
        love.window.setFullscreen(not love.window.getFullscreen())
        return
    end

    -- ESC while fullscreen: exit fullscreen first, don't navigate anywhere
    if key == 'escape' and love.window.getFullscreen() then
        love.window.setFullscreen(false)
        return
    end

    -- Route to the current state (each state handles ESC as "go back to previous screen")
    -- The title screen is the only place that allows quitting (press Q)
    gStateMachine.current:keypressed(key)
end

-- Route textinput to the current state (used by LobbyState for IP entry)
function love.textinput(t)
    if gStateMachine.current.textinput then
        gStateMachine.current:textinput(t)
    end
end

function love.update(dt)
    gStateMachine:update(dt)
    world:update(dt)
end

function love.draw()
    push:apply('start')
    gStateMachine:render()
    --world:draw()
    --love.graphics.print(love.timer.getFPS())
    push:apply('end')

end

-- =============================================================================
-- love.errorhandler — production crash screen + timestamped log
-- Uses only low-level LÖVE APIs (no game modules) so it can never re-crash
-- from game state.  Wraps all risky calls in pcall so a broken graphics
-- driver, missing font file, or failed audio stop still yields a usable UI.
-- =============================================================================
function love.errorhandler(msg)
    msg = tostring(msg or "unknown error")
    local trace = debug.traceback("", 2) or ""
    local details = "Error: " .. msg .. "\n\nStack traceback:" .. trace

    -- Best-effort: write crash log to the LÖVE save directory.
    local logName
    pcall(function ()
        local t = os.date("*t")
        logName = string.format("error-%04d%02d%02d-%02d%02d%02d.log",
            t.year, t.month, t.day, t.hour, t.min, t.sec)
        local header = string.format("SpaceWarrior crash log\nDate: %s\nLÖVE: %s\nOS: %s\n\n",
            os.date("%Y-%m-%d %H:%M:%S"),
            tostring(love._version or "?"),
            tostring(love.system and love.system.getOS() or "?"))
        love.filesystem.write(logName, header .. details .. "\n")
    end)

    -- Best-effort: silence any playing audio so it doesn't loop under the crash screen.
    pcall(function () if love.audio and love.audio.stop then love.audio.stop() end end)

    -- Best-effort: reset graphics to a known state.  If any of this fails we fall
    -- through to the default handler below.
    local ok = pcall(function ()
        if love.graphics and love.graphics.isActive and love.graphics.isActive() then
            love.graphics.reset()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.origin()
        end
        if love.mouse then
            if love.mouse.setVisible then love.mouse.setVisible(true) end
            if love.mouse.setGrabbed then love.mouse.setGrabbed(false) end
            if love.mouse.setRelativeMode then love.mouse.setRelativeMode(false) end
        end
        if love.window and love.window.setMode and love.window.getMode then
            local _, _, flags = love.window.getMode()
            if flags and flags.fullscreen then
                love.window.setFullscreen(false)
            end
        end
    end)
    if not ok then return end

    -- Truncate stack trace to ~20 lines for the on-screen summary.
    local traceLines = {}
    for line in trace:gmatch("[^\n]+") do traceLines[#traceLines + 1] = line end
    local shownLines = {}
    for i = 1, math.min(20, #traceLines) do shownLines[i] = traceLines[i] end
    if #traceLines > 20 then shownLines[#shownLines + 1] = ("... (" .. (#traceLines - 20) .. " more)") end
    local shownTrace = table.concat(shownLines, "\n")

    local screenText = table.concat({
        "Something went wrong.",
        "",
        "Error: " .. msg,
        "",
        shownTrace,
        "",
        logName and ("Log written to: " .. logName) or "(could not write crash log)",
        "",
        "C  — copy details to clipboard",
        "Q  — quit",
    }, "\n")

    -- Drain pending events so keypresses during the crash don't stack up.
    if love.event then pcall(love.event.pump) end

    return function ()
        if love.event then
            love.event.pump()
            for evt, a in love.event.poll() do
                if evt == "quit" then return 1
                elseif evt == "keypressed" and a == "q" then return 1
                elseif evt == "keypressed" and a == "escape" then return 1
                elseif evt == "keypressed" and a == "c" then
                    pcall(function ()
                        if love.system and love.system.setClipboardText then
                            love.system.setClipboardText(details)
                        end
                    end)
                end
            end
        end

        pcall(function ()
            love.graphics.clear(0.12, 0.12, 0.18, 1)
            love.graphics.setColor(1, 1, 1, 1)
            local font = love.graphics.getFont()
            if font then
                love.graphics.printf(screenText, 30, 30,
                    (love.graphics.getWidth() or 800) - 60, "left")
            end
            love.graphics.present()
        end)

        if love.timer then love.timer.sleep(0.1) end
    end
end
