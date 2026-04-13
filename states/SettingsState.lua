SettingsState = Class{__includes = BaseState}

-- Action order and their KEY_BINDINGS field names
local ACTION_LABELS = {"Rotate", "Shoot", "Use Power"}
local ACTION_KEYS   = {"rotate", "shoot", "usepower"}

-- Per-player display colours (matching the in-game HUD)
local PLAYER_COLORS = {
    {1, 0.9, 0.2},   -- P1: yellow
    {0.3, 0.9, 1},   -- P2: cyan
    {0.3, 1, 0.3},   -- P3: green
    {1, 0.5, 0.3},   -- P4: orange
}

function SettingsState:init()
    self.fontTitle  = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 44)
    self.fontLabel  = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 20)
    self.fontKey    = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 18)
    self.fontFooter = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf", 14)
    self.background = love.graphics.newImage("assets/BG.png")

    self.selectedPlayer = 1     -- 1 .. MAX_PLAYERS
    self.selectedAction = 1     -- 1 = rotate, 2 = shoot, 3 = usepower
    self.waitingForKey  = false  -- true while listening for a new key press
end

function SettingsState:keypressed(key)
    if self.waitingForKey then
        if key == 'escape' then
            -- Cancel: keep old binding
            self.waitingForKey = false
        else
            -- Assign new key to selected slot
            KEY_BINDINGS[self.selectedPlayer][ACTION_KEYS[self.selectedAction]] = key
            self.waitingForKey = false
        end
        return
    end

    -- Navigation
    if key == 'left' then
        self.selectedPlayer = ((self.selectedPlayer - 2) % MAX_PLAYERS) + 1
    elseif key == 'right' then
        self.selectedPlayer = (self.selectedPlayer % MAX_PLAYERS) + 1
    elseif key == 'up' then
        self.selectedAction = ((self.selectedAction - 2) % #ACTION_LABELS) + 1
    elseif key == 'down' then
        self.selectedAction = (self.selectedAction % #ACTION_LABELS) + 1
    elseif key == 'return' or key == ' ' then
        self.waitingForKey = true
    elseif key == 'escape' then
        gStateMachine:change('title')
    end
end

function SettingsState:update() end
function SettingsState:enter() end
function SettingsState:exit()  end

function SettingsState:render()
    -- Background with dark overlay for readability
    love.graphics.draw(self.background, 0, 0, 0,
        WINDOW_WIDTH  / self.background:getWidth(),
        WINDOW_HEIGHT / self.background:getHeight())
    love.graphics.setColor(0, 0, 0, 0.72)
    love.graphics.rectangle("fill", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setColor(1, 1, 1)

    -- Title
    love.graphics.setFont(self.fontTitle)
    love.graphics.printf("KEY BINDINGS", 0, 28, WINDOW_WIDTH, "center")

    -- Grid layout
    local colW   = WINDOW_WIDTH / MAX_PLAYERS   -- width of each player column
    local rowH   = 110                           -- height of each action row
    local gridY  = 120                           -- top of player-header row
    local cellY0 = gridY + 52                    -- top of first action row

    -- Player column headers
    love.graphics.setFont(self.fontLabel)
    for p = 1, MAX_PLAYERS do
        local c = PLAYER_COLORS[p]
        love.graphics.setColor(c[1], c[2], c[3])
        love.graphics.printf("Player "..p, (p-1)*colW, gridY, colW, "center")
    end

    -- Action rows
    love.graphics.setFont(self.fontKey)
    for a = 1, #ACTION_LABELS do
        local cy = cellY0 + (a-1) * rowH

        for p = 1, MAX_PLAYERS do
            local cx        = (p-1) * colW
            local isSelected = (p == self.selectedPlayer and a == self.selectedAction)
            local pc        = PLAYER_COLORS[p]
            local boxX, boxW = cx + 14, colW - 28
            local boxH = 62

            -- Cell background
            if isSelected then
                love.graphics.setColor(pc[1], pc[2], pc[3], 0.25)
                love.graphics.rectangle("fill", boxX, cy, boxW, boxH, 8)
                love.graphics.setColor(pc[1], pc[2], pc[3])
                love.graphics.setLineWidth(2)
                love.graphics.rectangle("line", boxX, cy, boxW, boxH, 8)
                love.graphics.setLineWidth(1)
            else
                love.graphics.setColor(0.2, 0.2, 0.2, 0.55)
                love.graphics.rectangle("fill", boxX, cy, boxW, boxH, 8)
                love.graphics.setColor(0.45, 0.45, 0.45)
                love.graphics.rectangle("line", boxX, cy, boxW, boxH, 8)
            end

            -- Action label (only in first player column to avoid clutter)
            if p == 1 then
                love.graphics.setColor(0.7, 0.7, 0.7)
                love.graphics.print(ACTION_LABELS[a], boxX + 4, cy + 4)
            end

            -- Key name
            local keyText
            if isSelected and self.waitingForKey then
                keyText = "< press key >"
                love.graphics.setColor(1, 1, 0.4)
            else
                keyText = string.upper(KEY_BINDINGS[p][ACTION_KEYS[a]])
                love.graphics.setColor(isSelected and {1,1,1} or {0.65, 0.65, 0.65})
            end
            love.graphics.printf(keyText, boxX, cy + 34, boxW, "center")
        end
    end

    -- Footer hint
    love.graphics.setFont(self.fontFooter)
    love.graphics.setColor(0.55, 0.55, 0.55)
    love.graphics.printf(
        "LEFT / RIGHT: player    UP / DOWN: action    ENTER: rebind    ESC: back",
        0, WINDOW_HEIGHT - 36, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)
end
