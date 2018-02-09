State_Losing = {};

function State_Losing:enter(from)
	self.from = from;
	self.effect = {
		r = 50,
		a = 0,
    y = SCREEN_HEIGHT
	};

	Timer.clear();
	Timer.script(function(wait)
		Timer.tween(6, self.effect, { r = 180, a = 255, y = 0 }, "in-linear");
    wait(6);
		self:onDone();
	end);
end

function State_Losing:onDone()
	GameState.switch(State_Lost);
end

function State_Losing:update(dt)
	Timer.update(dt);
end

function State_Losing:draw()
	self.from:draw();

	love.graphics.setColor(self.effect.r, 0, 0, self.effect.a);
	love.graphics.rectangle("fill", 0, self.effect.y, SCREEN_WIDTH, SCREEN_HEIGHT - self.effect.y);
end