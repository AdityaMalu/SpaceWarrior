
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
    self.arrowimage = love.graphics.newImage("assets/line.png")
    self.bulletangle = 0

end

function Player:update(dt)
    if self.collider.body then
        if self.class == 'player1' then
            if love.keyboard.isDown('a') then
                self.angle = self.angle - 4 * dt
            end

            if self.collider:enter ("powersuplier") then
                local collision_data = self.collider:getEnterCollisionData('powersuplier')
                if collision_data.collider.choice ==4 then
                    self.angle = self.angle +4*dt
                end
            end

            self.bulletangle = self.bulletangle + 4*dt
        end

        if self.class == 'player2' then
            if love.keyboard.isDown('j') then
                self.angle = (self.angle + 4 * dt)
            end

            self.bulletangle = self.bulletangle + 4*dt
        end
        
        self.collider:setX(self.collider:getX() + math.cos(self.angle) * 200 * dt)
        self.collider:setY(self.collider:getY() + math.sin(self.angle) * 200 * dt)

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

function Player:render()
    if self.collider.body then
        
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