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
        ['title'] = function () return TitleState() end,
        ['play'] = function () return PlayState() end,
        ['end'] = function () return EndState() end,
        ['score'] = function () return ScoreState() end,
        ['newScore'] = function () return NewScoreState() end,
        ['intro']    = function () return RuleBook() end,
        ['settings'] = function () return SettingsState() end
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
    gStateMachine.current:keypressed(key)
    if key == "escape" then
      love.event.quit()
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
