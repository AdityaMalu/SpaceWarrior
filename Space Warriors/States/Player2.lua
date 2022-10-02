Player2=Class{}

function Player2:init(x,y,width,height)
  self.player2_body=world:newRectangleCollider(x,y,width,height)
  self.player2_body:setCollisionClass('player2')
  self.player2_speed=200
end

function Player2:update(dt)
    if self.player2_body.body then
        if love.keyboard.isDown('up') then
            self.player2_body:setY(self.player2_body:getY() - self.player2_speed * dt)
        end
        if love.keyboard.isDown('down') then
            self.player2_body:setY(self.player2_body:getY() + self.player2_speed * dt)
        end
        if love.keyboard.isDown('left') then
            self.player2_body:setX(self.player2_body:getX() - self.player2_speed * dt)
        end
        if love.keyboard.isDown('right') then
            self.player2_body:setX(self.player2_body:getX() + self.player2_speed * dt)
        end
    end
    
end

function Player2:render()
end
