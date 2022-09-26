EndState = Class{__includes = BaseState}

require 'states.PlayState'

function EndState:init()
    self.background = love.graphics.newImage("assets/BG.png")
    self.font = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",30)
    --self.Animation:startNewTypingAnimation("GAME END",5)
    self.count = count
    self.count1 = count1
end

function EndState:update(dt)
    --self.Animation:update(dt)
    if(love.keyboard.isDown("return")) then
        gStateMachine:change("play")
    end
  end

function EndState:render()
    love.graphics.draw(self.background,0,0,0,WINDOW_WIDTH/self.background:getWidth(),WINDOW_HEIGHT/self.background:getHeight())
    love.graphics.setFont(self.font)
    --Animation:draw(400,100)
    love.graphics.printf("GAME",0,100,WINDOW_WIDTH,"center")
    love.graphics.printf("END",0,150,WINDOW_WIDTH,"center")
    love.graphics.printf("PRESS ENTER TO PLAY AGAIN",0,450,WINDOW_WIDTH,"center")
    love.graphics.printf("PRESS ESC TO EXIT",0,600,WINDOW_WIDTH,"center")
    love.graphics.print(self.count,0,0)
    love.graphics.print(self.count1,0,50)


end
