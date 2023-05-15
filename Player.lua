
require 'modules.powersuplier'
Player = Class{}

function Player:init(x, y, radius, class)
    self.radius = radius
    self.collider = world:newCircleCollider(x, y, radius)
    self.angle = 0
    self.collider:setCollisionClass(class)
    self.speed = 400
    self.class = class
    self.coverbullettimer = 2
    self.totalbullets = 3
    self.bulletrecoverytimer = 0
    self.font = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",12)
    self.bulletimage =  love.graphics.newImage('assets/Bullet 5x5.png')
    self.bulletangle = 0
    self.setrotation = 0

end

function Player:update(dt)
    if self.collider.body then
        if self.collider:enter('powersuplier')then
            local collisiondata = self.collider:getEnterCollisionData('powersuplier')
            if self.setrotation ==0 then
                self.setrotation = 1
            elseif self.setrotation == 1 then
                self.setrotation = 0
            end
        end
        if self.class == 'player1' then
            if love.keyboard.isDown('a') then
                if self.setrotation == 0 then
                    self.angle = self.angle - 4 * dt
                elseif self.setrotation == 1 then
                    self.angle = self.angle + 4 * dt
                end
                
            end   
            self.bulletangle = self.bulletangle + 4*dt
        end

        if self.class == 'player2' then
            if love.keyboard.isDown('j') then
                if self.setrotation == 0 then
                    self.angle = self.angle + 4 * dt
                elseif self.setrotation == 1 then
                    self.angle = self.angle - 4 * dt
                end
            end
            self.bulletangle = self.bulletangle + 4*dt
        end
        
        self.collider:setX(self.collider:getX() + math.cos(self.angle) * 350 * dt)
        self.collider:setY(self.collider:getY() + math.sin(self.angle) * 350 * dt)

        if self.collider:getX() <= self.radius then
            self.collider:setX(self.radius)
        end
        if self.collider:getX() >= WINDOW_WIDTH - self.radius then
            self.collider:setX(WINDOW_WIDTH - self.radius)
        end
        if self.collider:getY() <= self.radius then
            self.collider:setY(self.radius)
        end
        if self.collider:getY() >= WINDOW_HEIGHT - self.radius then
            self.collider:setY(WINDOW_HEIGHT - self.radius)
        end
    end

    if self.totalbullets <3 then
        self.bulletrecoverytimer = self.bulletrecoverytimer +dt
    end
    
    if self.bulletrecoverytimer>2 then
        self.totalbullets = math.min(self.totalbullets+1,3)
        self.bulletrecoverytimer = 0
    end
end

function Player:activateUltimate()
    if self.ultimate == 0 then
        self.timePositions = {}
        for i=1, 5 do
            table.insert(self.timePositions, {x= self.x, y=self.y, angle=self.angle})
        end
    end
end

function Player:move(dt)
    local friction = 0.7
    self.rotation = 2*math.pi*dt
    if(love.keyboard.isDown("w"))then
        self.angle=self.angle+self.rotation
    end
    if(love.keyboard.isDown("up"))then
        self.angle=self.angle-self.rotation
    end
    if(love.keyboard.isDown("s"))then
        self:activateUltimate()
        self.ultimate = 1
    end
    if(love.keyboard.isDown("q"))then
        self.thrusting=true
    else
        self.thrusting = false
    end
    if self.thrusting and self.xVel + self.yVel < 50 then
        self.thrust.x = self.thrust.x + self.thrust.speed * math.cos(self.angle)* dt
        self.thrust.y = self.thrust.y - self.thrust.speed * math.sin(self.angle)*dt
    elseif (self.thrust.x ~= 0 or self.thrust.y ~=0) then
        self.thrust.x = self.thrust.x - friction*self.thrust.x*dt
        self.thrust.y = self.thrust.y - friction*self.thrust.y*dt
    end
    if self.slow then
        self.x = self.x+0.5*self.thrust.x
        self.y=self.y+0.5*self.thrust.y
    else
        self.x = self.x+self.thrust.x
        self.y=self.y+self.thrust.y
    end

    --have to multiply by dt here
    if (self.x + self.radius < 0)then
        self.x = love.graphics.getWidth() + self.radius
    end
    if(self.x - self.radius > love.graphics.getWidth()) then
        self.x=0-self.radius
    end
    if(self.y+self.radius<0)then
        self.y = love.graphics.getHeight()+self.radius
    end
    if(self.y - self.radius > love.graphics.getHeight())then
        self.y = -self.radius
    end
end

function Player:takeDamage(d)
    d=d or 10
    self.health.current = self.health.current - d
    sounds.blip:play()
end

function Player:teleport(x, y)
    self.x  = x
    self.y = y
end

function Player:render()
    if self.collider.body then
        --love.graphics.print(self.setrotation,200,200)
        --love.graphics.draw(self.arrowimage,self.collider:getX(), self.collider:getY(),self.angle)
        --love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.angle) * 10, self.collider:getY() + math.sin(self.angle) * 10)
        -- love.graphics.circle("fill",self.collider:getX()+30,self.collider:getY()+30,3)
        -- love.graphics.circle("fill",self.collider:getX()-30,self.collider:getY()+30,3)
        -- love.graphics.circle("fill",self.collider:getX(),self.collider:getY()-39,3)

        --love.graphics.circle("line",self.collider:getX(),self.collider:getY(),40)
        
        if self.totalbullets == 3 then
            love.graphics.draw(self.bulletimage,self.collider:getX()+40*math.cos(self.bulletangle+360),self.collider:getY()+40*math.sin(self.bulletangle+360))
            love.graphics.draw(self.bulletimage,self.collider:getX()+40*math.cos(self.bulletangle),self.collider:getY()+40*math.sin(self.bulletangle))
            love.graphics.draw(self.bulletimage,self.collider:getX()+40*math.cos(self.bulletangle-360),self.collider:getY()+40*math.sin(self.bulletangle-360))
            -- love.graphics.circle("fill",self.collider:getX()+40*math.cos(self.bulletangle+360),self.collider:getY()+40*math.sin(self.bulletangle+360),3)
            -- love.graphics.circle("fill",self.collider:getX()+40*math.cos(self.bulletangle),self.collider:getY()+40*math.sin(self.bulletangle),3)
            -- love.graphics.circle("fill",self.collider:getX()+40*math.cos(self.bulletangle-360),self.collider:getY()+40*math.sin(self.bulletangle-360),3)
            -- love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.bulletangle-360) * 40, self.collider:getY() + math.sin(self.bulletangle-360) * 40)
            -- love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.bulletangle) * 40, self.collider:getY() + math.sin(self.bulletangle) * 40)
            -- love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.bulletangle+360) * 40, self.collider:getY() + math.sin(self.bulletangle+360) * 40)
        elseif self.totalbullets ==2 then
            love.graphics.draw(self.bulletimage,self.collider:getX()+40*math.cos(self.bulletangle+360),self.collider:getY()+40*math.sin(self.bulletangle+360))
            love.graphics.draw(self.bulletimage,self.collider:getX()+40*math.cos(self.bulletangle),self.collider:getY()+40*math.sin(self.bulletangle))
            -- love.graphics.circle("fill",self.collider:getX()+40*math.cos(self.bulletangle+360),self.collider:getY()+40*math.sin(self.bulletangle+360),3)
            -- love.graphics.circle("fill",self.collider:getX()+40*math.cos(self.bulletangle),self.collider:getY()+40*math.sin(self.bulletangle),3)
            -- love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.bulletangle-360) * 40, self.collider:getY() + math.sin(self.bulletangle-360) * 40)
            -- love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.bulletangle) * 40, self.collider:getY() + math.sin(self.bulletangle) * 40)
        elseif self.totalbullets ==1 then
            love.graphics.draw(self.bulletimage,self.collider:getX()+40*math.cos(self.bulletangle),self.collider:getY()+40*math.sin(self.bulletangle))
            --love.graphics.circle("fill",self.collider:getX()+40*math.cos(self.bulletangle),self.collider:getY()+40*math.sin(self.bulletangle),3)
            --love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.bulletangle) * 40, self.collider:getY() + math.sin(self.bulletangle) * 40)
        end
    end
    love.graphics.setFont(self.font)
    --love.graphics.print(self.totalbullets,self.collider:getX(),self.collider:getY())
end