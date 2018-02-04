Corpse = Class {
  init = function (self, parentManager, x, y, image)
    self.parentManager = parentManager;
    self.image = image;

    self.box = {
      x = x,
      y = y,
      w = CORPSE_SIZE,
      h = CORPSE_SIZE
    };

    BumpWorld:add(self, self.box.x, self.box.y, self.box.w, self.box.h);

    self.aliveTimer = 10;
    self.type = "corpse";
    self.active = true;
  end
}

function Corpse:update(dt)
  if not self.active then
    return;
  end

  if self.aliveTimer < 0 then
    self.active = false;
  else
    self.aliveTimer = self.aliveTimer - dt;

    -- TODO
  end
end

function Corpse:eat(dt)
  if self.aliveTimer > 0 then
    self.aliveTimer = self.aliveTimer - dt;
  end
end

function Corpse:draw()
  -- TODO
  love.graphics.setColor(255, 0, 0);
  love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.w, self.box.h);
end