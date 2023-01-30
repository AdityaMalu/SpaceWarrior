WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 700

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
        ['intro'] = function () return RuleBook() end
    }

    gStateMachine:change('title')


    PLAYER1_SCORE = 0
    PLAYER2_SCORE = 0

    love.window.setTitle("Space Warrior")
    
end

world = wf.newWorld(0, 0, false)

world:addCollisionClass('player1')
world:addCollisionClass('player2')
world:addCollisionClass('laser1P', {ignores = {'player1'}})
world:addCollisionClass('laser2P', {ignores = {'player2'}})
world:addCollisionClass('Bomb1P', {ignores = {'player1'}})
world:addCollisionClass('Bomb2P', {ignores = {'player2'}})
world:addCollisionClass('ScatterShot1P', {ignores = {'player1'}})
world:addCollisionClass('ScatterShot2P', {ignores = {'player2'}})
world:addCollisionClass('powersuplier')
world:addCollisionClass('bullets1P', {ignores = {'player1'}})
world:addCollisionClass('bullets2P', {ignores = {'player2'}})
world:addCollisionClass("maps",{ignores = {'laser1P','laser2P','Bomb1P','Bomb2P'}})

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
