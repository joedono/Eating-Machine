Manager_Prey = Class {
  init = function (self, parentStateGame)
    self.parentStateGame = parentStateGame;

    self.swimmerImage = love.graphics.newImage("asset/image/prey/swimmer.png");

    self.swimmers = {};
  end
}

function Manager_Prey:update(dt)
  if not self.active then
    return;
  end

  self:updateSwimmers(dt);
end

function Manager_Prey:updateSwimmers(dt)
  local activeSwimmers = {};
  for index, swimmer in pairs(self.swimmers) do
    swimmer:update(dt);
    if swimmer.active then
      table.insert(activeSwimmers, swimmer);
    end
  end

  self.swimmers = activeSwimmers;
end

function Manager_Prey:draw()
  love.graphics.setColor(255, 255, 255);
  for index, swimmer in pairs(self.swimmers) do
    swimmer:draw();
  end
end