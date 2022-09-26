PlayState = Class{__includes = BaseState}

require 'modules.Player'
require 'modules.powerups'
require 'modules.bullets'
require 'modules.powersuplier'
math.randomseed(os.time())

function PlayState:init()
    self.player1 = Player(40, WINDOW_HEIGHT-40, 30, 'player1')
    self.player2 = Player(WINDOW_WIDTH -40, 40, 30, 'player2')
    self.Powersuplier = {}
    self.player1Lasers = {}
    self.player2Lasers = {}
    self.player1Bomb = {}
    self.player2Bomb = {}
    self.player1ScatterShot = {}
    self.player2ScatterShot = {}
    self.Player1allBullet = {}
    self.Player2allBullet = {}
    self.timer = 0
    count = 0
    count1 = 0
    -- self.rectangle1 = world:newRectangleCollider(300, 100, 100, 100)
    -- self.rectangle1:setType('static')
    -- self.rectangle2 = world:newRectangleCollider(700, 100, 100, 100)
    -- self.rectangle2:setType('static')

    -- self.rectangle3 = world:newRectangleCollider(300, 500, 100, 100)
    -- self.rectangle3:setType('static')

    -- self.rectangle4 = world:newRectangleCollider(700, 500, 100, 100)
    -- self.rectangle4:setType('static')
end

function PlayState:shootBullet(shotBy)
    -- if shotBy == "player1" then
    --     table.insert(self.Player1allBullet,bullets(self.player1.collider:getX(),self.player1.collider:getY(),math.cos(self.player1.angle)*40000 , math.sin(self.player1.angle)*40000 ,'player1'))
    -- elseif shotBy == "player2" then
    --     table.insert(self.Player2allBullet,bullets(self.player2.collider:getX(),self.player2.collider:getY(),math.cos(self.player2.angle)*40000 , math.sin(self.player2.angle)*40000 ,'player2'))
    -- end
    if self.player1.collider.body then
        if shotBy == "player1" and self.player1.totalbullets>0 then
            self.player1.totalbullets = self.player1.totalbullets -1
                table.insert(self.Player1allBullet,bullets(self.player1.collider:getX(),self.player1.collider:getY(),math.cos(self.player1.angle)+ self.player1.collider:getX() , math.sin(self.player1.angle)+self.player1.collider:getY() ,'player1'))
        end
    end

    if self.player2.collider.body then
        if shotBy == "player2"  and self.player2.totalbullets>0 then
            self.player2.totalbullets = self.player2.totalbullets -1
                table.insert(self.Player2allBullet,bullets(self.player2.collider:getX(),self.player2.collider:getY(),math.cos(self.player2.angle)+self.player2.collider:getX() , math.sin(self.player2.angle)+self.player2.collider:getY() ,'player2'))
        end
    end


end

function PlayState:shootLaser(shotBy)
    if shotBy == 'player1' then
        table.insert(self.player1Lasers, Laser(self.player1.collider:getX(), self.player1.collider:getY(), math.cos(self.player1.angle) * 4000, math.sin(self.player1.angle) * 4000, 'player1'))
    elseif shotBy == 'player2' then
        table.insert(self.player2Lasers, Laser(self.player2.collider:getX(), self.player2.collider:getY(), math.cos(self.player2.angle) * 4000, math.sin(self.player2.angle) * 4000, 'player2'))
    end
end

function PlayState:plantBomb(shotBy)
    if shotBy == 'player1' then
        table.insert(self.player1Bomb, Bomb(self.player1.collider:getX(), self.player1.collider:getY(), 'player1'))
    elseif shotBy == 'player2' then
        table.insert(self.player2Bomb, Bomb(self.player2.collider:getX(), self.player2.collider:getY(), 'player2'))
    end
end

function PlayState:shootScatterShot(shotBy)
    if shotBy == 'player1' then
        table.insert(self.player1ScatterShot, ScatterShot(self.player1.collider:getX(), self.player1.collider:getY(), 'player1'))
    end
    if shotBy == 'player2' then
        table.insert(self.player2ScatterShot,ScatterShot(self.player2.collider:getX(), self.player2.collider:getY(), 'player2'))
    end
end

function PlayState:dabbaplant()
    table.insert(self.Powersuplier,powersuplier(math.random(200,400),math.random(200,400),30,30,'powersuplier'))
end

function PlayState:update(dt)

    if self.player1.collider.body and self.player2.collider.body then
        self.timer = self.timer +dt
        if self.player1.collider.body then
            self.player1:update(dt)
        end
        if self.player2.collider.body then
            self.player2:update(dt)
        end

        if self.player1.collider:enter ("powersuplier") then
            local collision_data = self.player1.collider:getEnterCollisionData('powersuplier')
            -- print(collision_data.collider.choice)
            collision_data.collider:destroy()
        end

        if self.player2.collider:enter ("powersuplier") then
            local collision_data = self.player2.collider:getEnterCollisionData('powersuplier')
            -- print(collision_data.collider.choice)
            collision_data.collider:destroy()
        end

        for key,box in pairs(self.Powersuplier) do
            box:update(dt)

        end

        if self.player1.collider.body then
            for key, laser in pairs(self.player1Lasers) do
                if laser.laser.body then
                    laser:update(dt)
                end
            end
        end

        if self.player2.collider.body then
            for key, laser in pairs(self.player2Lasers) do
                if laser.laser.body then
                    laser:update(dt)
                end
            end
        end
        if self.player2.collider.body then
            for key, bomb in pairs(self.player1Bomb) do
                if bomb.collider.body then
                    bomb:update(dt, self.player2)
                end
            end
        end

        if self.player1.collider.body then
            for key, bomb in pairs(self.player2Bomb) do
                if bomb.collider.body then
                    bomb:update(dt, self.player1)
                end
            end
        end
        if self.player1.collider.body then
            for key, value in pairs(self.player1ScatterShot) do
                value:update(dt)
            end
        end

        if self.player2.collider.body then
            for key, value in pairs(self.player2ScatterShot) do
                value:update(dt)
            end
        end

        if self.player1.collider.body then
            for key , value in pairs(self.Player1allBullet) do
                value:update(dt)
            end
        end
        if self.player2.collider.body then
            for key,value in pairs(self.Player2allBullet) do
                value:update(dt)
            end
        end

        if self.timer > 3 then
            self:dabbaplant()
            self.timer = 0
        end
    else

      if self.player2.collider.body then
      else
        count = count + 1
        gStateMachine:change("score")
      end

      if self.player1.collider.body then
      else
        count1 = count1 + 1
        gStateMachine:change("score")
      end

    end





end

-- function PlayState:count()
--
--   if self.player1.collider.body and self.player2.collider.body then
--   else
--     if self.player1.collider.body then
--       self.count = self.count + 1
--     end
--   end
--
-- end


function PlayState:keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
    if key == 'z' then
        if powersuplier.choice==1 then
          self:shootLaser('player1')
        end
    end
    -- for the laser shooting

    if key == 'p' then
        self:shootLaser('player2')
    end

    -- for the bomb shooting
    if key == 'b' then
        self:plantBomb('player1')
    end
    if key == 'm' then
        self:plantBomb('player2')
    end

    -- for the scatter shot shooting
    if key == 's' then
        self:shootScatterShot('player1')
    end

    if key  == 't' then
        self:shootScatterShot('player2')
    end

    if key == 'e' then
        self:shootBullet('player1')

    end

    if key =='k' then
        self:shootBullet('player2')
    end
end

function PlayState:render()
    if self.player1.collider.body then
        self.player1:render()
    end
    if self.player2.collider.body then
        self.player2:render()
    end

    for key, value in pairs(self.player1Lasers) do
        value:render()
    end

    for key, value in pairs(self.Player1allBullet) do
        value:render()
    end

    love.graphics.print(count)
    love.graphics.print(count1,0,50)

    -- for key, value in pairs(self.Player2allBullet) do
    --     value:render()
    -- end

    -- if self.player1.destroy or self.player2.destroy then
    --     love.graphics.print("Game Ended",100,100)
    -- end
end
