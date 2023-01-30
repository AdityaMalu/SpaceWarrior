EndState = Class{__includes = BaseState}

require 'states.PlayState'

function EndState:init()
    self.background = love.graphics.newImage("assets/BG.png")
    self.font = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",30)
    --self.Animation:startNewTypingAnimation("GAME END",5)
    self.sounds = love.audio.newSource("assets/Sounds/Victory Tune.ogg","static")
    self.sounds:setVolume(0.5)
    self.sounds:setLooping(true)
    self.sounds:play()
end

function EndState:update(dt)
    --self.Animation:update(dt)
    if(love.keyboard.isDown("return")) then
        gStateMachine:change("play")
    end

    if love.keyboard.isDown("return")then
        PLAYER1_SCORE = 0
         PLAYER2_SCORE = 0
    end

   
end

function  EndState:exit()
    self.sounds:stop()
end

  

function EndState:render()
    
    love.graphics.draw(self.background,0,0,0,WINDOW_WIDTH/self.background:getWidth(),WINDOW_HEIGHT/self.background:getHeight())
    love.graphics.setFont(self.font)
    if PLAYER1_SCORE ==6 then
        love.graphics.setColor(0,1,0)
        love.graphics.printf("Player 1 is the Winner!!",0,300,WINDOW_WIDTH,"center")
    end

    if PLAYER2_SCORE ==6 then
        love.graphics.setColor(0,1,0)
        love.graphics.printf("Player 2 is the Winner!!",0,300,WINDOW_WIDTH,"center")
    end

    love.graphics.setColor(1,1,1)
    --Animation:draw(400,100)
    love.graphics.printf("GAME",0,100,WINDOW_WIDTH,"center")
    love.graphics.printf("END",0,150,WINDOW_WIDTH,"center")
    love.graphics.printf("PRESS ENTER TO PLAY AGAIN",0,450,WINDOW_WIDTH,"center")
    love.graphics.printf("PRESS ESC TO EXIT",0,600,WINDOW_WIDTH,"center")
end
