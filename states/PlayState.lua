PlayState = Class{__includes = BaseState}

require 'modules.Player'
require 'modules.powerups'
require 'modules.bullets'
require 'modules.powersuplier'
require 'modules.maps'
local net = require 'modules.net'
local physics = require 'modules.physics'
math.randomseed(os.time())

-- Thin wrapper around physics.resolveElasticCollision: adapts the Player/collider
-- API to the pure-Lua function that lives in modules/physics.lua.
local function resolveElasticCollision(pa, pb)
    local a = { x = pa.collider:getX(), y = pa.collider:getY(),
                angle = pa.angle, speed = pa.speed, radius = pa.radius }
    local b = { x = pb.collider:getX(), y = pb.collider:getY(),
                angle = pb.angle, speed = pb.speed, radius = pb.radius }
    physics.resolveElasticCollision(a, b)
    pa.angle, pa.speed = a.angle, a.speed
    pb.angle, pb.speed = b.angle, b.speed
    pa.collider:setX(a.x); pa.collider:setY(a.y)
    pb.collider:setX(b.x); pb.collider:setY(b.y)
end

function PlayState:init()
    -- Number of players for this session (Phase 3 will set from network lobby)
    local NUM_PLAYERS = 2

    -- Player images (add more entries for players 3, 4 …)
    self.playerimages = {
        love.graphics.newImage("assets/player1.png"),
        love.graphics.newImage("assets/player2.png"),
    }

    -- Spawn positions (scales to 4 players; Phase 3 may override)
    local spawnPos = {
        { x = 40,              y = WINDOW_HEIGHT / 2 },
        { x = WINDOW_WIDTH-40, y = WINDOW_HEIGHT / 2 },
        { x = WINDOW_WIDTH/2,  y = 40                },
        { x = WINDOW_WIDTH/2,  y = WINDOW_HEIGHT-40  },
    }

    -- Create players; in host mode only the host's slot is local
    self.players = {}
    for i = 1, NUM_PLAYERS do
        local sp = spawnPos[i]
        local p  = Player(i, sp.x, sp.y, 30)
        if NET.mode == 'host' then
            p.isLocal = (i == NET.localId)   -- only the host player reads keyboard
        else
            p.isLocal = true                 -- local play: all players are local
        end
        p.controls = KEY_BINDINGS[i] or {}   -- reference to global — live bindings
        self.players[i] = p
    end

    -- Network (host) state
    self.netTimer           = 0
    self.lastClientShoot    = false
    self.lastClientUsepower = false
    self.hasGameEnded       = false   -- guards the one-shot MSG_GAMEOVER send

    -- Per-player weapon / power tables (indexed by player ID)
    self.lasers       = {}
    self.bombs        = {}
    self.scattershots = {}
    self.allBullets   = {}
    self.whichpower   = {}
    self.pendingpower = {}
    for i = 1, NUM_PLAYERS do
        self.lasers[i]       = {}
        self.bombs[i]        = {}
        self.scattershots[i] = {}
        self.allBullets[i]   = {}
        self.whichpower[i]   = ""
        self.pendingpower[i] = 0
    end

    self.Powersuplier     = {}
    self.background       = love.graphics.newImage("assets/Background/b3.png")
    self.player1bombimage = love.graphics.newImage("assets/Bomb_12x12.png")
    self.totalpowersuplier = 6
    self.timer            = 0
    self.display          = 0
    self.statechangetimer = 0
    self.hasGameEnded     = false

    -- Map obstacles (table — easy to extend or randomise later)
    self.maps = {
        Maps(300, 150,  50, 175, 5),
        Maps(125, 325, 175,  50, 5),
        Maps(300, 375,  50, 175, 5),
        Maps(350, 325, 175,  50, 5),
        Maps(800, 150,  50, 175, 5),
        Maps(625, 325, 175,  50, 5),
        Maps(800, 375,  50, 175, 5),
        Maps(850, 325, 175,  50, 5),
    }
    -- Rectangle coords mirroring Maps() init args (for rendering)
    self.mapRects = {
        {300, 150,  50, 175}, {125, 325, 175,  50},
        {300, 375,  50, 175}, {350, 325, 175,  50},
        {800, 150,  50, 175}, {625, 325, 175,  50},
        {800, 375,  50, 175}, {850, 325, 175,  50},
    }

    self.sounds = love.audio.newSource("assets/Sounds/Space Heroes.ogg", "static")
    self.sounds:setVolume(0.18)
    self.sounds:setLooping(true)
    self.sounds:play()
    self.blastsound  = love.audio.newSource("assets/Sounds/deathexplosion.mp3", "static")
    self.blastsound:setVolume(0.5)
    self.bulletsound = love.audio.newSource('assets/Sounds/bulletshootsound.mp3', 'static')
    self.bulletsound:setVolume(0.2)
end

-- id = numeric player ID (1, 2, 3 …)
function PlayState:shootBullet(id)
    local p = self.players[id]
    if p and p.collider.body and p.totalbullets > 0 then
        p.totalbullets = p.totalbullets - 1
        table.insert(self.allBullets[id], bullets(
            p.collider:getX(), p.collider:getY(),
            math.cos(p.angle) + p.collider:getX(),
            math.sin(p.angle) + p.collider:getY(),
            id
        ))
    end
end

function PlayState:shootLaser(id)
    local p = self.players[id]
    if p and p.collider.body then
        table.insert(self.lasers[id], Laser(
            p.collider:getX(), p.collider:getY(),
            math.cos(p.angle) * 4000, math.sin(p.angle) * 4000,
            id
        ))
    end
end

function PlayState:plantBomb(id)
    local p = self.players[id]
    if p and p.collider.body then
        table.insert(self.bombs[id], Bomb(p.collider:getX(), p.collider:getY(), id))
    end
end

function PlayState:shootScatterShot(id)
    local p = self.players[id]
    if p and p.collider.body then
        table.insert(self.scattershots[id], ScatterShot(p.collider:getX(), p.collider:getY(), id))
    end
end

-- Activate the stored power for player `id` and clear it from HUD
function PlayState:usePower(id)
    local power = self.pendingpower[id]
    if power == 1 then
        self:shootLaser(id)
    elseif power == 2 then
        self:plantBomb(id)
    elseif power == 3 then
        self:shootScatterShot(id)
    elseif power == 4 then
        -- Reverse: flip ALL players' angles (keeps the chaos symmetric)
        for _, p in ipairs(self.players) do
            p.angle = -p.angle
        end
    end
    self.pendingpower[id] = 0
    self.whichpower[id]   = ""
end

function PlayState:dabbaplant()
    self.totalpowersuplier = self.totalpowersuplier - 1
    if self.totalpowersuplier < 6 and self.totalpowersuplier > 0 then
        table.insert(self.Powersuplier,
            powersuplier(math.random(100, 1100), math.random(100, 600), 30, 30, 'powersuplier'))
    end
end

function PlayState:update(dt)
    local powerNames = { [1]="Laser", [2]="Bomb", [3]="Scatter Shot", [4]="Reverse" }

    -- Count alive players
    local alivePlayers = {}
    for i, p in ipairs(self.players) do
        if p.collider.body then
            table.insert(alivePlayers, i)
        end
    end

    -- ── Host networking: poll for client input and inject into remote player ──
    if NET.mode == 'host' and NET.host then
        local event = NET.host:service(0)
        while event do
            if event.type == 'receive' then
                local msg = net.decode(event.data)
                if msg and msg.type == net.MSG_INPUT then
                    local p2 = self.players[2]
                    if p2 then
                        p2.networkInput = p2.networkInput or {}
                        p2.networkInput.rotate = msg.rotate
                        -- One-shot shoot / usepower (edge-triggered)
                        if msg.shoot and not self.lastClientShoot then
                            self.bulletsound:play()
                            self:shootBullet(2)
                        end
                        if msg.usepower and not self.lastClientUsepower
                                and self.pendingpower[2] > 0 then
                            self:usePower(2)
                        end
                        self.lastClientShoot    = msg.shoot
                        self.lastClientUsepower = msg.usepower
                    end
                end
            elseif event.type == 'disconnect' then
                -- Client left; return to title
                gStateMachine:change('title')
                return
            end
            event = NET.host:service(0)
        end
    end

    if #alivePlayers > 1 then
        self.timer   = self.timer   + dt
        self.display = self.display + dt

        -- Update movement for every alive player
        for _, i in ipairs(alivePlayers) do
            self.players[i]:update(dt)
        end

        -- Power collection: save choice before collider is destroyed
        for _, i in ipairs(alivePlayers) do
            local p = self.players[i]
            if p.collider:enter("powersuplier") then
                local cd = p.collider:getEnterCollisionData('powersuplier')
                local choice = cd.collider.choice
                self.pendingpower[i] = choice
                self.whichpower[i]   = powerNames[choice] or "???"
                if cd.collider.body then cd.collider:destroy() end
            end
        end

        -- Update bullets + destroy on map hit
        for _, i in ipairs(alivePlayers) do
            for _, v in pairs(self.allBullets[i]) do
                v:update(dt)
                for _, v1 in pairs(v.shoots) do
                    if v1.body and v1:enter('maps') then v1:destroy() end
                end
            end
        end

        -- Update lasers
        for _, i in ipairs(alivePlayers) do
            for _, laser in pairs(self.lasers[i]) do
                if laser.laser.body then laser:update(dt) end
            end
        end

        -- Update bombs (Bomb:update now queries targets internally)
        for _, i in ipairs(alivePlayers) do
            for _, bomb in pairs(self.bombs[i]) do
                if bomb.collider.body then bomb:update(dt) end
            end
        end

        -- Update scatter shots + destroy on map hit
        for _, i in ipairs(alivePlayers) do
            for _, ss in pairs(self.scattershots[i]) do
                ss:update(dt)
                for _, v1 in pairs(ss.shots) do
                    if v1.body and v1:enter('maps') then v1:destroy() end
                end
            end
        end

        -- Elastic collision: check every unique pair of alive players
        for a = 1, #alivePlayers do
            for b = a + 1, #alivePlayers do
                local pa = self.players[alivePlayers[a]]
                local pb = self.players[alivePlayers[b]]
                if pa.collider.body and pb.collider.body then
                    resolveElasticCollision(pa, pb)
                end
            end
        end

        if self.timer > 10 then
            self:dabbaplant()
            self.timer = 0
        end

    else
        -- One or zero players remain: game over
        self.statechangetimer = self.statechangetimer + dt
        self.sounds:setVolume(0.05)
        self.blastsound:play()

        if self.statechangetimer > 3 then
            self.blastsound:stop()
            local winnerId = alivePlayers[1]   -- nil if draw
            -- Notify network client of game over (reliable, once)
            if NET.mode == 'host' and NET.peer and not self.hasGameEnded then
                NET.peer:send(net.encodeGameOver(winnerId or 0, PLAYER1_SCORE, PLAYER2_SCORE), 1, "reliable")
            end
            self.hasGameEnded = true
            if winnerId then
                PLAYER_SCORES[winnerId] = (PLAYER_SCORES[winnerId] or 0) + 1
                -- Keep legacy score globals in sync for the existing score states
                if winnerId == 1 then
                    PLAYER1_SCORE = PLAYER1_SCORE + 1
                elseif winnerId == 2 then
                    PLAYER2_SCORE = PLAYER2_SCORE + 1
                end
                gStateMachine:change('newScore', 'player'..winnerId)
            else
                gStateMachine:change('newScore', 'player1')   -- draw fallback
            end
        end
    end

    -- ── Host networking: broadcast game state to client ───────────────────────
    if NET.mode == 'host' and NET.peer then
        self.netTimer = self.netTimer + dt
        if self.netTimer >= net.TICK_RATE then
            self.netTimer = 0
            local gameOver = #alivePlayers <= 1
            local winnerId = gameOver and (alivePlayers[1] or 0) or 0
            local stateData = net.encodeState(
                self.players, self.allBullets, self.Powersuplier,
                self.pendingpower, gameOver, winnerId,
                self.lasers, self.bombs, self.scattershots)
            NET.peer:send(stateData, 0, "unreliable")
        end
    end
end

function PlayState:exit()
    self.sounds:stop()

    -- Destroy all bullets for every player
    for i = 1, #self.players do
        for _, v in pairs(self.allBullets[i]) do
            for _, v1 in pairs(v.shoots) do
                if v1.body then v1:destroy() end
            end
        end
        for _, v in pairs(self.scattershots[i]) do
            for _, v1 in pairs(v.shots) do
                if v1.body then v1:destroy() end
            end
        end
        for _, v in pairs(self.bombs[i]) do
            if v.collider.body then v.collider:destroy() end
        end
    end

    -- Destroy powerup suppliers
    for _, v in pairs(self.Powersuplier) do
        for _, v1 in pairs(v.dabba) do
            if v1.body then v1:destroy() end
        end
    end

    -- Destroy player colliders
    for _, p in ipairs(self.players) do
        if p.collider.body then p.collider:destroy() end
    end

    -- Destroy map colliders
    for _, m in ipairs(self.maps) do
        if m.collider.body then m.collider:destroy() end
    end

    -- NOTE: enet is intentionally NOT destroyed here.
    -- The connection must survive the newScore→play cycle so the next round
    -- can start automatically.  TitleState:init() is the single cleanup point.
end

function PlayState:keypressed(key)
    if key == 'escape' then
        gStateMachine:change('title')   -- ESC = back to menu (not quit)
        return
    end

    -- Each local player's shoot and usepower keys are driven by their controls table
    for i, p in ipairs(self.players) do
        if p.isLocal and p.collider.body and p.controls then
            if key == p.controls.shoot then
                self.bulletsound:play()
                self:shootBullet(i)
            end
            if key == p.controls.usepower and self.pendingpower[i] > 0 then
                self:usePower(i)
            end
        end
    end
end

function PlayState:render()
    -- Background
    love.graphics.draw(self.background, 0, 0, 0,
        WINDOW_WIDTH  / self.background:getWidth(),
        WINDOW_HEIGHT / self.background:getHeight())

    -- Map obstacles (draw once, only while colliders are alive)
    if #self.maps > 0 and self.maps[1].collider.body then
        love.graphics.setColor(0.9, 0.4, 0.4)
        for _, rect in ipairs(self.mapRects) do
            love.graphics.rectangle("fill", rect[1], rect[2], rect[3], rect[4])
        end
        love.graphics.setColor(1, 1, 1)
    end

    -- Players
    for i, p in ipairs(self.players) do
        if p.collider.body then
            p:render()
            local img = self.playerimages[i]
            if img then
                love.graphics.draw(img,
                    p.collider:getX(), p.collider:getY(),
                    p.angle + 359.75, 1, 1,
                    img:getWidth() / 2, img:getHeight() / 2)
            end
        end
    end

    -- Lasers
    for i = 1, #self.players do
        for _, v in pairs(self.lasers[i]) do v:render() end
    end

    -- Bullets
    for i = 1, #self.players do
        for _, v in pairs(self.allBullets[i]) do v:render() end
    end

    -- Bombs
    for i = 1, #self.players do
        for _, v in pairs(self.bombs[i]) do
            love.graphics.draw(self.player1bombimage, v.collider:getX()-5, v.collider:getY()-5)
            if self.display > 3 then
                love.graphics.circle("line", v.collider:getX(), v.collider:getY(), 200)
                self.display = 0
            end
            if v.growingradius > 0 then
                love.graphics.setColor(255, 165, 0, 0.5)
                love.graphics.circle("fill", v.collider:getX(), v.collider:getY(), v.growingradius)
            end
            love.graphics.setColor(1, 1, 1)
        end
    end

    -- Scatter shots
    for i = 1, #self.players do
        for _, v in pairs(self.scattershots[i]) do v:render() end
    end

    -- Powerup suppliers
    for _, v in pairs(self.Powersuplier) do v:render() end

    -- HUD: power name per player (colour-coded, stays until fired)
    local hudColors = {{1,0.9,0.2}, {0.3,0.9,1}, {0.3,1,0.3}, {1,0.5,0.3}}
    local hudX      = {20, WINDOW_WIDTH-220, WINDOW_WIDTH/2-110, WINDOW_WIDTH/2+20}
    for i, p in ipairs(self.players) do
        if self.whichpower[i] ~= "" then
            local c = hudColors[i] or {1, 1, 1}
            love.graphics.setColor(c[1], c[2], c[3])
            local keyHint = (p.controls and p.controls.usepower) or "?"
            love.graphics.print("P"..i.." Power: "..self.whichpower[i].."  [press "..keyHint.."]",
                hudX[i] or 20, 20)
            love.graphics.setColor(1, 1, 1)
        end
    end
end
