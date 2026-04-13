-- states/NetClientState.lua  ─ Thin-client game state for LAN player 2
-- The host runs all physics; this state only sends input and renders received state.
NetClientState = Class{__includes = BaseState}

local net = require "modules.net"

local POWER_NAMES = { [1]="Laser", [2]="Bomb", [3]="Scatter", [4]="Reverse" }
local HUD_COLORS  = { {1,0.9,0.2}, {0.3,0.9,1}, {0.3,1,0.3}, {1,0.5,0.3} }
local HUD_X       = { 20, WINDOW_WIDTH - 230 }

function NetClientState:init()
    -- Game state received from host (updated by MSG_STATE packets)
    self.playerData  = {}
    self.bulletData  = {}
    self.powerupData = {}
    self.gameOver    = false
    self.winnerId    = 0
    self.endTimer    = 0

    -- Pending one-shot input flags; cleared after each send
    self.pendingShoot    = false
    self.pendingUsepower = false
    self.sendTimer       = 0

    -- Assets (mirrors PlayState assets so rendering is consistent)
    self.background   = love.graphics.newImage("assets/Background/b3.png")
    self.playerimages = {
        love.graphics.newImage("assets/player1.png"),
        love.graphics.newImage("assets/player2.png"),
    }
    self.powerupimage = love.graphics.newImage("assets/powersupplier.png")
    self.bulletimage  = love.graphics.newImage("assets/Bullet 5x5.png")
    self.font         = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 22)
    self.font2        = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 48)

    -- Map rects (must match PlayState's layout)
    self.mapRects = {
        {300,150,50,175}, {125,325,175,50},
        {300,375,50,175}, {350,325,175,50},
        {800,150,50,175}, {625,325,175,50},
        {800,375,50,175}, {850,325,175,50},
    }
end

function NetClientState:update(dt)
    -- 1) Poll enet for incoming messages from the host
    if NET.host then
        local event = NET.host:service(0)
        while event do
            if event.type == "receive" then
                local msg = net.decode(event.data)
                if msg then
                    if msg.type == net.MSG_STATE then
                        self.playerData  = msg.players
                        self.bulletData  = msg.bullets
                        self.powerupData = msg.powerups
                        if msg.gameOver and not self.gameOver then
                            self.gameOver = true
                            self.winnerId = msg.winnerId
                        end
                    elseif msg.type == net.MSG_GAMEOVER then
                        -- Sync score globals so NewScoreState renders correctly
                        PLAYER1_SCORE = msg.p1score or PLAYER1_SCORE
                        PLAYER2_SCORE = msg.p2score or PLAYER2_SCORE
                        PLAYER_SCORES[1] = PLAYER1_SCORE
                        PLAYER_SCORES[2] = PLAYER2_SCORE
                        local winner = (msg.winnerId == 1) and "player1" or "player2"
                        gStateMachine:change('newScore', winner)
                        return
                    end
                end
            elseif event.type == "disconnect" then
                self:_cleanup()
                gStateMachine:change("title")
                return
            end
            event = NET.host:service(0)
        end
    end

    -- (Game-over is now handled immediately via MSG_GAMEOVER → newScore transition)

    -- 3) Send our input to the host every frame (~60 Hz)
    self.sendTimer = self.sendTimer + dt
    if self.sendTimer >= 1/60 and NET.peer then
        self.sendTimer = 0
        local lid    = NET.localId or 2
        local rotate = KEY_BINDINGS[lid] and love.keyboard.isDown(KEY_BINDINGS[lid].rotate) or false
        NET.peer:send(net.encodeInput(rotate, self.pendingShoot, self.pendingUsepower), 0, "unreliable")
        self.pendingShoot    = false
        self.pendingUsepower = false
    end
end

function NetClientState:keypressed(key)
    if key == "escape" then
        self:_cleanup()
        gStateMachine:change("title")
        return
    end
    local lid = NET.localId or 2
    if KEY_BINDINGS[lid] then
        if key == KEY_BINDINGS[lid].shoot    then self.pendingShoot    = true end
        if key == KEY_BINDINGS[lid].usepower then self.pendingUsepower = true end
    end
end

function NetClientState:_cleanup()
    if NET.host then NET.host:destroy() end
    NET.host    = nil
    NET.peer    = nil
    NET.mode    = nil
    NET.localId = 1
end

function NetClientState:exit() end

function NetClientState:render()
    -- Background
    love.graphics.draw(self.background, 0, 0, 0,
        WINDOW_WIDTH  / self.background:getWidth(),
        WINDOW_HEIGHT / self.background:getHeight())

    -- Map obstacles
    love.graphics.setColor(0.9, 0.4, 0.4)
    for _, r in ipairs(self.mapRects) do
        love.graphics.rectangle("fill", r[1], r[2], r[3], r[4])
    end
    love.graphics.setColor(1, 1, 1)

    -- Players (positions received from host)
    for i, pd in ipairs(self.playerData) do
        if pd.alive then
            local img = self.playerimages[i]
            if img then
                love.graphics.draw(img, pd.x, pd.y,
                    pd.angle + 359.75, 1, 1,
                    img:getWidth()/2, img:getHeight()/2)
            else
                local c = HUD_COLORS[i] or {1,1,1}
                love.graphics.setColor(c[1], c[2], c[3])
                love.graphics.circle("fill", pd.x, pd.y, 30)
                love.graphics.setColor(1, 1, 1)
            end
        end
    end

    -- Bullets — same image and scale as bullets:render() on the host
    for _, b in ipairs(self.bulletData) do
        love.graphics.draw(self.bulletimage, b.x - 3, b.y - 3, 0, 1.7, 1.7)
    end

    -- Powerup boxes
    for _, p in ipairs(self.powerupData) do
        love.graphics.draw(self.powerupimage, p.x - 17, p.y - 19, 0, 0.3, 0.3)
    end

    -- HUD: power name per player
    love.graphics.setFont(self.font)
    for i, pd in ipairs(self.playerData) do
        if pd.pendingpower and pd.pendingpower > 0 then
            local c = HUD_COLORS[i] or {1,1,1}
            love.graphics.setColor(c[1], c[2], c[3])
            local key = KEY_BINDINGS[i] and KEY_BINDINGS[i].usepower or "?"
            love.graphics.print(
                "P"..i.." Power: "..(POWER_NAMES[pd.pendingpower] or "?").."  ["..key.."]",
                HUD_X[i] or 20, 20)
            love.graphics.setColor(1, 1, 1)
        end
    end

    -- "Waiting" overlay when no state has arrived yet (host is in score screen)
    if #self.playerData == 0 and not self.gameOver then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(self.font)
        love.graphics.printf("Waiting for next round…", 0, WINDOW_HEIGHT/2 - 20, WINDOW_WIDTH, "center")
    end

end
