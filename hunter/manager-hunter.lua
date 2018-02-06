require "hunter/fisher";
require "hunter/shark";

Manager_Hunter = Class {
  init = function (self, parentStateGame)
    self.parentStateGame = parentStateGame;

    self.sharkImage = love.graphics.newImage("asset/image/player.png");
    self.sharkImageData = { w = 80, h = 80 };
    local grid = Anim8.newGrid(80, 80, self.sharkImage:getWidth(), self.sharkImage:getHeight());
    self.sharkAnimation = Anim8.newAnimation(grid("1-2", 1), 0.3);

    self.sharks = {};
    self.fishers = {};

    self.sharkTimer = love.math.random(20, 40);
    self.fisherTimer = love.math.random(20, 40);
  end
}

function Manager_Hunter:update(dt, attention)
  self:updateSharks(dt);
  self:updateFishers(dt);

  self.sharkTimer = self.sharkTimer - dt;
  if self.sharkTimer <= 0 then
    self:spawnShark();
  end

  if attention >= 100 then
    self.fisherTimer = self.fisherTimer - dt;
    if self.fisherTimer <= 0 then
      self:spawnFisher();
      self.fishertimer = love.math.random(20, 40);
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

function Manager_Hunter:updateFishers(dt)
  local activeFishers = {};

  for index, fisher in pairs(self.fishers) do
    fisher:update(dt);
    if fisher.active then
      table.insert(activeFishers, fisher);
    else
      BumpWorld:remove(fisher);
    end
  end

  self.fishers = activeFishers;
end

function Manager_Hunter:spawnShark()
  local x = love.math.random(0, SCREEN_WIDTH - SWIMMER_SIZE);
  table.insert(self.sharks, Shark(self, x, -SHARK_SIZE, self.sharkImage, self.sharkImageData, self.sharkAnimation));
  self.sharkTimer = love.math.random(1, 1);
end

function Manager_Hunter:spawnFisher()
  -- TODO
end

function Manager_Hunter:draw()
  for index, shark in pairs(self.sharks) do
    shark:draw();
  end

  for index, fisher in pairs(self.fishers) do
    fisher:draw();
  end
end