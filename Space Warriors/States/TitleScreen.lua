TitleScreen=Class{__includes=BaseState}


function TitleScreen:init()
  self.bg=love.graphics.newImage("Assests/BG.png")
end


function TitleScreen:update(dt)
  if love.keyboard.isDown("return") then
    gStateMachine:change('play')
  end
end


function TitleScreen:render()
  love.graphics.draw(self.bg,0,0, 0, window_width/self.bg:getWidth(), window_height/self.bg:getHeight())
end
