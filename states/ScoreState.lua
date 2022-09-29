ScoreState = Class{__includes = BaseState}

require 'modules.Player'
require 'states.PlayState'

function ScoreState:init()
  self.font = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",30)
  self.player1 = Player(500,650,30,'player1')
  self.player2 = Player(700,650,30,'player2')
  self.i = 1

end

function ScoreState:enter(count1)
  self.Count1 = count1
end


function ScoreState:update(dt)
  if love.keyboard.isDown("return") then
    gStateMachine:change("play")
  end

  if self.Count1 == 1 then
    self.player1.collider.body:setX(self.player1.collider.body:getX())
    self.player1.collider.body:setY(math.min(self.player1.collider.body:getY(),550))
  end

  if self.Count1 == 2 then
    self.player1.collider.body:setX(self.player1.collider.body:getX())
    self.player1.collider.body:setY(math.min(450,self.player1.collider.body:getY()))
  end

  if self.Count1 == 3 then
    self.player1.collider.body:setX(self.player1.collider.body:getX())
    self.player1.collider.body:setY(math.min(350,self.player1.collider.body:getY()))
  end

  if self.Count1 == 4 then
    self.player1.collider.body:setX(self.player1.collider.body:getX())
    self.player1.collider.body:setY(math.min(250,self.player1.collider.body:getY()))
  end

  if self.Count1 == 5 then
    self.player1.collider.body:setX(self.player1.collider.body:getX())
    self.player1.collider.body:setY(math.min(150,self.player1.collider.body:getY()))
  end


  -- for i=1,4,1 do
  --   if self.Count1 ~= i then
  --       break
  --   else
  --     self.player1.collider.body:setX(self.player1.collider.body:getX())
  --     self.player1.collider.body:setY(self.player1.collider.body:getY()-100*i*dt)
  --     --gStateMachine:change("play")
  --   end
  -- end

  if self.Count1 >5 then
    gStateMachine:change("end")
  end


end



function ScoreState:render()
  love.graphics.print(self.Count1,0,0)
  love.graphics.print(count2,0,50)
  love.graphics.line(400,100, 800,100)
  love.graphics.line(600,100,600,600)
  love.graphics.line(400,100,400,600)
  love.graphics.line(800,100,800,600)
  love.graphics.line(400,600,800,600)
  love.graphics.line(400,500,800,500)
  love.graphics.line(400,400,800,400)
  love.graphics.line(400,300,800,300)
  love.graphics.line(400,200,800,200)
  love.graphics.setFont(self.font)
  love.graphics.print("Player 1",420,50)
  love.graphics.print("Player 2",620,50)
  self.player1:render()
  self.player2:render()


  if self.Count1 == 1 then
    love.graphics.print("1",490,120)
  end

end
