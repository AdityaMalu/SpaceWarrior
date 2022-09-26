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

end

function Player:update(dt)
    if self.collider.body then
        if self.class == 'player1' then
            if love.keyboard.isDown('q') then
                self.angle = self.angle + 4 * dt
            end
        end

        if self.class == 'player2' then
            if love.keyboard.isDown('o') then
                self.angle = (self.angle + 4 * dt)
            end
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
        love.graphics.line(self.collider:getX(), self.collider:getY(), self.collider:getX() + math.cos(self.angle) * 10, self.collider:getY() + math.sin(self.angle) * 10)
    end
    love.graphics.setFont(self.font)
    love.graphics.print(self.totalbullets,self.collider:getX(),self.collider:getY())
end