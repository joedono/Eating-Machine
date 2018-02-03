State_Title = {};

function State_Title:init()
  self.font = love.graphics.newFont(12);
end

function State_Title:keypressed(key, unicode)
  GameState.switch(State_Game);
end

function State_Title:gamepadpressed(joystick, button)
  GameState.switch(State_Game);
end

function State_Title:draw()
	CANVAS:renderTo(function()
    love.graphics.clear();
    love.graphics.setFont(self.font);
		love.graphics.setColor(255, 0, 0);
    love.graphics.printf("Eating Machine", 0, 200, SCREEN_WIDTH, "center");
		love.graphics.setColor(255, 255, 255, 255);
  end);

  love.graphics.setColor(255, 255, 255);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end