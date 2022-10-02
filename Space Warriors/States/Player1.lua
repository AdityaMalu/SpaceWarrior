Player1=Class{}

function Player1:init(x,y,radius)
  self.player1_body=world:newCircleCollider(x,y,radius)
  self.player1_body:setCollisionClass('player1')
  self.player1_speed=200
  self.angle = 0
end

function Player1:update(dt)
    if love.keyboard.isDown('up') then
        self.player1_body:setY(self.player1_body:getY() - self.player1_speed * dt)
    end
    if love.keyboard.isDown('down') then
        self.player1_body:setY(self.player1_body:getY() + self.player1_speed * dt)
    end
    if love.keyboard.isDown('left') then
        self.player1_body:setX(self.player1_body:getX() - self.player1_speed * dt)
    end
    if love.keyboard.isDown('right') then
        self.player1_body:setX(self.player1_body:getX() + self.player1_speed * dt)
    end
end

function Player1:render()
end
