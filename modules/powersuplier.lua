
powersuplier = Class{}
function powersuplier:init(x1,y1,height,width)
    self.dabba = {}
    local box = world:newRectangleCollider(x1,y1,height,width)
    box:setCollisionClass("powersuplier")
    box.choice = math.random(0, 4)
    --box.choice = 2
    table.insert(self.dabba,box)
    self.timer = 0
    self.image = love.graphics.newImage("assets/powersupplier.png")
end

function powersuplier:update(dt)
    self.timer = self.timer + dt
        -- for k,v in pairs(self.dabba) do
        --     if v:enter('player1')then
        --         v:destroy()
        --     end
        --     if v:enter('player2')then
        --         v:destroy()
        --     end
        -- end
    
end

function powersuplier:enter()

end



function powersuplier:render()
    for k,v in pairs(self.dabba)do
        if v.body then
            love.graphics.draw(self.image,v:getX()-17,v:getY()-19,0,0.3,0.3)
        end
    end
end