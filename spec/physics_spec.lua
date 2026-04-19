-- spec/physics_spec.lua ─ busted tests for modules.physics
-- Runs in plain Lua 5.3+ (no LÖVE needed).

require 'spec.helper'
local physics = require 'modules.physics'

local function body(x, y, angle, speed, radius)
    return { x = x, y = y, angle = angle, speed = speed, radius = radius }
end

local function clone(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end

describe("physics.resolveElasticCollision", function()

    it("does nothing when bodies are farther apart than the sum of radii", function()
        local a = body(0,   0, 0,       300, 20)
        local b = body(100, 0, math.pi, 300, 20)
        local a0, b0 = clone(a), clone(b)
        physics.resolveElasticCollision(a, b)
        assert.are.same(a0, a)
        assert.are.same(b0, b)
    end)

    it("does nothing when the two bodies share the same position (dist == 0)", function()
        local a = body(50, 50, 0,       300, 20)
        local b = body(50, 50, math.pi, 300, 20)
        local a0, b0 = clone(a), clone(b)
        physics.resolveElasticCollision(a, b)
        assert.are.same(a0, a)
        assert.are.same(b0, b)
    end)

    it("pushes overlapping, approaching bodies apart along the collision normal", function()
        -- Head-on along +x: a moving right (angle 0), b moving left (angle pi).
        local a = body(0,  0, 0,       300, 20)
        local b = body(30, 0, math.pi, 300, 20)  -- dist 30, minDist 40 → overlap 10
        physics.resolveElasticCollision(a, b)
        -- a is pushed -x, b is pushed +x along the normal (which is +x)
        assert.is_true(a.x < 0)
        assert.is_true(b.x > 30)
        -- Pure x-axis collision: no y displacement.
        assert.are.equal(0, a.y)
        assert.are.equal(0, b.y)
    end)

    it("clamps post-collision speeds into [180, 350]", function()
        -- Very high speeds should be clamped down to MAX_SPEED=350.
        local a = body(0,  0, 0,       10000, 20)
        local b = body(30, 0, math.pi, 10000, 20)
        physics.resolveElasticCollision(a, b)
        assert.is_true(a.speed <= 350 + 1e-6)
        assert.is_true(b.speed <= 350 + 1e-6)
        assert.is_true(a.speed >= 180 - 1e-6)
        assert.is_true(b.speed >= 180 - 1e-6)
    end)

    it("leaves angles / speeds unchanged when bodies are moving apart", function()
        -- Overlapping but separating: a moving -x, b moving +x → normal-rel vel < 0.
        local a = body(0,  0, math.pi, 300, 20)
        local b = body(30, 0, 0,       300, 20)
        local angA, spdA = a.angle, a.speed
        local angB, spdB = b.angle, b.speed
        physics.resolveElasticCollision(a, b)
        -- Velocity-modifying branch is skipped, so angle/speed are untouched.
        assert.are.equal(angA, a.angle)
        assert.are.equal(spdA, a.speed)
        assert.are.equal(angB, b.angle)
        assert.are.equal(spdB, b.speed)
        -- Overlap resolution still runs: positions are pushed apart.
        assert.is_true(a.x < 0)
        assert.is_true(b.x > 30)
    end)

    it("swaps velocity components along the normal for equal-mass bodies", function()
        -- Head-on along +x at equal speed; the along-normal component is simply
        -- swapped and scaled by r=0.75, so magnitudes should match post-collision.
        local a = body(0,  0, 0,       300, 20)
        local b = body(30, 0, math.pi, 300, 20)
        physics.resolveElasticCollision(a, b)
        assert.is_true(math.abs(a.speed - b.speed) < 1e-3)
    end)

end)
