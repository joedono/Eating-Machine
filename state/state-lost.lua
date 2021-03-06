State_Lost = {};

function State_Lost:init()
	self.titleFont = love.graphics.newFont("asset/font/Arial-Bold.ttf", 50);
	self.helpFont = love.graphics.newFont("asset/font/Arial-Bold.ttf", 16);
end

function State_Lost:enter()
	love.graphics.setBackgroundColor(180, 0, 0);
	self.inputEnabled = false;
	self.alphas = {
		titleAlpha = 0,
		helpAlpha = 0
	};

	Timer.clear();
	Timer.script(function(wait)
		Timer.tween(4, self.alphas, { titleAlpha = 255 }, "in-linear");
    wait(4);
		self.inputEnabled = true;
		Timer.tween(4, self.alphas, { helpAlpha = 255 }, "in-linear");
	end);
end

function State_Lost:keypressed(key, unicode)
	if not self.inputEnabled then
		return;
	end

	GameState.switch(State_Title);
end

function State_Lost:gamepadpressed(joystick, button)
	if not self.inputEnabled then
		return;
	end

	GameState.switch(State_Title);
end

function State_Lost:update(dt)
	Timer.update(dt);
end

function State_Lost:draw()
	CANVAS:renderTo(function()
    love.graphics.clear();
		love.graphics.setColor(0, 0, 0, self.alphas.titleAlpha);
		love.graphics.setFont(self.titleFont);
		love.graphics.printf("You lose", 0, 200, SCREEN_WIDTH, "center");

		love.graphics.setColor(0, 0, 0, self.alphas.helpAlpha);
		love.graphics.setFont(self.helpFont);
		love.graphics.printf("Press any key", 0, 350, SCREEN_WIDTH, "center");
  end);

  love.graphics.setColor(255, 255, 255);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end