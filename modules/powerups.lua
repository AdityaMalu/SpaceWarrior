Laser = Class{}

function Laser:init(x1, y1, x2, y2, shotBy)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2
    self.timer = 0
    self.shotBy = shotBy
    self.laser = world:newLineCollider(x1, y1, x2, y2)
    if shotBy == 'player1' then
        self.laser:setCollisionClass('laser1P')
    elseif shotBy == 'player2' then
        self.laser:setCollisionClass('laser2P')
    end
    self.laser_photo = love.graphics.newImage('assets/laser.jpg')
end

function Laser:update(dt)
    self.timer = self.timer + dt

    if self.timer > 0.2 then
        self.laser:destroy()
    end

    if self.shotBy == 'player1' then
        local collider_1 = world:queryLine(self.x1, self.y1, self.x2, self.y2, {'player2'})
        if #collider_1 > 0 then
            for key, value in pairs(collider_1) do
                value:destroy()
            end
        end
    elseif self.shotBy == 'player2' then
        local collider_1 = world:queryLine(self.x1, self.y1, self.x2, self.y2, {'player1'})
        if #collider_1 > 0 then
            for key, value in pairs(collider_1) do
                value:destroy()
            end
        end
    end
end

function Laser:render()
    if self.laser.body then
        love.graphics.draw(self.laser_photo, self.x1, self.y1, math.atan2(self.y2 - self.y1, self.x2 - self.x1), 100, 0.1)
    end
end

Bomb = Class{}

function Bomb:init(x, y, shotBy)
    self.x = x
    self.y = y
    self.width = 10
    self.height = 10
    self.shotBy = shotBy
    self.collider = world:newRectangleCollider(x, y, self.width, self.height)
    --self.collider:setCollisionClass(self.shotBy)
    if shotBy == 'player1' then
        self.collider:setCollisionClass('Bomb1P')
    elseif shotBy == 'player2' then
        self.collider:setCollisionClass('Bomb2P')
    end
end

function Bomb:checkDistance(player)
    local d = math.sqrt(math.pow(player.collider:getX() - self.x, 2) + math.pow(player.collider:getY() - self.y, 2))
    if d <= 200 then
        player.collider:destroy()
    end
end

function Bomb:update(dt, player)
    if self.shotBy == 'player1' then
        -- self:checkDistance(player)
        local q = world:queryCircleArea(self.x, self.y, 200, {'player2'})
        for key, collider in pairs(q) do
            collider:destroy()
        end
    elseif self.shotBy == 'player2' then
        --self:checkDistance(player)
        local q = world:queryCircleArea(self.x, self.y, 200, {'player1'})
        for key, collider in pairs(q) do
            collider:destroy()
        end
    end
end

ScatterShot = Class{}

function ScatterShot:init(x1,y1,shotBy)
    self.shots = {}
    self.shotBy = shotBy
    for angle = 0,6.27,  0.314 do
        local b = world:newCircleCollider(x1,y1,5)
        b.angle = angle
        if shotBy == 'player1' then
            b:setCollisionClass('ScatterShot1P')
        end

        if shotBy == 'player2' then
            b:setCollisionClass('ScatterShot1P')
        end

        table.insert(self.shots,b)
    end    
end

function ScatterShot:update(dt)
    for key , shot in pairs(self.shots) do
        shot:setX(shot:getX() + math.cos(shot.angle) * 300 * dt)
        shot:setY(shot:getY() + math.sin(shot.angle) * 300 * dt)
        if self.shotBy == 'player1' then
            local b = world:queryCircleArea(shot:getX(), shot:getY(),3,{'player2'})
            if #b>0 then 
                for key, collider in pairs(b) do
                    collider:destroy()
                end
            end
        end

        if self.shotBy == 'player2' then
            local b = world:queryCircleArea(shot:getX(), shot:getY(),3,{'player1'})
            if #b>0 then 
                for key, collider in pairs(b) do
                    collider:destroy()
                end
            end
        end

        if shot:getX() < 0 or shot:getX() > WINDOW_WIDTH then
            shot:destroy()
            table.remove(self.shots, key)
        end
        if shot.body then
            if shot:getY() < 0 or shot:getY() > WINDOW_HEIGHT then
                shot:destroy()
                table.remove(self.shots, key)
            end
        end
    end
end

function ScatterShot:render()

end