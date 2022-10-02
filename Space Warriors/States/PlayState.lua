PlayState=Class{__includes=BaseState}

require'States/Player1'
require'States/Player2'
require 'States/bullet'
require 'States/power1'
--require 'States/power2'

function PlayState:init()
  self.player1=Player1(50,window_height/2,40)
  self.player2=Player2(window_width-50,window_height/2,100,100)
  --self.bullet1=bullet(setX(self.player1:getX()),setY(self.player1:getY())-5,20,10)
  self.bullet1 = Bullet1(self.player1.player1_body:getX(), self.player1.player1_body:getY(),20,10, self.player2)
  self.laser = Laser(self.player1.player1_body:getX(),self.player1.player1_body:getY(),self.player1.player1_body:getX(),self.player1.player1_body:getY())
  --self.reverse_body = Reverse(math.random(30,window_width-30),math.random(30,window_height-30),30,30)


  Bullet={}
  self.Lasers = {}
  Reverseall = {}
end

function PlayState:shootLaser(x1, y1, x2, y2)
  self.laser = Laser(x1, y1, x2, y2)
  table.insert(self.Lasers, self.laser)
end

function PlayState:keypressed(key)
  if key == 'space' then
    Bullet1(self.player1.player1_body:getX(), self.player1.player1_body:getY(),20,10, self.player2)
  end
  if key == 'l' then
    self:shootLaser(self.player1.player1_body:getX(), self.player1.player1_body:getY(), math.cos(self.player1.angle) * 5000, math.sin(self.player1.angle) * 5000)
  end
end

function PlayState:update(dt)
  self.player1:update(dt)
  self.player2:update(dt)
  self.bullet1:update(dt)

  if love.keyboard.isDown('r') then
    self.player1.angle = self.player1.angle + 3 * dt
  end

  for key, value in pairs(self.Lasers) do
    if value.laser.body then
      value:update(dt)
    end
    
  end
  -- if self.player1:enter "reverseall " then
  --   self.player1.angle = self.player1.angle*(-1)
  -- end

  -- self.laser:update(dt)
end

function PlayState:render()
  self.player1:render()
  self.player2:render()
  love.graphics.print(self.player1.angle)
  love.graphics.line(self.player1.player1_body:getX(), self.player1.player1_body:getY(), math.cos(self.player1.angle) * 10+ self.player1.player1_body:getX(), math.sin(self.player1.angle) * 10 + self.player1.player1_body:getY())
  -- self.laser:render()
  --self.reverse_body:render()
end
