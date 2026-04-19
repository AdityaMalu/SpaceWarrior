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
