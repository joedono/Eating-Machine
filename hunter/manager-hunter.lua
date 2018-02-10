require "hunter/hunter";
require "hunter/shark";

Manager_Hunter = Class {
	init = function (self, parentStateGame)
		self.parentStateGame = parentStateGame;

		self.sharkImage = love.graphics.newImage("asset/image/player.png");
		self.sharkImageData = { w = 80, h = 80 };
		local grid = Anim8.newGrid(80, 80, self.sharkImage:getWidth(), self.sharkImage:getHeight());
		self.sharkAnimation = Anim8.newAnimation(grid("1-2", 1), 0.3);

		self.huntingBoatImage = love.graphics.newImage("asset/image/hunter/ship_small_body.png");
		self.huntingGunImage = love.graphics.newImage("asset/image/hunter/ship_big_gun.png");
		self.huntingGunFireImage = love.graphics.newImage("asset/image/hunter/gun_fire.png");
		self.waterRippleImage = love.graphics.newImage("asset/image/hunter/water_ripple.png");
		local grid = Anim8.newGrid(168, 64, self.waterRippleImage:getWidth(), self.waterRippleImage:getHeight());
		self.waterRippleAnimation = Anim8.newAnimation(grid(1, "1-4"), 0.3);

		self.gunshotSound = love.audio.newSource("asset/sound/gunshot.wav", "static");

		self.sharks = {};
		self.hunters = {};

		self.sharkTimer = love.math.random(SHARK_SPAWN_MIN, SHARK_SPAWN_MAX);
		self.hunterTimer = love.math.random(HUNTER_SPAWN_MIN, HUNTER_SPAWN_MAX);
	end
}

function Manager_Hunter:update(dt, attention)
	self:updateSharks(dt);
	self:updateHunters(dt);

	self.sharkTimer = self.sharkTimer - dt;
	if self.sharkTimer <= 0 then
		self:spawnShark();
	end

	if attention >= 100 then
		self.hunterTimer = self.hunterTimer - dt;
		if self.hunterTimer <= 0 then
			self:spawnHunter();
		end
	end
end

function Manager_Hunter:updateSharks(dt)
	local activeSharks = {};

	for index, shark in pairs(self.sharks) do
		shark:update(dt);
		if shark.active then
			table.insert(activeSharks, shark);
		else
			BumpWorld:remove(shark);
		end
	end

	self.sharks = activeSharks;
end

function Manager_Hunter:updateHunters(dt)
	local activeHunters = {};

	for index, hunter in pairs(self.hunters) do
		hunter:update(dt);
		if hunter.active then
			table.insert(activeHunters, hunter);
		else
			BumpWorld:remove(hunter);
		end
	end

	self.hunters = activeHunters;
end

function Manager_Hunter:spawnShark()
	local x = love.math.random(0, SCREEN_WIDTH - SHARK_SIZE);
	table.insert(self.sharks, Shark(self, x, -SHARK_SIZE, self.sharkImage, self.sharkImageData, self.sharkAnimation));
	self.sharkTimer = love.math.random(SHARK_SPAWN_MIN, SHARK_SPAWN_MAX);
end

function Manager_Hunter:spawnHunter()
	local x = -200;
	local y = love.math.random(100, SCREEN_HEIGHT / 2);
	local velocity = {
		x = 1,
		y = 0
	};

	if love.math.random() < 0.5 then
		x = SCREEN_WIDTH + 200;
		velocity.x = -1;
	end

	table.insert(self.hunters, Hunter(
		self,
		x, y, velocity,
		self.huntingBoatImage,
		self.huntingGunImage,
		self.waterRippleImage,
		self.waterRippleAnimation,
		self.huntingGunFireImage,
		self.gunshotSound
	));

	self.hunterTimer = love.math.random(HUNTER_SPAWN_MIN, HUNTER_SPAWN_MAX);
end

function Manager_Hunter:huntersLeave()
	for index, hunter in pairs(self.hunters) do
		hunter.state = "leaving";
		hunter.stateTimer = 2;
	end
end

function Manager_Hunter:draw()
	for index, shark in pairs(self.sharks) do
		shark:draw();
	end

	for index, hunter in pairs(self.hunters) do
		hunter:draw();
	end
end