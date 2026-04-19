-- spec/helper.lua ─ Minimal LÖVE stub for unit tests of pure modules.
--
-- modules/net.lua is the only production module under test that touches the
-- LÖVE API, and only through love.data.pack / love.data.unpack.  Lua 5.3+
-- ships string.pack / string.unpack with the same format strings we use
-- ("B", "BB", "f", "ff", "BBBB", "fffBBB", "ffff", "fff", …), so a
-- pass-through implementation is sufficient for round-trip tests.
--
-- This file is intentionally standalone so individual spec files can load it
-- with `require 'spec.helper'` regardless of whether busted is invoked from
-- the project root or the spec/ directory.

local M = {}

love = love or {}
love.data = love.data or {}

if not love.data.pack then
    -- `container` is ignored: LÖVE accepts "string" or "data"; we always return
    -- a plain Lua string which is what net.lua feeds back into love.data.unpack.
    function love.data.pack(_container, fmt, ...)
        return string.pack(fmt, ...)
    end
end

if not love.data.unpack then
    function love.data.unpack(fmt, data, pos)
        return string.unpack(fmt, data, pos)
    end
end

return M
