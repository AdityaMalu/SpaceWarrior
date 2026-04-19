local audio = require 'modules.audio'

local PauseState = Class{__includes = BaseState}

local function freezeWorld(worldObject)
    if not worldObject then return nil end
    local originalUpdate = worldObject.update
    worldObject.update = function() end
    return originalUpdate
end

function PauseState:init()
    self.fontTitle = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 52)
    self.fontBody  = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 24)
end

function PauseState:enter(playState)
    self.playState = playState
    self.savedWorldUpdate = freezeWorld(world)
    audio.setBus('music', (AUDIO_VOLUMES.music or 1) * 0.3)
end

function PauseState:_restore()
    if self.savedWorldUpdate then
        world.update = self.savedWorldUpdate
        self.savedWorldUpdate = nil
    end
    audio.apply()
end

function PauseState:_resume()
    self:_restore()
    gStateMachine.current = self.playState
end

function PauseState:_quitToTitle()
    self:_restore()
    gStateMachine.current = self.playState
    gStateMachine:change('title')
end

function PauseState:keypressed(key)
    if key == 'escape' then
        self:_resume()
    elseif key == 'q' then
        self:_quitToTitle()
    end
end

function PauseState:exit()
    self:_restore()
end

function PauseState:render()
    self.playState:render()

    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle('fill', 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setColor(0.08, 0.08, 0.12, 0.92)
    love.graphics.rectangle('fill', WINDOW_WIDTH / 2 - 240, WINDOW_HEIGHT / 2 - 120, 480, 240, 16)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(self.fontTitle)
    love.graphics.printf('PAUSED', 0, WINDOW_HEIGHT / 2 - 70, WINDOW_WIDTH, 'center')

    love.graphics.setFont(self.fontBody)
    love.graphics.printf('ESC — RESUME', 0, WINDOW_HEIGHT / 2 + 5, WINDOW_WIDTH, 'center')
    love.graphics.printf('Q — QUIT TO TITLE', 0, WINDOW_HEIGHT / 2 + 48, WINDOW_WIDTH, 'center')
end

return PauseState