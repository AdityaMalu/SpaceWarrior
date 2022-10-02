
powersuplier = Class{}
function powersuplier:init(x1,y1,height,width)
    self.dabba = {}
    local box = world:newRectangleCollider(x1,y1,height,width)
    box:setCollisionClass("powersuplier")
    box.choice = 4
    table.insert(self.dabba,box)
    self.timer = 0
    
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
    for k,v in pairs(self.dabba) do
        if v:enter('player1') then
                self.choice =1
        end 
    end
end

function powersuplier:render()

end