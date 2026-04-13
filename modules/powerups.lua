-- Helper: build list of all player collision classes except the given owner ID
local function otherPlayers(ownerId)
    local t = {}
    for i = 1, MAX_PLAYERS do
        if i ~= ownerId then
            table.insert(t, 'player'..i)
        end
    end
    return t
end

Laser = Class{}

-- ownerId: numeric player ID (1, 2, 3 …)
function Laser:init(x1, y1, x2, y2, ownerId)
    self.x1      = x1
    self.y1      = y1
    self.x2      = x2
    self.y2      = y2
    self.timer   = 0
    self.ownerId = ownerId
    self.laser   = world:newLineCollider(x1, y1, x2, y2)
    self.laser:setCollisionClass('laser'..ownerId..'P')
    self.laser_photo = love.graphics.newImage('assets/laser.jpg')
end

function Laser:update(dt)
    self.timer = self.timer + dt
    if self.timer > 0.2 then
        self.laser:destroy()
    end
    local targets = otherPlayers(self.ownerId)
    local hits = world:queryLine(self.x1, self.y1, self.x2, self.y2, targets)
    for _, value in pairs(hits) do
        value:destroy()
    end
end

function Laser:render()
    if self.laser.body then
        love.graphics.draw(self.laser_photo, self.x1, self.y1, math.atan2(self.y2 - self.y1, self.x2 - self.x1), 100, 0.1)
    end
end

Bomb = Class{}

-- ownerId: numeric player ID (1, 2, 3 …)
function Bomb:init(x, y, ownerId)
    self.x       = x
    self.y       = y
    self.width   = 10
    self.height  = 10
    self.ownerId = ownerId
    self.collider = world:newRectangleCollider(x, y, self.width, self.height)
    self.growingradius = 1
    self.collider:setCollisionClass('Bomb'..ownerId..'P')
end

function Bomb:update(dt)
    local targets = otherPlayers(self.ownerId)
    local q = world:queryCircleArea(self.x, self.y, 200, targets)
    for _, collider in pairs(q) do
        if collider.body then
            if self.growingradius < 200 then
                self.growingradius = self.growingradius + dt
            end
            collider:destroy()
        end
    end
end

function Bomb:render()
    love.graphics.setColor(0,1,1,0.5)
    love.graphics.circle("fill",self.x,self.y, self.growingradius)
    love.graphics.setColor(1,1,1,1)
end

ScatterShot = Class{}

-- ownerId: numeric player ID (1, 2, 3 …)
function ScatterShot:init(x1, y1, ownerId)
    self.shots   = {}
    self.ownerId = ownerId
    self.image   = love.graphics.newImage("assets/Bullet 5x5.png")
    for angle = 0, 6.27, 0.314 do
        local b = world:newCircleCollider(x1, y1, 5)
        b.angle = angle
        b:setCollisionClass('ScatterShot'..ownerId..'P')
        table.insert(self.shots, b)
    end
end

function ScatterShot:update(dt)
    local targets = otherPlayers(self.ownerId)
    for key, shot in pairs(self.shots) do
        if shot.body then
            shot:setX(shot:getX() + math.cos(shot.angle) * 300 * dt)
            shot:setY(shot:getY() + math.sin(shot.angle) * 300 * dt)

            local hits = world:queryCircleArea(shot:getX(), shot:getY(), 3, targets)
            for _, collider in pairs(hits) do
                if collider.body then
                    collider:destroy()
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
end

function ScatterShot:render()
    for _, v in pairs(self.shots) do
        if v.body then
            love.graphics.draw(self.image, v:getX(), v:getY())
        end
    end

end


