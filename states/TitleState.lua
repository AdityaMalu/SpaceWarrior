TitleState = Class{__includes = BaseState}

function TitleState:init()
    self.background = love.graphics.newImage("assets/BG.png")
    self.font = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",60)
    self.font2 = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",30)
    self.sounds = love.audio.newSource("assets/Sounds/SkyFire (Title Screen).ogg","static")
    self.sounds:setVolume(0.5)
    self.sounds:setLooping(true)
    self.sounds:play()
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
    elseif key == 'q' then
        love.event.quit()
    end
    -- ESC on the title screen does nothing: there is no "previous" screen.
    -- Fullscreen ESC is already handled globally in main.lua.
end

function TitleState:exit()
    self.sounds:stop()
end

-- function love.keypressed(key)
--     if(key== "return") then
--         gStateMachine:change("play")
--     end
-- end

function TitleState:render()
    love.graphics.draw(self.background,0,0,0,WINDOW_WIDTH/self.background:getWidth(),WINDOW_HEIGHT/self.background:getHeight())
    love.graphics.setFont(self.font)
    love.graphics.printf("Space Warrior",0,0,WINDOW_WIDTH,"center")
    love.graphics.setFont(self.font2)
    love.graphics.printf("PRESS ENTER TO PLAY",       0, 460, WINDOW_WIDTH, "center")
    love.graphics.printf("PRESS I FOR RULES",          0, 505, WINDOW_WIDTH, "center")
    love.graphics.printf("PRESS K FOR KEY BINDINGS",   0, 550, WINDOW_WIDTH, "center")
    love.graphics.printf("PRESS L FOR LAN GAME",       0, 595, WINDOW_WIDTH, "center")
    love.graphics.printf("F11 TOGGLE FULLSCREEN",      0, 640, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.printf("PRESS Q TO QUIT",            0, 685, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)

end
