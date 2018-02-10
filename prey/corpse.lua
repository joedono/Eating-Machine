Corpse = Class {
	init = function (self, parentManager, x, y, bloodEffect)
		self.parentManager = parentManager;
		self.bloodEffect = bloodEffect:clone();
		self.bloodEffect:start();

		self.box = {
			x = x - CORPSE_SIZE / 2,
			y = y - CORPSE_SIZE / 2,
			w = CORPSE_SIZE,
			h = CORPSE_SIZE
		};

		BumpWorld:add(self, self.box.x, self.box.y, self.box.w, self.box.h);

		self.aliveTimer = CORPSE_TIMER;
		self.type = "corpse";
		self.active = true;
	end
}

function Corpse:update(dt)
	if not self.active then
		return;
	end

	self.bloodEffect:update(dt);

	if self.aliveTimer < 0 then
		self.bloodEffect:setEmissionRate(0);

		if self.bloodEffect:getCount() == 0 then
			self.bloodEffect:stop();
			self.active = false;
		end
	else
		self.aliveTimer = self.aliveTimer - dt;
	end
end

function Corpse:eat(dt)
	if self.aliveTimer > 0 then
		self.aliveTimer = self.aliveTimer - dt * CORPSE_EAT_RATE;
	end
end

function Corpse:draw()
	love.graphics.setColor(255, 255, 255);
	love.graphics.draw(self.bloodEffect, self.box.x + self.box.w / 2, self.box.y + self.box.h / 2);

	if DRAW_BOXES then
		love.graphics.setColor(0, 0, 255);
		love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.w, self.box.h);
	end
end