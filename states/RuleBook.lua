RuleBook= Class{__includes = BaseState}

function RuleBook:init()
    self.bg = love.graphics.newImage("assets/rules.png")
    self.timer =0 
end

function RuleBook:update()
    if love.keyboard.isDown("return")  then
        gStateMachine:change("play")
    end    


end

function RuleBook:render()
    love.graphics.draw(self.bg,0,0,0,WINDOW_WIDTH/self.bg:getWidth(),WINDOW_HEIGHT/self.bg:getHeight())

end