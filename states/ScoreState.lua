ScoreState = Class{__includes = BaseState}

function ScoreState:init()
  --self.count = count
  --self.count1 = count1
  self.font = love.graphics.newFont("libraries/Bungee/BungeeSpice-Regular.ttf",30)

end

function ScoreState:update(dt)
  if love.keyboard.isDown("return") then
    gStateMachine:change("play")
  end

  if count >5 or count1 >5 then
    gStateMachine:change("end")
  end
end



function ScoreState:render()
  love.graphics.print(count,0,0)
  love.graphics.print(count1,0,50)
  love.graphics.line(400,100, 800,100)
  love.graphics.line(600,100,600,600)
  love.graphics.line(400,100,400,600)
  love.graphics.line(800,100,800,600)
  love.graphics.line(400,600,800,600)
  love.graphics.line(400,500,800,500)
  love.graphics.line(400,400,800,400)
  love.graphics.line(400,300,800,300)
  love.graphics.line(400,200,800,200)
  love.graphics.setFont(self.font)
  love.graphics.print("Player 1",420,50)
  love.graphics.print("Player 2",620,50)

  if self.count == 1 then
    love.graphics.print("1",490,120)
  end

end
