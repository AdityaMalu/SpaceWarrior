CreditsState = Class{__includes = BaseState}

local REPO_URL = "https://github.com/AdityaMalu/SpaceWarrior"

-- Game contributors.  New names added here in alphabetical order.
local CONTRIBUTORS = {
    "Aditya Malu",
    "Vedant Chakkarwar",
}

-- Third-party assets / libraries bundled with the game.
local CREDITS_LIBS = {
    "windfield - Box2D wrapper (a327ex)",
    "Simple-Tiled-Implementation (karai17)",
    "anim8 - animation helper (kikito)",
    "push - resolution manager (Ulysse Ramage)",
    "Bungee Spice font (The Bungee Project)",
}

function CreditsState:init()
    self.background = love.graphics.newImage("assets/BG.png")
    self.fontTitle  = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 48)
    self.fontLabel  = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 22)
    self.fontLine   = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 18)
    self.fontFooter = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 14)
end

function CreditsState:keypressed(key)
    if key == 'escape' or key == 'return' then
        gStateMachine:change('title')
    end
end

function CreditsState:render()
    love.graphics.draw(self.background, 0, 0, 0,
        WINDOW_WIDTH  / self.background:getWidth(),
        WINDOW_HEIGHT / self.background:getHeight())

    love.graphics.setFont(self.fontTitle)
    love.graphics.printf("Credits", 0, 40, WINDOW_WIDTH, "center")

    love.graphics.setFont(self.fontLabel)
    love.graphics.setColor(1, 0.9, 0.2)
    love.graphics.printf("Space Warrior  v" .. tostring(GAME_VERSION),
        0, 120, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)

    local y = 180
    love.graphics.setFont(self.fontLabel)
    love.graphics.printf("Contributors", 0, y, WINDOW_WIDTH, "center")
    y = y + 40
    love.graphics.setFont(self.fontLine)
    for _, name in ipairs(CONTRIBUTORS) do
        love.graphics.printf(name, 0, y, WINDOW_WIDTH, "center")
        y = y + 28
    end

    y = y + 30
    love.graphics.setFont(self.fontLabel)
    love.graphics.printf("Libraries & Assets", 0, y, WINDOW_WIDTH, "center")
    y = y + 40
    love.graphics.setFont(self.fontLine)
    for _, line in ipairs(CREDITS_LIBS) do
        love.graphics.printf(line, 0, y, WINDOW_WIDTH, "center")
        y = y + 26
    end

    love.graphics.setFont(self.fontFooter)
    love.graphics.setColor(0.7, 0.9, 1)
    love.graphics.printf(REPO_URL, 0, WINDOW_HEIGHT - 60, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("PRESS ESC TO GO BACK", 0, WINDOW_HEIGHT - 30, WINDOW_WIDTH, "center")
end
