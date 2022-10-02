bullets = Class{}

function bullets:init(x1,y1,x2,y2,shotBy)
    self.counter = 3
    self.timer  = 0
    self.shoots = {}
    self.shotBy = shotBy
        local b = world:newCircleCollider(x1,y1,5)
        b.angle = math.atan2((y2-y1),(x2-x1))
        if shotBy == 'player1' then
            b:setCollisionClass('bullets1P')
        end

        if shotBy == 'player2' then
            b:setCollisionClass('bullets2P')
        end
    if #b<=3 then
        table.insert(self.shoots,b)
    end
    self.newImage = love.graphics.newImage("assets/Bullet 5x5.png")
end

function bullets:update(dt)

        self.timer = self.timer +dt      
                    for key , shoot in pairs(self.shoots) do
                        shoot:setX(shoot:getX() + math.cos(shoot.angle) * 600 * dt)
                        shoot:setY(shoot:getY() + math.sin(shoot.angle) * 600 * dt)
                        if self.shotBy == 'player1' then
                            local b = world:queryCircleArea(shoot:getX(), shoot:getY(),3,{'player2'})
                            if #b>0 then 
                                for key, collider in pairs(b) do
                                    collider:destroy()
                                end
                            end
                        end

                        if self.shotBy == 'player2' then
                            local b = world:queryCircleArea(shoot:getX(), shoot:getY(),3,{'player1'})
                            if #b>0 then 
                                for key, collider in pairs(b) do
                                    collider:destroy()
                                end
                            end
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
                    for k,v in pairs(self.shoots) do
                        if self.timer>3 then
                            local b = world:newCircleCollider(v:getX(),v:getY(),5)
                            table.insert(self.shoots,b)
                            self.timer = 0
                        end 
                    end

end

function bullets:render()
        love.graphics.draw(self.newImage)
end