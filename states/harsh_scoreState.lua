NewScoreState = Class{__includes = BaseState}
function NewScoreState:enter(winner)
    print(winner)
    self.player1ProgressMeter = {}
    self.player1ProgressMeter.radius = 30
    self.player1ProgressMeter.x = WINDOW_WIDTH/2 - 100
    -- self.player1ProgressMeter.y = 550 + 50
    self.player1ProgressMeter.y = (6 - PLAYER1_SCORE) * 100 + 100

    if winner == "player1" then
        self.player1CurrentPosition = self.player1ProgressMeter.y + 100
    else
        self.player1CurrentPosition = self.player1ProgressMeter.y
    end
    

    -- player2
    self.player2ProgressMeter = {}
    self.player2ProgressMeter.radius = 30
    self.player2ProgressMeter.x = WINDOW_WIDTH/2 + 100
    self.player2ProgressMeter.y = (6 - PLAYER2_SCORE) * 100 + 100

    if winner == "player2" then
        self.player2CurrentPosition = self.player2ProgressMeter.y + 100
    else
        self.player2CurrentPosition = self.player2ProgressMeter.y
    end
end

function NewScoreState:init()
    self.progressTable = {}
    for i = 0, 5 do
        table.insert(self.progressTable, {{WINDOW_WIDTH/2 - 200, 50 + i * 100}, {WINDOW_WIDTH/2, 50 + i * 100}})
    end

    self.background = love.graphics.newImage("assets/Background/b3.png")
    self.player1image = love.graphics.newImage("assets/player1.png")
    self.player2image = love.graphics.newImage("assets/player2.png")
    self.tablegraphics = love.graphics.newImage("assets/line.png")
    self.sounds = love.audio.newSource("assets/Sounds/scorestate.wav","static")
    self.sounds:setVolume(0.5)
    self.sounds:setLooping(true)
    self.sounds:play()
    -- player 1
    

    -- animationSpeed
    self.animationSpeed = 100
end

function NewScoreState:update(dt)
    if self.player1CurrentPosition > self.player1ProgressMeter.y then
        self.player1CurrentPosition = self.player1CurrentPosition - self.animationSpeed * dt / 2
    end

    if self.player2CurrentPosition > self.player2ProgressMeter.y then
        self.player2CurrentPosition = self.player2CurrentPosition - self.animationSpeed * dt / 2
    end
    if self.player1CurrentPosition <= self.player1ProgressMeter.y and self.player2CurrentPosition <= self.player2ProgressMeter.y then
        gStateMachine:change('play')
    end

    if PLAYER1_SCORE == 6 then
        gStateMachine:change("end")
    end

    if PLAYER2_SCORE == 6 then 
        gStateMachine:change("end")
    end
end

function NewScoreState:exit()
    self.sounds:stop()
end



function NewScoreState:render()

    love.graphics.draw(self.background,0,0,0,WINDOW_WIDTH/self.background:getWidth(),WINDOW_HEIGHT/self.background:getHeight())
    for i = 1, 6 do
        love.graphics.rectangle("line", self.progressTable[i][1][1], self.progressTable[i][1][2], 200, 100)
        love.graphics.rectangle("line", self.progressTable[i][2][1], self.progressTable[i][2][2], 200, 100)
    end

    -- draw player 1
    --love.graphics.circle("fill", self.player1ProgressMeter.x, self.player1ProgressMeter.y, self.player1ProgressMeter.radius)
    love.graphics.draw(self.player1image,self.player1ProgressMeter.x-20, self.player1CurrentPosition-20)
    --love.graphics.circle("fill", self.player1ProgressMeter.x, self.player1CurrentPosition, self.player1ProgressMeter.radius)

    --draw player 2
    --love.graphics.circle("fill", self.player2ProgressMeter.x, self.player2ProgressMeter.y, self.player2ProgressMeter.radius)
    love.graphics.draw(self.player2image,self.player2ProgressMeter.x-20, self.player2CurrentPosition-20)
    --love.graphics.circle("fill", self.player2ProgressMeter.x, self.player2CurrentPosition, self.player2ProgressMeter.radius)
end