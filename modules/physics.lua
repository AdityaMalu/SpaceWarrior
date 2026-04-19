-- modules/physics.lua  ─ Pure math helpers (no LÖVE dependency)
-- Extracted from states/PlayState.lua so the logic is unit-testable in plain Lua.

local physics = {}

-- Lua 5.3+ uses math.atan(y, x); LuaJIT 2.1 (LÖVE 11.x) still provides math.atan2.
local atan2 = math.atan2 or math.atan

-- Equal-mass elastic collision between two circular bodies.
--
-- Each body is a plain table: { x, y, angle, speed, radius }
--   x, y     — position
--   angle    — heading (radians); velocity is (cos*angle * speed, sin*angle * speed)
--   speed    — scalar speed along `angle`
--   radius   — collision radius (read-only)
--
-- Mutates a.x/a.y/a.angle/a.speed and b.x/b.y/b.angle/b.speed in place
-- when the bodies overlap. Returns nothing.
function physics.resolveElasticCollision(a, b)
    local dx   = b.x - a.x
    local dy   = b.y - a.y
    local dist = math.sqrt(dx * dx + dy * dy)
    local minDist = a.radius + b.radius
    if dist >= minDist or dist <= 0 then return end

    local nx = dx / dist
    local ny = dy / dist
    local vax = math.cos(a.angle) * a.speed
    local vay = math.sin(a.angle) * a.speed
    local vbx = math.cos(b.angle) * b.speed
    local vby = math.sin(b.angle) * b.speed
    local van = vax * nx + vay * ny
    local vbn = vbx * nx + vby * ny

    if van - vbn > 0 then   -- only resolve if approaching
        local r = 0.75
        local new_van = vbn * r
        local new_vbn = van * r
        local new_vax = vax + (new_van - van) * nx
        local new_vay = vay + (new_van - van) * ny
        local new_vbx = vbx + (new_vbn - vbn) * nx
        local new_vby = vby + (new_vbn - vbn) * ny
        local spda = math.sqrt(new_vax * new_vax + new_vay * new_vay)
        local spdb = math.sqrt(new_vbx * new_vbx + new_vby * new_vby)
        local MIN_SPEED, MAX_SPEED = 180, 350
        a.speed = math.max(MIN_SPEED, math.min(MAX_SPEED, spda))
        b.speed = math.max(MIN_SPEED, math.min(MAX_SPEED, spdb))
        if spda > 0.1 then a.angle = atan2(new_vay, new_vax) end
        if spdb > 0.1 then b.angle = atan2(new_vby, new_vbx) end
    end
    local overlap = (minDist - dist) / 2 + 1
    a.x = a.x - nx * overlap
    a.y = a.y - ny * overlap
    b.x = b.x + nx * overlap
    b.y = b.y + ny * overlap
end

return physics
