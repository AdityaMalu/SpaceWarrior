-- states/LobbyState.lua  ─ LAN Lobby: choose to Host or Join a game
LobbyState = Class{__includes = BaseState}

local net = require "modules.net"

-- Internal phase names
local MENU       = "menu"
local HOST_WAIT  = "host_wait"    -- server running, waiting for a client
local HOST_READY = "host_ready"   -- client connected, press ENTER to begin
local JOIN_INPUT = "join_input"   -- typing in the host's IP address
local CONNECTING = "connecting"   -- TCP handshake in progress

function LobbyState:init()
    self.phase   = MENU
    self.ipInput = ""
    self.localIP = ""
    self.errMsg  = ""
    self.font    = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 36)
    self.font2   = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 22)
end

function LobbyState:update(dt)
    if not NET.host then return end

    if self.phase == HOST_WAIT or self.phase == HOST_READY then
        local event = NET.host:service(0)
        while event do
            if event.type == "connect" then
                NET.peer   = event.peer
                self.phase = HOST_READY
                self.errMsg = ""
            elseif event.type == "disconnect" then
                NET.peer    = nil
                self.phase  = HOST_WAIT
                self.errMsg = "Client disconnected — waiting again…"
            end
            event = NET.host:service(0)
        end

    elseif self.phase == CONNECTING then
        local event = NET.host:service(10)
        while event do
            if event.type == "connect" then
                NET.peer    = event.peer
                self.errMsg = "Connected! Waiting for host to start…"
            elseif event.type == "receive" then
                local msg = net.decode(event.data)
                if msg and msg.type == net.MSG_START then
                    NET.mode    = "client"
                    NET.localId = 2
                    gStateMachine:change("netclient")
                    return
                end
            elseif event.type == "disconnect" then
                self.errMsg = "Connection refused or timed out"
                self.phase  = JOIN_INPUT
                if NET.host then NET.host:destroy() end
                NET.host = nil
                NET.peer = nil
            end
            event = NET.host:service(10)
        end
    end
end

function LobbyState:keypressed(key)
    if self.phase == MENU then
        if key == "h" then
            NET.host    = net.enet.host_create("*:" .. net.PORT, 1, 2)
            NET.mode    = "host"
            NET.localId = 1
            self.localIP = net.getLocalIP()
            self.phase   = HOST_WAIT
        elseif key == "j" then
            self.phase   = JOIN_INPUT
            self.ipInput = ""
            self.errMsg  = ""
        elseif key == "escape" then
            gStateMachine:change("title")
        end

    elseif self.phase == HOST_WAIT then
        if key == "escape" then self:_cancel() end

    elseif self.phase == HOST_READY then
        if key == "return" then
            NET.peer:send(net.encodeStart(), 1, "reliable")
            gStateMachine:change("play")
        elseif key == "escape" then
            self:_cancel()
        end

    elseif self.phase == JOIN_INPUT then
        if key == "return" and #self.ipInput > 0 then
            NET.host      = net.enet.host_create(nil, 1, 2)
            NET.host:connect(self.ipInput .. ":" .. net.PORT, 2)
            self.phase    = CONNECTING
            self.errMsg   = "Connecting to " .. self.ipInput .. "…"
        elseif key == "backspace" then
            self.ipInput = self.ipInput:sub(1, -2)
        elseif key == "escape" then
            self.phase  = MENU
            self.errMsg = ""
        end

    elseif self.phase == CONNECTING then
        if key == "escape" then
            if NET.host then NET.host:destroy() end
            NET.host   = nil
            NET.peer   = nil
            NET.mode   = nil
            self.phase  = JOIN_INPUT
            self.errMsg = ""
        end
    end
end

-- Called by love.textinput (routed via main.lua) — IP address characters only
function LobbyState:textinput(t)
    if self.phase == JOIN_INPUT and t:match("[0-9%.]") then
        self.ipInput = self.ipInput .. t
    end
end

function LobbyState:_cancel()
    if NET.host then NET.host:destroy() end
    NET.host   = nil
    NET.peer   = nil
    NET.mode   = nil
    self.phase = MENU
    self.errMsg = ""
end

function LobbyState:exit() end   -- host/peer kept alive for PlayState / NetClientState

function LobbyState:render()
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf("LAN MULTIPLAYER", 0, 80, WINDOW_WIDTH, "center")
    love.graphics.setFont(self.font2)

    if self.phase == MENU then
        love.graphics.printf("H  –  HOST GAME",  0, 250, WINDOW_WIDTH, "center")
        love.graphics.printf("J  –  JOIN GAME",  0, 310, WINDOW_WIDTH, "center")
        love.graphics.printf("ESC  –  BACK",     0, 370, WINDOW_WIDTH, "center")

    elseif self.phase == HOST_WAIT then
        love.graphics.printf("Waiting for player to join…",  0, 240, WINDOW_WIDTH, "center")
        love.graphics.printf("Your IP:  " .. self.localIP,   0, 295, WINDOW_WIDTH, "center")
        love.graphics.printf("Port:     " .. net.PORT,       0, 340, WINDOW_WIDTH, "center")
        love.graphics.printf("ESC  –  cancel",               0, 420, WINDOW_WIDTH, "center")

    elseif self.phase == HOST_READY then
        love.graphics.setColor(0.3, 1, 0.3)
        love.graphics.printf("Player connected!",        0, 250, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ENTER  –  start game",    0, 320, WINDOW_WIDTH, "center")
        love.graphics.printf("ESC  –  disconnect",      0, 380, WINDOW_WIDTH, "center")

    elseif self.phase == JOIN_INPUT then
        love.graphics.printf("Enter host IP address:",  0, 220, WINDOW_WIDTH, "center")
        love.graphics.setColor(0.9, 0.9, 0.4)
        love.graphics.printf(self.ipInput .. "_",       0, 280, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ENTER to connect  |  ESC – back", 0, 350, WINDOW_WIDTH, "center")

    elseif self.phase == CONNECTING then
        love.graphics.printf(self.errMsg,    0, 300, WINDOW_WIDTH, "center")
        love.graphics.printf("ESC  –  cancel", 0, 370, WINDOW_WIDTH, "center")
    end

    if self.errMsg ~= "" and self.phase ~= CONNECTING then
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.printf(self.errMsg, 0, 500, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
    end
end
