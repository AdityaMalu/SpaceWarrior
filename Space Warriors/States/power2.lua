Reverse = Class{}


function Reverse:init(rotation,x,y,width,height)
    self.rotation = rotation
    self.x  = x
    self.y = y
    self.width = width
    self.height = height
    self.reverse_body = world:newRectangleCollider(x,y,width,height)
    self.reverse_body:setCollisionClass('reverseall')
end

function Reverse:update(dt)

end

function Reverse:render()

end
