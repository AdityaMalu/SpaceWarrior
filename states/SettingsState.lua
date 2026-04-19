SettingsState = Class{__includes = BaseState}

local audio = require 'modules.audio'

-- Action order and their KEY_BINDINGS field names
local ACTION_LABELS = {"Rotate", "Shoot", "Use Power"}
local ACTION_KEYS   = {"rotate", "shoot", "usepower"}
local VOLUME_LABELS = {"Master", "Music", "SFX"}
local VOLUME_KEYS   = {"master", "music", "sfx"}

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
    self.previewMusic = audio.newSource("assets/Sounds/SkyFire (Title Screen).ogg", "static", "music")
    self.previewMusic:setVolume(0.5)
    self.previewMusic:setLooping(true)
    self.previewMusic:play()

    self.selectedPlayer = 1     -- 1 .. MAX_PLAYERS
    self.selectedAction = 1     -- 1 = rotate, 2 = shoot, 3 = usepower
    self.selectedSection = 'bindings'
    self.selectedAudio = 1
    self.waitingForKey  = false  -- true while listening for a new key press
end

local function clampVolume(value)
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

function SettingsState:adjustVolume(delta)
    local key = VOLUME_KEYS[self.selectedAudio]
    AUDIO_VOLUMES[key] = clampVolume((AUDIO_VOLUMES[key] or 0) + delta)
    audio.apply()
end

function SettingsState:keypressed(key)
    if self.waitingForKey then
        if key == 'escape' then
            -- Cancel: keep old binding
            self.waitingForKey = false
        else
            -- Assign new key to selected slot and persist immediately.
            KEY_BINDINGS[self.selectedPlayer][ACTION_KEYS[self.selectedAction]] = key
            self.waitingForKey = false
            if settings and settings.save then
                settings.save()
            end
        end
        return
    end

    if key == 'escape' then
        gStateMachine:change('title')
        return
    end

    -- Navigation
    if key == 'left' then
        if self.selectedSection == 'bindings' then
            self.selectedPlayer = ((self.selectedPlayer - 2) % MAX_PLAYERS) + 1
        else
            self:adjustVolume(-0.05)
        end
    elseif key == 'right' then
        if self.selectedSection == 'bindings' then
            self.selectedPlayer = (self.selectedPlayer % MAX_PLAYERS) + 1
        else
            self:adjustVolume(0.05)
        end
    elseif key == 'up' then
        if self.selectedSection == 'bindings' then
            if self.selectedAction == 1 then
                self.selectedSection = 'audio'
                self.selectedAudio = #VOLUME_LABELS
            else
                self.selectedAction = self.selectedAction - 1
            end
        elseif self.selectedAudio == 1 then
            self.selectedSection = 'bindings'
            self.selectedAction = #ACTION_LABELS
        else
            self.selectedAudio = self.selectedAudio - 1
        end
    elseif key == 'down' then
        if self.selectedSection == 'bindings' then
            if self.selectedAction == #ACTION_LABELS then
                self.selectedSection = 'audio'
                self.selectedAudio = 1
            else
                self.selectedAction = self.selectedAction + 1
            end
        elseif self.selectedAudio == #VOLUME_LABELS then
            self.selectedSection = 'bindings'
            self.selectedAction = 1
        else
            self.selectedAudio = self.selectedAudio + 1
        end
    elseif key == 'return' or key == ' ' then
        if self.selectedSection == 'bindings' then
            self.waitingForKey = true
        elseif settings and settings.save then
            settings.save()
        end
    end
end

function SettingsState:update() end
function SettingsState:enter() end
function SettingsState:exit()
    self.previewMusic:stop()
end

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
    love.graphics.printf("SETTINGS", 0, 20, WINDOW_WIDTH, "center")

    -- Grid layout
    local colW   = WINDOW_WIDTH / MAX_PLAYERS   -- width of each player column
    local rowH   = 88                            -- height of each action row
    local gridY  = 96                            -- top of player-header row
    local cellY0 = gridY + 44                    -- top of first action row

    love.graphics.setFont(self.fontLabel)
    love.graphics.printf("Key Bindings", 0, 72, WINDOW_WIDTH, "center")

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
            local isSelected = self.selectedSection == 'bindings'
                and p == self.selectedPlayer and a == self.selectedAction
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
                if isSelected then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(0.65, 0.65, 0.65)
                end
            end
            love.graphics.printf(keyText, boxX, cy + 34, boxW, "center")
        end
    end

    love.graphics.setFont(self.fontLabel)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Audio", 0, 430, WINDOW_WIDTH, "center")

    local sliderX = 360
    local sliderW = 360
    local sliderH = 18
    local sliderY = 480
    local rowGap = 48
    for i = 1, #VOLUME_LABELS do
        local y = sliderY + (i - 1) * rowGap
        local value = AUDIO_VOLUMES[VOLUME_KEYS[i]] or 0
        local isSelected = self.selectedSection == 'audio' and self.selectedAudio == i

        if isSelected then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle('line', sliderX - 12, y - 10, sliderW + 110, sliderH + 20, 8)
        end

        love.graphics.setColor(0.75, 0.75, 0.75)
        love.graphics.printf(VOLUME_LABELS[i], 180, y - 4, 150, 'left')
        love.graphics.setColor(0.2, 0.2, 0.2, 0.9)
        love.graphics.rectangle('fill', sliderX, y, sliderW, sliderH, 8)
        love.graphics.setColor(0.3, 0.9, 1, 0.9)
        love.graphics.rectangle('fill', sliderX, y, sliderW * value, sliderH, 8)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('line', sliderX, y, sliderW, sliderH, 8)
        love.graphics.printf(string.format('%d%%', math.floor(value * 100 + 0.5)),
            sliderX + sliderW + 20, y - 4, 90, 'left')
    end

    -- Footer hint
    love.graphics.setFont(self.fontFooter)
    love.graphics.setColor(0.55, 0.55, 0.55)
    love.graphics.printf(
        "BINDINGS: LEFT/RIGHT player, UP/DOWN action, ENTER rebind    AUDIO: UP/DOWN select, LEFT/RIGHT adjust, ENTER save    ESC: back",
        0, WINDOW_HEIGHT - 36, WINDOW_WIDTH, "center")
    love.graphics.setColor(1, 1, 1)
end
