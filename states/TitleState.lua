TitleState = Class{__includes = BaseState}

function TitleState:init()
    self.background = love.graphics.newImage("assets/BG.png")
    self.font = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",60)
    self.font2 = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",30)
end

function TitleState:update()
    if(love.keyboard.isDown("return")) then
        gStateMachine:change("play")
    end
end

-- function love.keypressed(key)
--     if(key== "return") then
--         gStateMachine:change("play")
--     end
-- end

function TitleState:render()
    love.graphics.draw(self.background,0,0,0,WINDOW_WIDTH/self.background:getWidth(),WINDOW_HEIGHT/self.background:getHeight())
    love.graphics.setFont(self.font)
    love.graphics.printf("ASTRO PARTY",0,0,WINDOW_WIDTH,"center")
    love.graphics.setFont(self.font2)
    love.graphics.printf("PRESS ENTER TO PLAY",0,500,WINDOW_WIDTH,"center")

end
