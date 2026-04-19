-- states/LobbyState.lua  ─ Multiplayer Lobby: Host or Join over LAN or Internet
LobbyState = Class{__includes = BaseState}

local net = require "modules.net"

-- Internal phase names
local MENU       = "menu"
local HOST_WAIT  = "host_wait"    -- server running, waiting for a client
local HOST_READY = "host_ready"   -- client connected, press ENTER to begin
local JOIN_INPUT = "join_input"   -- typing in the host's IP address
local CONNECTING = "connecting"   -- TCP handshake in progress

-- Background thread: fetches public IP from ipify.org (non-blocking)
local PUBIP_THREAD = [[
    local http = require("socket.http")
    local chan  = love.thread.getChannel("sw_pubip")
    local ok, body, code = pcall(http.request, "http://api.ipify.org")
    if ok and code == 200 and body and #body > 0 then
        chan:push(body)
    else
        chan:push("")
    end
]]

function LobbyState:init()
    self.phase       = MENU
    self.ipInput     = ""
    self.localIP     = ""
    self.publicIP    = ""          -- fetched asynchronously when hosting
    self.connectTimer = 0
    self.handshakeComplete = false
    self.pendingTitleMessage = nil
    self.pubIPChan   = love.thread.getChannel("sw_pubip")
    self.pubIPThread = nil
    self.errMsg      = ""
    self.font    = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 36)
    self.font2   = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 22)
    -- Drain any stale result from a previous session
    while self.pubIPChan:pop() do end
end

function LobbyState:update(dt)
    -- Poll public-IP result channel (filled by background thread)
    local fetchedIP = self.pubIPChan:pop()
    if fetchedIP then
        self.publicIP = (#fetchedIP > 0) and fetchedIP or "unavailable"
    end

    if not NET.host then return end

    if self.phase == HOST_WAIT or self.phase == HOST_READY then
        local event = NET.host:service(0)
        while event do
            if event.type == "connect" then
                NET.peer   = event.peer
                self.errMsg = ""
            elseif event.type == "receive" then
                local msg = net.decode(event.data)
                if msg and msg.type == net.MSG_HELLO then
                    if msg.version == net.NET_PROTOCOL_VERSION then
                        NET.peer = event.peer
                        NET.peer:send(net.encodeHelloOk(), 1, "reliable")
                        self.phase = HOST_READY
                        self.errMsg = ""
                    else
                        self.pendingTitleMessage = net.formatVersionMismatch(
                            net.getGameVersion(),
                            net.NET_PROTOCOL_VERSION,
                            msg.version)
                        event.peer:send(
                            net.encodeVersionMismatch(net.NET_PROTOCOL_VERSION, msg.version),
                            1,
                            "reliable")
                        event.peer:disconnect_later()
                        if NET.host then NET.host:flush() end
                        self.phase = HOST_WAIT
                        self.errMsg = self.pendingTitleMessage
                        NET.peer = nil
                    end
                end
            elseif event.type == "disconnect" then
                NET.peer    = nil
                if self.pendingTitleMessage then
                    local message = self.pendingTitleMessage
                    self.pendingTitleMessage = nil
                    self:_cancel()
                    gStateMachine:change("title", message)
                    return
                end
                self.phase  = HOST_WAIT
                self.errMsg = net.STRINGS.peerDisconnected
            end
            event = NET.host:service(0)
        end

    elseif self.phase == CONNECTING then
        if not self.handshakeComplete then
            self.connectTimer = self.connectTimer + dt
            if self.connectTimer >= 5 then
                self:_resetToMenu(net.STRINGS.connectTimeout)
                return
            end
        end

        local event = NET.host:service(10)
        while event do
            if event.type == "connect" then
                NET.peer    = event.peer
                NET.peer:send(net.encodeHello(net.NET_PROTOCOL_VERSION), 1, "reliable")
                self.errMsg = "Connected. Waiting for handshake…"
            elseif event.type == "receive" then
                local msg = net.decode(event.data)
                if msg then
                    if msg.type == net.MSG_HELLO_OK then
                        self.handshakeComplete = true
                        self.errMsg = "Connected! Waiting for host to start…"
                    elseif msg.type == net.MSG_VERSION_MISMATCH then
                        self:_resetConnectionState()
                        gStateMachine:change(
                            "title",
                            net.formatVersionMismatch(
                                net.getGameVersion(),
                                msg.actualVersion,
                                msg.expectedVersion))
                        return
                    elseif msg.type == net.MSG_START then
                        NET.mode    = "client"
                        NET.localId = 2
                        gStateMachine:change("netclient")
                        return
                    end
                end
            elseif event.type == "disconnect" then
                if self.handshakeComplete then
                    self:_resetToMenu(net.STRINGS.peerDisconnected)
                else
                    self:_resetToMenu(net.STRINGS.connectTimeout)
                end
                return
            end
            event = NET.host:service(10)
        end
    end
end

function LobbyState:keypressed(key)
    if self.phase == MENU then
        if key == "h" then
            NET.host = net.enet.host_create("*:" .. net.PORT, 1, 2)
            if not NET.host then
                self.errMsg = string.format(net.STRINGS.portInUse, net.PORT)
                self.phase = MENU
                return
            end
            NET.mode    = "host"
            NET.localId = 1
            self.localIP  = net.getLocalIP()
            self.publicIP = "fetching…"
            self.pendingTitleMessage = nil
            -- Launch background thread to fetch public (WAN) IP
            self.pubIPThread = love.thread.newThread(PUBIP_THREAD)
            self.pubIPThread:start()
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
            if not NET.host then
                self:_resetToMenu(net.STRINGS.connectTimeout)
                return
            end
            NET.host:connect(self.ipInput .. ":" .. net.PORT, 2)
            self.phase    = CONNECTING
            self.connectTimer = 0
            self.handshakeComplete = false
            self.errMsg   = "Connecting to " .. self.ipInput .. "…"
        elseif key == "backspace" then
            self.ipInput = self.ipInput:sub(1, -2)
        elseif key == "escape" then
            self.phase  = MENU
            self.errMsg = ""
        end

    elseif self.phase == CONNECTING then
        if key == "escape" then
            self:_resetConnectionState()
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
    self:_resetConnectionState()
    self.phase    = MENU
    self.errMsg   = ""
    self.publicIP = ""
    self.pendingTitleMessage = nil
    -- Let the background thread finish naturally (it will push to the channel
    -- which we drain on the next init(), so no cleanup needed here)
end

function LobbyState:_resetConnectionState()
    if NET.peer then NET.peer:disconnect_now() end
    if NET.host then NET.host:destroy() end
    NET.host      = nil
    NET.peer      = nil
    NET.mode      = nil
    self.connectTimer = 0
    self.handshakeComplete = false
    self.pendingTitleMessage = nil
end

function LobbyState:_resetToMenu(message)
    self:_resetConnectionState()
    self.phase = MENU
    self.errMsg = message or ""
    self.publicIP = ""
end

function LobbyState:exit() end   -- host/peer kept alive for PlayState / NetClientState

function LobbyState:render()
    love.graphics.setColor(0.05, 0.05, 0.15)
    love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf("MULTIPLAYER", 0, 60, WINDOW_WIDTH, "center")
    love.graphics.setFont(self.font2)

    if self.phase == MENU then
        love.graphics.printf("H  –  HOST GAME",  0, 240, WINDOW_WIDTH, "center")
        love.graphics.printf("J  –  JOIN GAME",  0, 300, WINDOW_WIDTH, "center")
        love.graphics.printf("ESC  –  BACK",     0, 360, WINDOW_WIDTH, "center")
        -- Hint about internet play
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.printf("LAN: type the host's LAN IP   |   Internet: type the host's Public IP", 0, 460, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)

    elseif self.phase == HOST_WAIT then
        love.graphics.printf("Waiting for player to join…",     0, 200, WINDOW_WIDTH, "center")
        love.graphics.printf("LAN IP:    " .. self.localIP,     0, 255, WINDOW_WIDTH, "center")
        love.graphics.printf("Public IP: " .. self.publicIP,    0, 290, WINDOW_WIDTH, "center")
        love.graphics.printf("Port:      " .. net.PORT,         0, 325, WINDOW_WIDTH, "center")
        -- Internet play instructions
        love.graphics.setColor(0.9, 0.85, 0.4)
        love.graphics.printf("Internet play: forward UDP port " .. net.PORT .. " on your router", 0, 375, WINDOW_WIDTH, "center")
        love.graphics.printf("then share your Public IP with the other player", 0, 405, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ESC  –  cancel",                  0, 455, WINDOW_WIDTH, "center")

    elseif self.phase == HOST_READY then
        love.graphics.setColor(0.3, 1, 0.3)
        love.graphics.printf("Player connected!",        0, 250, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ENTER  –  start game",    0, 320, WINDOW_WIDTH, "center")
        love.graphics.printf("ESC  –  disconnect",      0, 380, WINDOW_WIDTH, "center")

    elseif self.phase == JOIN_INPUT then
        love.graphics.printf("Enter host IP address:",  0, 200, WINDOW_WIDTH, "center")
        love.graphics.setColor(0.9, 0.9, 0.4)
        love.graphics.printf(self.ipInput .. "_",       0, 260, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("ENTER to connect  |  ESC – back", 0, 330, WINDOW_WIDTH, "center")
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.printf("Same WiFi → use LAN IP   |   Internet → use Public IP", 0, 390, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)

    elseif self.phase == CONNECTING then
        love.graphics.printf(self.errMsg,    0, 300, WINDOW_WIDTH, "center")
        love.graphics.printf("ESC  –  cancel", 0, 370, WINDOW_WIDTH, "center")
    end

    if self.errMsg ~= "" and self.phase ~= CONNECTING then
        love.graphics.setColor(1, 0.4, 0.4)
        love.graphics.printf(self.errMsg, 0, 530, WINDOW_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
    end
end
