TitleState = Class{__includes = BaseState}

local audio = require 'modules.audio'

function TitleState:init()
    -- Single cleanup point for any LAN connection left over from a finished game.
    -- PlayState intentionally keeps enet alive across rounds; arriving here means
    -- the player truly exited, so we tear it down now.
    if NET.host then
        NET.host:destroy()
        NET.host    = nil
        NET.peer    = nil
        NET.mode    = nil
        NET.localId = 1
    end

    self.background = love.graphics.newImage("assets/BG.png")
    self.font  = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 60)
    self.font2 = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 30)
    self.sounds = audio.newSource("assets/Sounds/SkyFire (Title Screen).ogg", "static", "music")
    self.sounds:setVolume(0.5)
    self.sounds:setLooping(true)
    self.sounds:play()
    self.notice = ""
end

function TitleState:enter(message)
    self.notice = message or ""
end

function TitleState:update()
    if love.keyboard.isDown("return") then
        gStateMachine:change("play")
    end
    if love.keyboard.isDown("i") then
        gStateMachine:change("intro")
    end
end

-- keypressed handles single-press navigation (avoids repeating on hold)
function TitleState:keypressed(key)
    if key == 'k' then
        gStateMachine:change("settings")
    elseif key == 'l' then
        gStateMachine:change("lobby")
    elseif key == 'c' then
        gStateMachine:change("credits")
    elseif key == 'q' then
        love.event.quit()
    end
    -- ESC on the title screen does nothing: there is no "previous" screen.
    -- Fullscreen ESC is already handled globally in main.lua.
end

function TitleState:exit()
    self.sounds:stop()
end

function TitleState:render()
    love.graphics.draw(self.background,0,0,0,WINDOW_WIDTH/self.background:getWidth(),WINDOW_HEIGHT/self.background:getHeight())
    love.graphics.setFont(self.font)
    love.graphics.printf("Space Warrior",0,0,WINDOW_WIDTH,"center")
    love.graphics.setFont(self.font2)
    if self.notice ~= "" then
        love.graphics.setColor(1, 0.8, 0.4)
        love.graphics.printf(self.notice, 120, 385, WINDOW_WIDTH - 240, "center")
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.printf("PRESS ENTER TO PLAY",       0, 430, WINDOW_WIDTH, "center")
    love.graphics.printf("PRESS I FOR RULES",          0, 470, WINDOW_WIDTH, "center")
    love.graphics.printf("PRESS K FOR KEY BINDINGS",   0, 510, WINDOW_WIDTH, "center")
    love.graphics.printf("PRESS L FOR LAN GAME",       0, 550, WINDOW_WIDTH, "center")
    love.graphics.printf("PRESS C FOR CREDITS",        0, 590, WINDOW_WIDTH, "center")
    love.graphics.printf("F11 TOGGLE FULLSCREEN",      0, 630, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.printf("PRESS Q TO QUIT",            0, 670, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)

end
