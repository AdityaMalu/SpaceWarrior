Bullet1=Class{}

require 'States.Player2'

function Bullet1:init(x,y,width,height, target)
  self.Bullet_body=world:newRectangleCollider(x,y,width,height)
  self.Bullet_body:setCollisionClass('Bullet1')
  self.speed=250
  self.target = target
  self.timer = 0
end

-- function Bullet1:keypressed(key)
--   if key == 'space' then
--
-- end

function Bullet1:update(dt)
    if self.Bullet_body.body then
      local slope=math.atan2(self.Bullet_body:getY()-self.target.player2_body:getY(),self.Bullet_body:getX()-self.target.player2_body:getX())
      self.Bullet_body:setX(self.Bullet_body:getX()-math.cos(slope)*200*dt)
      self.Bullet_body:setY(self.Bullet_body:getY()-math.sin(slope)*200*dt)
    end

  self.timer = self.timer + dt

  if (self.timer > 5) then
    if self.Bullet_body.body then
    self.Bullet_body:destroy()
  end
  end
end

function Bullet1:render()
end
