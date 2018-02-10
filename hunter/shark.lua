Shark = Class {
	init = function (self, parentManager, x, y, sharkImage, sharkImageData, sharkAnimation)
		self.parentManager = parentManager;
		self.image = sharkImage;
		self.imageData = sharkImageData;
		self.animation = sharkAnimation:clone();

		self.box = {
			x = x,
			y = y,
			w = SHARK_SIZE,
			h = SHARK_SIZE
		};
		self.velocity = { x = 0, y = 0 };
		self.facing = { x = 0, y = 1 };

		BumpWorld:add(self, self.box.x, self.box.y, self.box.w, self.box.h);

		self.state = "entering";
		self.stateTimer = love.math.random(1, 3);
		self.leaveTimer = love.math.random(10, 20);
		self.type = "shark";
		self.active = true;
	end
}

function Shark:update(dt)
	if not self.active then
		return;
	end

	if self.stateTimer > 0 then
		self.stateTimer = self.stateTimer - dt;
	end

	if self.leaveTimer > 0 then
		self.leaveTimer = self.leaveTimer - dt;
	end

	if self.leaveTimer <= 0 then
		self.state = "leaving";
	end

	if self.state == "entering" then
		self:updateEntering(dt);
	elseif self.state == "treading" then
		self:updateTreading(dt);
	elseif self.state == "swimming" then
		self:updateSwimming(dt);
	elseif self.state == "hunting" then
		self:updateHunting(dt);
	elseif self.state == "eating" then
		self:updateEating(dt);
	elseif self.state == "leaving" then
		self:updateLeaving(dt);
	elseif self.state == "dead" then
		self.active = false;
	end

	self.animation:update(dt);
	self:updatePosition(dt);
	self:updateRotation(dt);
end

function Shark:updateEntering(dt)
	if self:canSenseBlood() then
		self:huntBlood();
	end

	self.velocity.y = SHARK_SPEED;

	if self.stateTimer <= 0 then
		self.velocity.y = 0;
		self.state = "treading";
		self.stateTimer = love.math.random(3, 5);
	end
end

function Shark:updateTreading(dt)
	if self:canSenseBlood() then
		self:huntBlood();
	end

	if self.stateTimer <= 0 then
		self.target = {
			x = love.math.random(0, SCREEN_WIDTH - SHARK_SIZE),
			y = love.math.random(0, SCREEN_HEIGHT - BEACH_TOP - SHARK_SIZE)
		};
		self.state = "swimming";
	end
end

function Shark:updateSwimming(dt)
	if self:canSenseBlood() then
		self:huntBlood();
	end

	local vx = self.target.x - self.box.x;
	local vy = self.target.y - self.box.y;

	if math.abs(vx) < 5 and math.abs(vy) < 5 then
		self.state = "treading";
		self.velocity = { x = 0, y = 0 };
		self.stateTimer = love.math.random(3, 5);
	else
		vx, vy = math.normalize(vx, vy);
		self.velocity.x = vx * SHARK_SPEED;
		self.velocity.y = vy * SHARK_SPEED;
	end
end

function Shark:updateHunting(dt)
	if self.huntTarget == nil or not self.huntTarget.active or self.huntTarget.aliveTimer <= 0 then
		self.state = "treading";
		self.velocity = { x = 0, y = 0 };
		self.stateTimer = love.math.random(3, 5);
		return;
	end

	local vx = (self.huntTarget.box.x + self.huntTarget.box.w / 2) - (self.box.x + self.box.w / 2);
	local vy = (self.huntTarget.box.y + self.huntTarget.box.h / 2) - (self.box.y + self.box.h / 2);

	vx, vy = math.normalize(vx, vy);
	self.velocity.x = vx * SHARK_SPEED;
	self.velocity.y = vy * SHARK_SPEED;
end

function Shark:updateEating(dt)
	self.velocity.x = 0;
	self.velocity.y = 0;

	if self.huntTarget == nil or not self.huntTarget.active then
		self.state = "treading";
		self.stateTimer = love.math.random(3, 5);
	end
end

function Shark:updateLeaving(dt)
	self.velocity.x = 0;
	self.velocity.y = -SHARK_SPEED;

	if self.box.y < 0 - self.box.h then
		self.active = false;
	end
end

function Shark:canSenseBlood()
	return self.parentManager.parentStateGame.preyManager.numCorpses > 0;
end

function Shark:huntBlood()
	self.huntTarget = self.parentManager.parentStateGame.preyManager:getClosestCorpse(self.box.x, self.box.y);
	self.state = "hunting";
end

function Shark:updatePosition(dt)
	local dx = self.box.x + self.velocity.x * dt;
	local dy = self.box.y + self.velocity.y * dt;

	dx = math.clamp(dx, 0, SCREEN_WIDTH - self.box.w);

	if self.state == "leaving" then
		dy = math.clamp(dy, -50, SCREEN_HEIGHT - self.box.h);
	else
		dy = math.clamp(dy, 0, SCREEN_HEIGHT - self.box.h);
	end

	local actualX, actualY, cols, len = BumpWorld:move(self, dx, dy, sharkCollision);

	for i = 1, len do
		local other = cols[i].other;

		if other.type == "corpse" and self.state == "hunting" and other.aliveTimer > 0 then
			self.state = "eating";
			self.huntTarget = other;
			other:eat(dt);
		end
	end

	self.box.x = actualX;
	self.box.y = actualY;
end

function Shark:updateRotation(dt)
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		local fx, fy = math.normalize(self.velocity.x, self.velocity.y);
		self.facing.x = fx;
		self.facing.y = fy;
	end
end

function Shark:draw()
	if not self.active then
		return;
	end

	love.graphics.setColor(0, 0, 0, 100);

	local rotation = math.angle(0, 0, self.facing.y, self.facing.x);
	self.animation:draw(
		self.image,
		self.box.x + self.box.w / 2, self.box.y + self.box.h / 2,
		rotation,
		SHARK_SCALE, SHARK_SCALE,
		self.imageData.w / 2, self.imageData.h / 2
	);

	if DRAW_BOXES then
		love.graphics.setColor(255, 255, 255);
		love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h);
	end
end