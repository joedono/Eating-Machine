State_Pause = {};

function State_Pause:init()
	self.font = love.graphics.newFont(36);
end

function State_Pause:enter(from)
	self.from = from;
end

function State_Pause:keypressed(key, scancode, isrepeat)
	if key == KEY_START then
		GameState.pop();
	end
end

function State_Pause:gamepadpressed(joystick, button)
	if button == GAMEPAD_START then
		GameState.pop();
	end
end

function State_Pause:draw()
	self.from:draw();

	love.graphics.setColor(0, 0, 0, 150);
	love.graphics.rectangle("fill", CANVAS_OFFSET_X, CANVAS_OFFSET_Y, SCREEN_WIDTH * CANVAS_SCALE, SCREEN_HEIGHT * CANVAS_SCALE);

	love.graphics.setFont(self.font);
	love.graphics.setColor(255, 255, 255);
	love.graphics.printf("PAUSED", 0, CANVAS_OFFSET_Y + SCREEN_HEIGHT * CANVAS_SCALE / 2 - 100, SCREEN_WIDTH * CANVAS_SCALE, "center");
end