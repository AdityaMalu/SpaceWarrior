window_width=1200
window_height=800

Class= require'Class'

require'StateMachine'
require 'States/BaseState'
require'States/TitleScreen'
require'States/PlayState'

wf = require 'libraries/windfield'


world = wf.newWorld(0, 0, false)
world:addCollisionClass('player1')
world:addCollisionClass('player2')
world:addCollisionClass('Bullet1')
world:addCollisionClass('Powers')
world:addCollisionClass('reverseall')


function love.load()
  love.window.setMode(window_width, window_height)
  love.window.setTitle("Space Warriors")

  gStateMachine = StateMachine{
        ['title'] =function () return TitleScreen() end,
        ['play'] = function () return PlayState() end
    }

    gStateMachine:change('title')
end

function love.update(dt)
  gStateMachine:update(dt)
end


function love.keypressed(key)
  gStateMachine.current:keypressed(key)
end

function love.draw()

  gStateMachine:render()
  world:draw()
end
