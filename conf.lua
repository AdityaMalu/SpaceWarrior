-- LÖVE reads this file BEFORE main.lua.  Keep it limited to love.conf;
-- do not run game-setup code here.
function love.conf(t)
    local ok, v = pcall(require, 'version')
    local version = (ok and type(v) == 'string') and v or 'dev'

    t.identity = 'SpaceWarrior'
    t.version  = '11.5'
    t.console  = false

    t.window.title = 'Space Warrior ' .. version
    t.window.icon  = 'assets/icon-256.png'
end
