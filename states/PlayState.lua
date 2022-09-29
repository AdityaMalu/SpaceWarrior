PlayState = Class{__includes = BaseState}

require 'modules.Player'
require 'modules.powerups'
require 'modules.bullets'
require 'modules.powersuplier'
require 'modules.maps'
math.randomseed(os.time())

-- count1 = 0
-- count2 = 0
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
    self.whichpowerp1 = ""
    self.whichpowerp2 = ""
    self.background = love.graphics.newImage("assets/Background/b3.png")
    self.totalpowersuplier = 6
    self.mappart1 = Maps(300,150,50,175,5)
    self.mappart2 = Maps(125.,325,175,50,5)
    self.mappart3 = Maps(300,375,50,175,5)
    self.mappart4 = Maps(350,325,175,50,5)
    self.mappart5 = Maps(800,150,50,175,5)
    self.mappart6 = Maps(625.,325,175,50,5)
    self.mappart7 = Maps(800,375,50,175,5)
    self.mappart8 = Maps(850,325,175,50,5)
    self.sounds = love.audio.newSource("assets/Sounds/Space Heroes.ogg","static")
    self.sounds:setVolume(0.5)
    self.sounds:setLooping(true)
    self.sounds:play()
    --self.ScoreBoard = true
    -- self.rectangle1 = world:newRectangleCollider(300, 100, 100, 100)
    -- self.rectangle1:setType('static')
    -- self.rectangle2 = world:newRectangleCollider(700, 100, 100, 100)
    -- self.rectangle2:setType('static')

    -- self.rectangle3 = world:newRectangleCollider(300, 500, 100, 100)
    -- self.rectangle3:setType('static')

    -- self.rectangle4 = world:newRectangleCollider(700, 500, 100, 100)
    -- self.rectangle4:setType('static')


    self.hasGameEnded = false
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
        assert(self.player1.collider.body, "player1 body does not exist")
        table.insert(self.player1Lasers, Laser(self.player1.collider:getX(), self.player1.collider:getY(), math.cos(self.player1.angle) * 4000, math.sin(self.player1.angle) * 4000, 'player1'))
    elseif shotBy == 'player2' then
        assert(self.player2.collider.body, "player 2 body not found")
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
    
    self.totalpowersuplier = self.totalpowersuplier -1
    if self.totalpowersuplier <6 and self.totalpowersuplier>0 then
        table.insert(self.Powersuplier,powersuplier(math.random(100,1100),math.random(100,600),30,30,'powersuplier'))
    end 
    
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

        if self.player1.collider.body then
            if self.player1.collider:enter ("powersuplier") then
                local collision_data = self.player1.collider:getEnterCollisionData('powersuplier')
                -- print(collision_data.collider.choice)
                collision_data.collider:destroy()
            end
        end

        if self.player2.collider.body then
            if self.player2.collider:enter ("powersuplier") then
                local collision_data = self.player2.collider:getEnterCollisionData('powersuplier')
                -- print(collision_data.collider.choice)
                collision_data.collider:destroy()
            end
        end
        


        -- for key,box in pairs(self.Powersuplier) do
        --     --box:update(dt)
        --
        -- end

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

        if self.timer > 10 then
            self:dabbaplant()
            self.timer = 0
        end

        
    else
    --   if self.player1.collider.body then
    --     count1 = count1 +1
    --     gStateMachine:change("score",count1)
    --   else
    --     count2 = count2 +1
    --     gStateMachine:change("score",count2)
    --   end
        if self.player1.collider.body then
            PLAYER1_SCORE = PLAYER1_SCORE + 1
            gStateMachine:change('newScore', "player1")
        else
            PLAYER2_SCORE = PLAYER2_SCORE + 1
            gStateMachine:change('newScore', "player2")
        end

    end
end

function PlayState:exit()
    
    self.sounds:stop()
    for k,v in pairs(self.Player1allBullet) do
        for k1, v1 in pairs(v.shoots) do
            v1:destroy()
        end
    end

    for k,v in pairs(self.Player2allBullet) do
        for k1, v1 in pairs(v.shoots) do
            v1:destroy()
        end
    end

    for k,v in pairs(self.player1ScatterShot) do
        for k1,v1 in pairs(v.shots) do
        v1:destroy()
        end
    end

    for k, v in pairs(self.player2ScatterShot) do
        for k1, v1 in pairs(v.shots) do
            v1:destroy()
        end
    end

    for k,v in pairs(self.Powersuplier) do
        for k1,v1 in pairs(v.dabba) do
            if v1.body then
                v1:destroy()
            end
        
        end
    end

    if self.player2.collider.body then
        self.player2.collider:destroy()
        self.mappart1.collider:destroy()
        self.mappart2.collider:destroy()
        self.mappart3.collider:destroy()
        self.mappart4.collider:destroy()
        self.mappart5.collider:destroy()
        self.mappart6.collider:destroy()
        self.mappart7.collider:destroy()
        self.mappart8.collider:destroy()
    end
    if self.player1.collider.body then
        self.player1.collider:destroy()
        self.mappart1.collider:destroy()
        self.mappart2.collider:destroy()
        self.mappart3.collider:destroy()
        self.mappart4.collider:destroy()
        self.mappart5.collider:destroy()
        self.mappart6.collider:destroy()
        self.mappart7.collider:destroy()
        self.mappart8.collider:destroy()
    end

    for k,v in pairs(self.player1Bomb) do
        v.collider:destroy()
    end

    for k,v in pairs(self.player2Bomb) do
        v.collider:destroy()
    end

    for k,v in pairs(self.player1Lasers) do 
        v.laser:destroy()
    end
    
    for k,v in pairs(self.player2Lasers) do 
        v.laser:destroy()
    end
    
  --self.player2.collider:destroy()
--   self.player1.collider:destroy()


end

function PlayState:keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
   
    if key == 'd' then

        local collision_data = self.player1.collider:getEnterCollisionData('powersuplier')
        if collision_data ~= nil then
            if collision_data.collider.choice == 1 then
                self:shootLaser('player1')
                collision_data.collider.choice =0
            elseif collision_data.collider.choice ==2 then
                self:plantBomb('player1')
                collision_data.collider.choice =0
            elseif collision_data.collider.choice ==3 then
                self:shootScatterShot('player1')
                collision_data.collider.choice =0
            end    
        end
        self.whichpowerp1 = ""
    end

            if key == 'm' then
            local collision_data = self.player2.collider:getEnterCollisionData('powersuplier')
            if collision_data ~= nil then
                if collision_data.collider.choice == 1 then
                self:shootLaser('player2')
                collision_data.collider.choice =0
                elseif collision_data.collider.choice ==2 then
                    self:plantBomb('player2')
                    collision_data.collider.choice =0
                elseif collision_data.collider.choice ==3 then
                    self:shootScatterShot('player2')
                    collision_data.collider.choice =0
                end
            end
            self.whichpowerp2 = ""
        end

    if key == 's' then
        self:shootBullet('player1')

    end

    if key =='n' then
        self:shootBullet('player2')
    end
end

function PlayState:render()
    --if not self.ScoreBoard then

    love.graphics.draw(self.background,0,0,0,WINDOW_WIDTH/self.background:getWidth(),WINDOW_HEIGHT/self.background:getHeight())
      if self.player1.collider.body then

        love.graphics.setColor(1,1,0)
        love.graphics.rectangle("fill",300,150,50,175)
        love.graphics.rectangle("fill",125.,325,175,50)
        love.graphics.rectangle("fill",300,375,50,175)
        love.graphics.rectangle("fill",350,325,175,50)
        love.graphics.rectangle("fill",800,150,50,175)
        love.graphics.rectangle("fill",625.,325,175,50)
        love.graphics.rectangle("fill",800,375,50,175)
        love.graphics.rectangle("fill",850,325,175,50)
        love.graphics.setColor(1,1,1)
          self.player1:render()
          self.mappart1:render()
          self.mappart2:render()
          self.mappart3:render()
          self.mappart4:render()
          self.mappart6:render()
          self.mappart7:render()
          self.mappart8:render()
          self.mappart5:render()
          
      end
      if self.player2.collider.body then
        love.graphics.setColor(0.9,0.4,0.4)
        love.graphics.rectangle("fill",300,150,50,175)
        love.graphics.rectangle("fill",125.,325,175,50)
        love.graphics.rectangle("fill",300,375,50,175)
        love.graphics.rectangle("fill",350,325,175,50)
        love.graphics.rectangle("fill",800,150,50,175)
        love.graphics.rectangle("fill",625.,325,175,50)
        love.graphics.rectangle("fill",800,375,50,175)
        love.graphics.rectangle("fill",850,325,175,50)
        love.graphics.setColor(1,1,1)
          self.player2:render()
          self.mappart1:render()
          self.mappart2:render()
          self.mappart3:render()
          self.mappart4:render()
          self.mappart5:render()
          self.mappart6:render()
          self.mappart7:render()
          self.mappart8:render()

          
      end

      

  
      for key, value in pairs(self.player1Lasers) do
          value:render()
      end
  
      for key, value in pairs(self.Player1allBullet) do
          value:render()
      end
  
    --   love.graphics.print(count1)
    --   love.graphics.print(count2,0,50)
  
      love.graphics.print(self.whichpowerp1,20,20)
      love.graphics.print(self.whichpowerp2,WINDOW_WIDTH-150,20)
  
  
      if self.player1.collider:enter("powersuplier") then
          local collision_data = self.player1.collider:getEnterCollisionData('powersuplier')
          if collision_data.collider.choice ==1 then
              self.whichpowerp1 = "Laser"
              --love.graphics.print("Laser",20,20)
          elseif collision_data.collider.choice ==2 then
              self.whichpowerp1 = "Bomb"
              --love.graphics.print("Bomb",20,20)
          elseif collision_data.collider.choice ==3  then
              self.whichpowerp1 = "ScatterShot"
              --love.graphics.print("ScatterShot",20,20)
          elseif  collision_data.collider.choice ==0 then
              self.whichpowerp1 = "Oops No Powerup!!"
              --love.graphics.print("Oops No Powerup",20,20)
          end
          
      end
  
      if self.player2.collider:enter("powersuplier") then
          local collision_data = self.player2.collider:getEnterCollisionData('powersuplier')
          if collision_data.collider.choice ==1 then
              self.whichpowerp2 = "Laser"
              --love.graphics.print("Laser",20,20)
          elseif collision_data.collider.choice ==2 then
              self.whichpowerp2 = "Bomb"
              --love.graphics.print("Bomb",20,20)
          elseif collision_data.collider.choice ==3  then
              self.whichpowerp2 = "ScatterShot"
              --love.graphics.print("ScatterShot",20,20)
          elseif  collision_data.collider.choice ==0 then
              self.whichpowerp2 = "Oops No Powerup!!"
              --love.graphics.print("Oops No Powerup",20,20)
          end
          
      end
    --end
  
      -- for key, value in pairs(self.Player2allBullet) do
      --     value:render()
      -- end
  
      -- if self.player1.destroy or self.player2.destroy then
      --     love.graphics.print("Game Ended",100,100)
      -- end
      love.graphics.print('Memory actually used (in kB): ' .. collectgarbage('count'), 500,20)
  end
  