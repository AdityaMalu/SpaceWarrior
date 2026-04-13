-- modules/net.lua  ─ LAN Multiplayer networking utilities (Phase 2)
-- Architecture: authoritative host runs all physics; client is a thin renderer.
-- Protocol: enet (reliable UDP, bundled with LÖVE 11.x).

local net = {}

local enet_ok, enet = pcall(require, "enet")
if not enet_ok then enet = nil end
net.enet = enet

-- ── Message type constants ────────────────────────────────────────────────────
net.MSG_INPUT    = 1   -- client → host : rotate(B), shoot(B), usepower(B)
net.MSG_STATE    = 2   -- host → client : full game snapshot
net.MSG_START    = 3   -- host → client : "game is starting now"
net.MSG_GAMEOVER = 4   -- host → client : winner announced

net.PORT      = 22122
net.TICK_RATE = 1 / 20   -- host broadcasts state 20 times per second

-- ── Helpers ──────────────────────────────────────────────────────────────────
-- Returns the LAN IP of this machine using the UDP-routing trick (no data sent).
-- UDP sockets use setpeername() not connect() — connect() is TCP only.
function net.getLocalIP()
    local ok, ip = pcall(function()
        local socket = require("socket")
        local s = socket.udp()
        s:setpeername("8.8.8.8", 1)   -- UDP: setpeername, not connect
        local addr = s:getsockname()
        s:close()
        return addr
    end)
    if ok and ip and ip ~= "0.0.0.0" then return ip end
    return "see System Preferences › Network"
end

-- ── Simple encode helpers ─────────────────────────────────────────────────────
function net.encodeStart()
    return love.data.pack("string", "B", net.MSG_START)
end

-- winnerId: 1-based player index (0 = draw)
-- p1score/p2score: current round-win counts so the client can show the same score screen
function net.encodeGameOver(winnerId, p1score, p2score)
    return love.data.pack("string", "BBBB",
        net.MSG_GAMEOVER, winnerId or 0,
        math.min(p1score or 0, 255),
        math.min(p2score or 0, 255))
end

-- rotate / shoot / usepower: booleans
function net.encodeInput(rotate, shoot, usepower)
    return love.data.pack("string", "BBBB",
        net.MSG_INPUT,
        rotate   and 1 or 0,
        shoot    and 1 or 0,
        usepower and 1 or 0)
end

-- ── Full state encoder ────────────────────────────────────────────────────────
-- players      = PlayState.players  (array of Player objects)
-- allBullets   = PlayState.allBullets
-- Powersuplier = PlayState.Powersuplier
-- pendingpower = PlayState.pendingpower  (table indexed by player id)
-- gameOver, winnerId : end-of-round flags
function net.encodeState(players, allBullets, Powersuplier, pendingpower, gameOver, winnerId)
    local data = love.data.pack("string", "BB", net.MSG_STATE, #players)

    for i, p in ipairs(players) do
        local alive = (p.collider and p.collider.body) and 1 or 0
        local x     = alive == 1 and p.collider:getX() or 0
        local y     = alive == 1 and p.collider:getY() or 0
        local pp    = (pendingpower and pendingpower[i]) or 0
        data = data .. love.data.pack("string", "fffBBB",
            x, y, p.angle, alive, p.totalbullets or 0, pp)
    end

    -- Collect active bullet-shoot bodies from all players
    local blist = {}
    for i, pbullets in ipairs(allBullets) do
        for _, bobj in pairs(pbullets) do
            for _, sh in pairs(bobj.shoots) do
                if sh.body then
                    blist[#blist+1] = { x=sh:getX(), y=sh:getY(), owner=i }
                end
            end
        end
    end
    local nb = math.min(#blist, 200)
    data = data .. love.data.pack("string", "B", nb)
    for k = 1, nb do
        data = data .. love.data.pack("string", "ffB",
            blist[k].x, blist[k].y, blist[k].owner)
    end

    -- Collect active powerup boxes
    local plist = {}
    for _, sup in pairs(Powersuplier) do
        for _, box in pairs(sup.dabba) do
            if box.body then
                plist[#plist+1] = { x=box:getX(), y=box:getY(), choice=box.choice }
            end
        end
    end
    local np = math.min(#plist, 50)
    data = data .. love.data.pack("string", "B", np)
    for k = 1, np do
        data = data .. love.data.pack("string", "ffB",
            plist[k].x, plist[k].y, plist[k].choice)
    end

    data = data .. love.data.pack("string", "BB", gameOver and 1 or 0, winnerId or 0)
    return data
end

-- ── Decoder ──────────────────────────────────────────────────────────────────
-- Parses any incoming packet.  Returns a typed table or nil on error.
function net.decode(raw)
    if not raw or #raw < 1 then return nil end
    local msgType = love.data.unpack("B", raw, 1)

    if msgType == net.MSG_INPUT then
        if #raw < 4 then return nil end
        local _, r, s, u = love.data.unpack("BBBB", raw, 1)
        return { type=net.MSG_INPUT, rotate=r==1, shoot=s==1, usepower=u==1 }

    elseif msgType == net.MSG_STATE then
        local msg = { type=net.MSG_STATE, players={}, bullets={}, powerups={} }
        local _, np, pos = love.data.unpack("BB", raw, 1)
        for _ = 1, np do
            local x, y, ang, alive, tb, pp, npos = love.data.unpack("fffBBB", raw, pos)
            msg.players[#msg.players+1] = {
                x=x, y=y, angle=ang,
                alive=(alive==1), totalbullets=tb, pendingpower=pp,
            }
            pos = npos
        end
        local nb, bpos = love.data.unpack("B", raw, pos)
        pos = bpos
        for _ = 1, nb do
            local bx, by, bo, npos = love.data.unpack("ffB", raw, pos)
            msg.bullets[#msg.bullets+1] = { x=bx, y=by, owner=bo }
            pos = npos
        end
        local npu, ppos = love.data.unpack("B", raw, pos)
        pos = ppos
        for _ = 1, npu do
            local px, py, pc, npos = love.data.unpack("ffB", raw, pos)
            msg.powerups[#msg.powerups+1] = { x=px, y=py, choice=pc }
            pos = npos
        end
        local go, wi = love.data.unpack("BB", raw, pos)
        msg.gameOver = (go == 1)
        msg.winnerId = wi
        return msg

    elseif msgType == net.MSG_START then
        return { type=net.MSG_START }

    elseif msgType == net.MSG_GAMEOVER then
        if #raw < 4 then return nil end
        local _, wi, s1, s2 = love.data.unpack("BBBB", raw, 1)
        return { type=net.MSG_GAMEOVER, winnerId=wi, p1score=s1, p2score=s2 }
    end

    return nil
end

return net
