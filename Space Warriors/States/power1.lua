Laser = Class{}

function Laser:init(x1, y1, x2, y2)
    self.laser = world:newLineCollider(x1, y1, x2, y2)
    self.x1 = x1
    self.y1 = y1
    self.x2 = x2
    self.y2 = y2
    self.timer = 0
    self.collision = false
end

function Laser:update(dt)
    self.timer = self.timer + dt

    if self.timer > 1 then
        self.laser:destroy()
    end

    -- if self.laser:enter('player2') then
    --     local collisionData = self.laser:getEnterCollisionData('player2')
    --     collisionData.collider:destroy()
    -- end
    local collider1 = world:queryLine(self.x1, self.y1, self.x2, self.y2, {'player2'})
    for key, value in pairs(collider1) do
        value:destroy()
    end

end