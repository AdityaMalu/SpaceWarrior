-- spec/net_spec.lua ─ busted tests for modules.net encode/decode round-trips.
-- Uses spec/helper.lua to stub love.data.pack / love.data.unpack with the
-- pure-Lua string.pack / string.unpack equivalents.

require 'spec.helper'
local net = require 'modules.net'

-- ── Tiny collider fixture ────────────────────────────────────────────────────
-- Mimics the subset of the windfield collider API that modules/net.lua reads:
--   body   — truthy flag ("is this collider alive?")
--   :getX() / :getY() — current position
local function fakeCollider(x, y)
    return {
        body  = true,
        getX  = function(self) return self._x end,
        getY  = function(self) return self._y end,
        _x = x, _y = y,
    }
end

describe("net encode/decode round-trips", function()

    it("MSG_START: decodes back to a MSG_START table", function()
        local raw = net.encodeStart()
        local msg = net.decode(raw)
        assert.are.equal(net.MSG_START, msg.type)
    end)

    it("MSG_GAMEOVER: preserves winnerId and per-player scores", function()
        local raw = net.encodeGameOver(2, 3, 4)
        local msg = net.decode(raw)
        assert.are.equal(net.MSG_GAMEOVER, msg.type)
        assert.are.equal(2, msg.winnerId)
        assert.are.equal(3, msg.p1score)
        assert.are.equal(4, msg.p2score)
    end)

    it("MSG_GAMEOVER: clamps scores above 255 into a byte (protocol limit)", function()
        local raw = net.encodeGameOver(0, 999, 1000)
        local msg = net.decode(raw)
        assert.are.equal(0, msg.winnerId)
        assert.are.equal(255, msg.p1score)
        assert.are.equal(255, msg.p2score)
    end)

    it("MSG_INPUT: boolean flags round-trip true/false combinations", function()
        local combos = {
            { true,  true,  true  },
            { false, false, false },
            { true,  false, true  },
            { false, true,  false },
        }
        for _, c in ipairs(combos) do
            local rotate, shoot, usepower = c[1], c[2], c[3]
            local raw = net.encodeInput(rotate, shoot, usepower)
            local msg = net.decode(raw)
            assert.are.equal(net.MSG_INPUT, msg.type)
            assert.are.equal(rotate,   msg.rotate)
            assert.are.equal(shoot,    msg.shoot)
            assert.are.equal(usepower, msg.usepower)
        end
    end)

    it("MSG_STATE: round-trips a minimal two-player snapshot with no entities", function()
        local players = {
            { collider = fakeCollider(10, 20), angle = 0,           totalbullets = 3 },
            { collider = fakeCollider(30, 40), angle = math.pi / 2, totalbullets = 1 },
        }
        local raw = net.encodeState(players, {}, {}, { [1] = 2, [2] = 0 }, false, 0)
        local msg = net.decode(raw)
        assert.are.equal(net.MSG_STATE, msg.type)
        assert.are.equal(2, #msg.players)
        assert.are.equal(10, msg.players[1].x)
        assert.are.equal(20, msg.players[1].y)
        assert.is_true(msg.players[1].alive)
        assert.are.equal(3, msg.players[1].totalbullets)
        assert.are.equal(2, msg.players[1].pendingpower)
        assert.are.equal(1, msg.players[2].totalbullets)
        assert.are.equal(false, msg.gameOver)
        assert.are.equal(0,     msg.winnerId)
        assert.are.equal(0, #msg.bullets)
        assert.are.equal(0, #msg.powerups)
        assert.are.equal(0, #msg.lasers)
        assert.are.equal(0, #msg.bombs)
        assert.are.equal(0, #msg.scattershots)
    end)

    it("MSG_STATE: round-trips bullets, powerups, lasers, bombs, scattershots", function()
        local players = { { collider = fakeCollider(0, 0), angle = 0, totalbullets = 0 } }

        -- One regular bullet owned by player 1
        local allBullets = {
            [1] = { { shoots = { fakeCollider(100, 200) } } },
        }

        -- One powerup box with choice 2
        local powersuplier = { {
            dabba = { (function()
                local c = fakeCollider(50, 60); c.choice = 2; return c
            end)() },
        } }

        -- One laser for player 1
        local lasers = { [1] = { { laser = { body = true }, x1 = 1, y1 = 2, x2 = 3, y2 = 4 } } }

        -- One bomb for player 1 with a growing explosion radius
        local bombs = { [1] = { { collider = fakeCollider(70, 80), growingradius = 12 } } }

        -- Two scatter shots emitted by player 1's scattershot emitter
        local scattershots = { [1] = { {
            shots = { fakeCollider(5, 6), fakeCollider(7, 8) },
        } } }

        local raw = net.encodeState(players, allBullets, powersuplier,
            { [1] = 0 }, true, 1, lasers, bombs, scattershots)
        local msg = net.decode(raw)

        assert.are.equal(true, msg.gameOver)
        assert.are.equal(1,    msg.winnerId)

        assert.are.equal(1,   #msg.bullets)
        assert.are.equal(100, msg.bullets[1].x)
        assert.are.equal(200, msg.bullets[1].y)
        assert.are.equal(1,   msg.bullets[1].owner)

        assert.are.equal(1,  #msg.powerups)
        assert.are.equal(50, msg.powerups[1].x)
        assert.are.equal(60, msg.powerups[1].y)
        assert.are.equal(2,  msg.powerups[1].choice)

        assert.are.equal(1, #msg.lasers)
        assert.are.same({ x1 = 1, y1 = 2, x2 = 3, y2 = 4 }, msg.lasers[1])

        assert.are.equal(1,  #msg.bombs)
        assert.are.equal(70, msg.bombs[1].x)
        assert.are.equal(80, msg.bombs[1].y)
        assert.are.equal(12, msg.bombs[1].r)

        assert.are.equal(2, #msg.scattershots)
        assert.are.equal(5, msg.scattershots[1].x)
        assert.are.equal(8, msg.scattershots[2].y)
    end)

    it("decode returns nil for an empty packet", function()
        assert.is_nil(net.decode(""))
        assert.is_nil(net.decode(nil))
    end)

end)
