Maps = Class{}

function Maps:init(x,y,width,height,corner)
    self.collider = world:newBSGRectangleCollider(x,y,width,height,corner)
    self.collider:setCollisionClass('maps')
    self.collider:setType("Static")
end

function Maps:render()
    
end