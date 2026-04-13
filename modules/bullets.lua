bullets = Class{}

-- ownerId: numeric player ID (1, 2, 3 …)
function bullets:init(x1, y1, x2, y2, ownerId)
    self.counter = 3
    self.timer   = 0
    self.shoots  = {}
    self.ownerId = ownerId
    local b = world:newCircleCollider(x1, y1, 5)
    b.angle = math.atan2((y2 - y1), (x2 - x1))
    b:setCollisionClass('bullets'..ownerId..'P')
    if #b <= 3 then
        table.insert(self.shoots, b)
    end
    self.newImage = love.graphics.newImage("assets/Bullet 5x5.png")
end

function bullets:update(dt)
    self.timer = self.timer + dt

    -- Build target classes dynamically: hit every player except the owner
    local targets = {}
    for i = 1, MAX_PLAYERS do
        if i ~= self.ownerId then
            table.insert(targets, 'player'..i)
        end
    end

    for _, v in pairs(self.shoots) do
        if v.body then
            for key, shoot in pairs(self.shoots) do
                shoot:setX(shoot:getX() + math.cos(shoot.angle) * 600 * dt)
                shoot:setY(shoot:getY() + math.sin(shoot.angle) * 600 * dt)

                local hits = world:queryCircleArea(shoot:getX(), shoot:getY(), 3, targets)
                for _, collider in pairs(hits) do
                    collider:destroy()
                end

                if shoot:getX() < 0 or shoot:getX() > WINDOW_WIDTH then
                    shoot:destroy()
                    table.remove(self.shoots, key)
                end
                if shoot.body then
                    if shoot:getY() < 0 or shoot:getY() > WINDOW_HEIGHT then
                        shoot:destroy()
                        table.remove(self.shoots, key)
                    end
                end
            end
            for _, sv in pairs(self.shoots) do
                if self.timer > 3 then
                    local nb = world:newCircleCollider(sv:getX(), sv:getY(), 5)
                    table.insert(self.shoots, nb)
                    self.timer = 0
                end
            end
        end
    end
end

function bullets:render()
    for _, v in pairs(self.shoots) do
        if v.body then
            love.graphics.draw(self.newImage, v:getX()-3, v:getY()-3, 0, 1.7, 1.7)
        end
    end
end