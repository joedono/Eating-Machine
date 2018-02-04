require "prey/corpse";
require "prey/swimmer";

Manager_Prey = Class {
  init = function (self, parentStateGame)
    self.parentStateGame = parentStateGame;

    self.swimmerImage = love.graphics.newImage("asset/image/prey/swimmer.png");
    local swimmerGrid = Anim8.newGrid(32, 32, self.swimmerImage:getWidth(), self.swimmerImage:getHeight());
    self.swimmerAnimation = Anim8.newAnimation(swimmerGrid("1-2", 1), 0.3);

    self.corpseImage = nil;

    self.swimmers = {};
    self.swimmerSpawnTimer = 0;

    self.corpses = {};

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
  self.swimmerSpawnTimer = love.math.random(10, 15);
end

function Manager_Prey:spawnCorpse(x, y)
	table.insert(self.corpses, Corpse(self, x, y, self.corpseImage));
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
    end
	end
	self.corpses = activeCorpses;
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