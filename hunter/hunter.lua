Hunter = Class {
	init = function (self, parentManager, x, y, velocity, boatImage, gunImage, waterRippleImage, waterRippleAnimation, gunFireImage, gunshotSound)
		self.parentManager = parentManager;

		self.box = {
			x = x,
			y = y,
			w = HUNTER_SIZE,
			h = HUNTER_SIZE
		};

		BumpWorld:add(self, self.box.x, self.box.y, self.box.w, self.box.h);

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
		self.gunshotSound = gunshotSound;
		self.shootTimer = 0;

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

	if self.shootTimer > 0 then
		self.shootTimer = self.shootTimer - dt;
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
	if self:canSeeBlood() then
		self:huntShark();
	end

	if self.stateTimer <= 0 then
		self.velocity.x = 0;
		self.state = "treading";
		self.stateTimer = love.math.random(3, 5);
	end
end

function Hunter:updateTreading(dt)
	if self:canSeeBlood() then
		self:huntShark();
	end

	if self.stateTimer <= 0 then
		self.target = {
			x = love.math.random(0, SCREEN_WIDTH - HUNTER_SIZE),
			y = love.math.random(0, SCREEN_HEIGHT - BEACH_TOP - HUNTER_SIZE)
		};
		self.state = "patrolling";
	end
end

function Hunter:updatePatrolling(dt)
	if self:canSeeBlood() then
		self:huntShark();
	end

	local vx = self.target.x - self.box.x;
	local vy = self.target.y - self.box.y;

	if math.abs(vx) < 5 and math.abs(vy) < 5 then
		self.state = "treading";
		self.velocity = { x = 0, y = 0 };
		self.stateTimer = love.math.random(3, 5);
	else
		vx, vy = math.normalize(vx, vy);
		self.velocity.x = vx * HUNTER_SPEED;
		self.velocity.y = vy * HUNTER_SPEED;
	end
end

function Hunter:updatePursuing(dt)
	if not self.closestCorpse.active then
		self.state = "treading";
		return;
	end

	local vx = (self.closestCorpse.box.x + self.closestCorpse.box.w / 2) - (self.box.x + self.box.w / 2);
	local vy = (self.closestCorpse.box.y + self.closestCorpse.box.h / 2) - (self.box.y + self.box.h / 2);

	local fx, fy = math.normalize(vx, vy);
	self.facing.x = fx;
	self.facing.y = fy;

	if math.abs(vx) < 100 and math.abs(vy) < 100 then
		self.velocity = { x = 0, y = 0 };
		self.shootTarget = nil;
		self.state = "shooting";
		self.stateTimer = love.math.random(3, 5);
	else
		vx, vy = math.normalize(vx, vy);
		self.velocity.x = vx * HUNTER_SPEED;
		self.velocity.y = vy * HUNTER_SPEED;
	end
end

function Hunter:updateShooting(dt)
	if self.stateTimer <= 0 then
		self.target = {
			x = love.math.random(0, SCREEN_WIDTH - HUNTER_SIZE),
			y = love.math.random(0, SCREEN_HEIGHT - BEACH_TOP - HUNTER_SIZE)
		};
		self.state = "patrolling";
	end

	if self.shootTarget == nil then
		local targets, len = BumpWorld:queryRect(
			self.box.x + self.box.w / 2 + self.facing.x * 80 - 90 / 2,
			self.box.y + self.box.h / 2 + self.facing.y * 80 - 90 / 2,
			90, 90,
			hunterTargetFilter
		);

		if len > 0 then
			self.shootTarget = targets[1];
			self.gunshotSound:rewind();
			self.gunshotSound:play();

			self.aiming.x = self.shootTarget.box.x - self.box.x;
			self.aiming.y = self.shootTarget.box.y - self.box.y;

			self.aiming.x, self.aiming.y = math.normalize(self.aiming.x, self.aiming.y);

			self.shootTimer = 0.3;
		end
	else
		if self.shootTarget.type == "shark" then
			self.shootTarget.state = "dead";
			self.shootTarget = nil;
			self.parentManager.parentStateGame:killedShark();
		elseif self.shootTarget.type == "player" then
			self.parentManager.parentStateGame:loseGame();
		end
	end
end

function Hunter:updateLeaving(dt)
	if self.stateTimer <= 0 then
		self.velocity.x = 0;
		self.velocity.y = -HUNTER_SPEED;

		if self.box.y < -200 then
			self.active = false;
		end
	end
end

function Hunter:canSeeBlood()
	return self.parentManager.parentStateGame.preyManager.numCorpses > 0;
end

function Hunter:huntShark()
	self.closestCorpse = self.parentManager.parentStateGame.preyManager:getClosestCorpse(self.box.x, self.box.y);
	self.state = "pursuing";
	self.velocity = { x = 0, y = 0 };
end

function Hunter:updatePosition(dt)
	local dx = self.box.x + self.velocity.x * dt;
	local dy = self.box.y + self.velocity.y * dt;

	dx = math.clamp(dx, 0, SCREEN_WIDTH - self.box.w);

	if self.state == "leaving" then
		dy = math.clamp(dy, -100, SCREEN_HEIGHT - self.box.h);
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

		if self.state ~= "shooting" then
			self.aiming.x = fx;
			self.aiming.y = fy;
		end
	end
end

function Hunter:draw()
	if not self.active then
		return;
	end

	love.graphics.setColor(255, 255, 255);
	local facingAngle = math.angle(0, 0, self.facing.y, self.facing.x);
	local aimingAngle = math.angle(0, 0, self.aiming.y, self.aiming.x);

	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		local offsetX = -self.facing.x * 15 + self.box.x + self.box.w / 2;
		local offsetY = -self.facing.y * 15 + self.box.y + self.box.h / 2;
		self.waterRippleAnimation:draw(
			self.waterRippleImage,
			offsetX, offsetY,
			facingAngle,
			1, 1,
			168 / 2, 64 / 2
		);
	end

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

	if self.shootTimer > 0 then
		local gunOffsetX = self.aiming.x * 50 + self.box.x + self.box.w / 2;
		local gunOffsetY = self.aiming.y * 50 + self.box.y + self.box.h / 2;
		love.graphics.draw(
			self.gunFireImage,
			gunOffsetX, gunOffsetY,
			aimingAngle,
			0.7, 0.7,
			75 / 2, 30 / 2
		);
	end

	if DRAW_BOXES then
		love.graphics.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h);

		if self.state == "shooting" then
			love.graphics.setColor(255, 0, 0);
		else
			love.graphics.setColor(255, 255, 255);
		end

		love.graphics.rectangle("line",
			self.box.x + self.box.w / 2 + self.facing.x * 80 - 90 / 2,
			self.box.y + self.box.h / 2 + self.facing.y * 80 - 90 / 2,
			90, 90
		);
	end
end