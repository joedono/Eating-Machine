Hunter = Class {
	init = function (self, parentManager, x, y, velocity, boatImage, gunImage, waterRippleImage, waterRippleAnimation, gunFireImage)
		self.parentManager = parentManager;

		self.box = {
			x = x,
			y = y,
			w = HUNTER_SIZE,
			h = HUNTER_SIZE
		};

		self.velocity = velocity;
		self.facing = {
			x = velocity.x,
			y = velocity.y
		};

		self.aiming = {
			x = velocity.x,
			y = velocity.y
		};

		self.velocity.x = self.velocity.x * HUNTER_SPEED;
		self.velocity.y = self.velocity.y * HUNTER_SPEED;

		self.boatImage = boatImage;
		self.gunImage = gunImage;
		self.gunFireImage = gunFireImage;
		self.waterRippleImage = waterRippleImage;
		self.waterRippleAnimation = waterRippleAnimation:clone();

		self.state = "entering";
		self.stateTimer = love.math.random(1, 3);
		self.type = "hunter";
		self.active = true;
	end
}

function Hunter:update(dt)
	if not self.active then
		return;
	end

	if self.stateTimer > 0 then
		self.stateTimer = self.stateTimer - dt;
	end

	if self.state == "entering" then
		self:updateEntering(dt);
	elseif self.state == "treading" then
		self:updateTreading(dt);
	elseif self.state == "patrolling" then
		self:updatePatrolling(dt);
	elseif self.state == "pursuing" then
		self:updatePursuing(dt);
	elseif self.state == "shooting" then
		self:updateShooting(dt);
	elseif self.state == "leaving" then
		self:updateLeaving(dt);
	end

	self.waterRippleAnimation:update(dt);
	self:updatePosition(dt);
	self:updateRotation(dt);
end

function Hunter:updateEntering(dt)
	-- TODO
end

function Hunter:updateTreading(dt)
	-- TODO
end

function Hunter:updatePatrolling(dt)
	-- TODO
end

function Hunter:updatePursuing(dt)
	-- TODO
end

function Hunter:updateShooting(dt)
	-- TODO
end

function Hunter:updateLeaving(dt)
	-- TODO
end

function Hunter:updatePosition(dt)
	local dx = self.box.x + self.velocity.x * dt;
	local dy = self.box.y + self.velocity.y * dt;

	dx = math.clamp(dx, 0, SCREEN_WIDTH - self.box.w);

	if self.state == "leaving" then
		dy = math.clamp(dy, -50, SCREEN_HEIGHT - self.box.h);
	else
		dy = math.clamp(dy, 0, SCREEN_HEIGHT - self.box.h);
	end

	local actualX, actualY, cols, len = BumpWorld:move(self, dx, dy, hunterCollision);

	self.box.x = actualX;
	self.box.y = actualY;
end

function Hunter:updateRotation(dt)
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		local fx, fy = math.normalize(self.velocity.x, self.velocity.y);
		self.facing.x = fx;
		self.facing.y = fy;
	end
end

function Hunter:draw()
	if not self.active then
		return;
	end

	love.graphics.setColor(255, 255, 255);
	local facingAngle = math.angle(0, 0, self.facing.y, self.facing.x);
	local aimingAngle = math.angle(0, 0, self.aiming.y, self.aiming.x);

	local offsetX = -self.facing.x * 15 + self.box.x + self.box.w / 2;
	local offsetY = -self.facing.y * 15 + self.box.y + self.box.h / 2;
	self.waterRippleAnimation:draw(
		self.waterRippleImage,
		offsetX, offsetY,
		facingAngle,
		1, 1,
		168 / 2, 64 / 2
	);

	love.graphics.draw(
		self.boatImage,
		self.box.x + self.box.w / 2, self.box.y + self.box.h / 2,
		facingAngle,
		1, 1,
		105 / 2, 54 / 2
	);

	love.graphics.draw(
		self.gunImage,
		self.box.x + self.box.w / 2, self.box.y + self.box.h / 2,
		aimingAngle,
		1, 1,
		60 / 2, 32 / 2
	);

	if DRAW_BOXES then
		love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h);
	end
end