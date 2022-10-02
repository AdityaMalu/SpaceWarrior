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
    if(love.keyboard.isDown("return")) then
        gStateMachine:change("play")
    end

    if(love.keyboard.isDown("i")) then
        gStateMachine:change("intro")
    end
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
    love.graphics.printf("Space Warriors",0,0,WINDOW_WIDTH,"center")
    love.graphics.setFont(self.font2)
    love.graphics.printf("PRESS ENTER TO PLAY",0,500,WINDOW_WIDTH,"center")
    love.graphics.printf("PRESS I TO SEE THE RULES",0,550,WINDOW_WIDTH,"center")

end
