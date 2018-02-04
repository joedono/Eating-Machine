Swimmer = Class {
  init = function (self, parentManager, x, y, image, animation)
    self.parentManager = parentManager;
    self.image = image;
    self.animation = animation:clone();

    self.box = {
      x = x,
      y = y,
      w = SWIMMER_SIZE,
      h = SWIMMER_SIZE
    };
    self.velocity = { x = 0, y = 0 };
    self.facing = { x = 0, y = -1 };

    BumpWorld:add(self, self.box.x, self.box.y, self.box.w, self.box.h);

    self.state = "entering";
    self.stateTimer = love.math.random(4, 10);
    self.type = "swimmer";
    self.active = true;
  end
}

function Swimmer:update(dt)
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
  elseif self.state == "swimming" then
    self:updateSwimming(dt);
  elseif self.state == "fleeing" then
    self:updateFleeing(dt);
  end

  self.animation:update(dt);
  self:updatePosition(dt);
  self:updateRotation(dt);
end

function Swimmer:updateEntering(dt)
  self.velocity.y = -SWIMMER_SPEED;

  if self.stateTimer <= 0 then
    self.velocity.y = 0;
    self.state = "treading";
    self.stateTimer = love.math.random(4, 10);
  end
end

function Swimmer:updateTreading(dt)
  if self.stateTimer <= 0 then
    self.target = {
      x = love.math.random(0, SCREEN_WIDTH - SWIMMER_SIZE),
      y = love.math.random(0, SCREEN_HEIGHT - BEACH_TOP - SWIMMER_SIZE)
    };
    self.state = "swimming";
  end
end

function Swimmer:updateSwimming(dt)
  local vx = self.target.x - self.box.x;
  local vy = self.target.y - self.box.y;

  if math.abs(vx) < 5 and math.abs(vy) < 5 then
    self.state = "treading";
    self.facing = { x = 0, y = -1 };
    self.velocity = { x = 0, y = 0 };
    self.stateTimer = love.math.random(4, 10);
  else
    vx, vy = math.normalize(vx, vy);
    self.velocity.x = vx * SWIMMER_SPEED;
    self.velocity.y = vy * SWIMMER_SPEED;
  end
end

function Swimmer:updateFleeing(dt)
end

function Swimmer:updatePosition(dt)
  local dx = self.box.x + self.velocity.x * dt;
  local dy = self.box.y + self.velocity.y * dt;

  dx = math.clamp(dx, 0, SCREEN_WIDTH - self.box.w);
  dy = math.clamp(dy, 0, SCREEN_HEIGHT - self.box.h);

  local actualX, actualY, cols, len = BumpWorld:move(self, dx, dy, swimmerCollision);

  self.box.x = actualX;
  self.box.y = actualY;
end

function Swimmer:updateRotation(dt)
  if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
    local fx, fy = math.normalize(self.velocity.x, self.velocity.y);
    self.facing.x = fx;
    self.facing.y = fy;
  end
end

function Swimmer:draw()
  love.graphics.setColor(255, 255, 255);

  local rotation = math.angle(0, 0, self.facing.y, self.facing.x);
  self.animation:draw(
    self.image,
    self.box.x + self.box.w / 2, self.box.y + self.box.h / 2,
    rotation,
    1, 1,
    SWIMMER_SIZE / 2, SWIMMER_SIZE / 2
  );
end