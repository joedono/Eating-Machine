State_Game = {};

function State_Game:init()
	BumpWorld = Bump.newWorld(32);

	self.oceanImage = love.graphics.newImage("asset/image/ocean.png");
end

function State_Game:focus(focused)
  if focused then
    self.active = true;
  else
    self.active = false;
  end
end

function State_Game:keypressed(key, unicode)
	if not self.active then
    return;
  end

end

function State_Game:keyreleased(key, unicode)
	if not self.active then
    return;
  end
end

function State_Game:gamepadpressed(joystick, button)
  if not self.active then
    return;
  end
end

function State_Game:gamepadreleased(joystick, button)
  if not self.active then
    return;
  end
end

function State_Game:gamepadaxis(joystick, axis, value)

end

function State_Game:update(dt)
	if not self.active then
    return;
  end
end

function State_Game:draw()
	CANVAS:renderTo(function()
		love.graphics.clear();
    love.graphics.setColor(255, 255, 255);
    love.graphics.draw(self.oceanImage, 0, 0);
  end);

  love.graphics.setColor(255, 255, 255);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end