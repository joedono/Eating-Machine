require "prey/corpse";
require "prey/swimmer";

Manager_Prey = Class {
	init = function (self, parentStateGame)
		self.parentStateGame = parentStateGame;

		self.swimmerImage = love.graphics.newImage("asset/image/prey/swimmer.png");
		local swimmerGrid = Anim8.newGrid(32, 32, self.swimmerImage:getWidth(), self.swimmerImage:getHeight());
		self.swimmerAnimation = Anim8.newAnimation(swimmerGrid("1-2", 1), 0.3);

		local bloodImage = love.graphics.newImage("asset/image/effect/corpse-blood.png");
		self.bloodEffect = love.graphics.newParticleSystem(bloodImage, 100);
		self.bloodEffect:setColors(
			150, 0, 0, 100,
			200, 0, 0, 150,
			200, 0, 0, 100,
			150, 0, 0, 0
		);
		self.bloodEffect:setEmissionRate(20);
		self.bloodEffect:setInsertMode("bottom");
		self.bloodEffect:setLinearAcceleration(-10, -5, 10, 5);
		self.bloodEffect:setParticleLifetime(3, 4);
		self.bloodEffect:setSizes(0.5, 2);

		self.swimmers = {};
		self.swimmerSpawnTimer = love.math.random(SWIMMER_SPAWN_MIN, SWIMMER_SPAWN_MAX);

		self.corpses = {};
		self.numCorpses = 0;

		self.active = true;
	end
}

function Manager_Prey:update(dt)
	if not self.active then
		return;
	end

	self.swimmerSpawnTimer = self.swimmerSpawnTimer - dt;
	if self.swimmerSpawnTimer <= 0 then
		self:spawnSwimmer();
	end

	self:updateSwimmers(dt);
	self:updateCorpses(dt);
end

function Manager_Prey:spawnSwimmer()
	local x = love.math.random(0, SCREEN_WIDTH - SWIMMER_SIZE);
	table.insert(self.swimmers, Swimmer(self, x, SCREEN_HEIGHT + SWIMMER_SIZE, self.swimmerImage, self.swimmerAnimation));
	self.swimmerSpawnTimer = love.math.random(SWIMMER_SPAWN_MIN, SWIMMER_SPAWN_MAX);
end

function Manager_Prey:spawnCorpse(x, y)
	table.insert(self.corpses, Corpse(self, x, y, self.bloodEffect));
	self.numCorpses = self.numCorpses + 1;
end

function Manager_Prey:updateSwimmers(dt)
	local activeSwimmers = {};
	for index, swimmer in pairs(self.swimmers) do
		swimmer:update(dt);
		if swimmer.active then
			table.insert(activeSwimmers, swimmer);
		else
			BumpWorld:remove(swimmer);
		end
	end

	self.swimmers = activeSwimmers;
end

function Manager_Prey:updateCorpses(dt)
	local activeCorpses = {};
	for index, corpse in pairs(self.corpses) do
		corpse:update(dt);
		if corpse.active then
			table.insert(activeCorpses, corpse);
		else
			BumpWorld:remove(corpse);
			self.numCorpses = self.numCorpses - 1;
		end
	end
	self.corpses = activeCorpses;
end

function Manager_Prey:getClosestCorpse(x, y)
	local closestCorpse = nil;
	local dist = 0;

	for index, corpse in pairs(self.corpses) do
		if closestCorpse == nil or dist > math.dist(x, y, corpse.box.x, corpse.box.y) then
			closestCorpse = corpse;
			dist = math.dist(x, y, corpse.box.x, corpse.box.y);
		end
	end

	return closestCorpse;
end

function Manager_Prey:draw()
	love.graphics.setColor(255, 255, 255);

	for index, corpse in pairs(self.corpses) do
		corpse:draw();
	end

	for index, swimmer in pairs(self.swimmers) do
		swimmer:draw();
	end
end