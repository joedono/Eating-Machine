Player = Class {
  init = function (self, parentStateGame)
    self.parentStateGame = parentStateGame;

    self.box = {
      x = PLAYER_INITIAL_DIMENSIONS.x,
      y = PLAYER_INITIAL_DIMENSIONS.y,
      w = PLAYER_INITIAL_DIMENSIONS.w,
      h = PLAYER_INITIAL_DIMENSIONS.h
    };

    self.velocity = { x = 0, y = 0 };
    self.gamepadVelocity = { x = 0, y = 0 };
    self.facing = { x = 0, y = 0, };

    BumpWorld:add(self, self.box.x, self.box.y, self.box.w, self.box.h);

    self:resetKeys();

    self.active = true;
    self.type = "player";
  end
}

function Player:resetKeys()
  self.leftPressed = false;
  self.rightPressed = false;
  self.upPressed = false;
  self.downPressed = false;

  self.gamepadVelocity = { x = 0, y = 0 };
end

function Player:update(dt)
  if not self.active then
    return;
  end

  self:updateVelocity();
  self:updateRotation();
  self:updatePosition(dt);
end

function Player:updateVelocity()
  local vx = 0;
  local vy = 0;

  if self.leftPressed or self.rightPressed or self.upPressed or self.downPressed then
    if self.leftPressed then
      vx = vx - 1;
    end

    if self.rightPressed then
      vx = vx + 1;
    end

    if self.upPressed then
      vy = vy - 1;
    end

    if self.downPressed then
      vy = vy + 1;
    end
  else
    vx = self.gamepadVelocity.x;
    vy = self.gamepadVelocity.y;

    if math.dist(0, 0, vx, vy) < GAMEPAD_DEADZONE then
      vx = 0;
      vy = 0;
    end
  end

  if vx ~= 0 or vy ~= 0 then
    vx, vy = math.normalize(vx, vy);
  end

  self.velocity.x = vx * PLAYER_SWIM_SPEED;
  self.velocity.y = vy * PLAYER_SWIM_SPEED;
end

function Player:updateRotation()
  if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
    local fx, fy = math.normalize(self.velocity.x, self.velocity.y);
    self.facing.x = fx;
    self.facing.y = fy;
  end
end

function Player:updatePosition(dt)
  local dx = self.box.x + self.velocity.x * dt;
  local dy = self.box.y + self.velocity.y * dt;

  dx = math.clamp(dx, 0, SCREEN_WIDTH - self.box.w);
  dy = math.clamp(dy, 0, SCREEN_HEIGHT - self.box.h);

  local actualX, actualY, cols, len = BumpWorld:move(self, dx, dy, playerCollision);

  self.box.x = actualX;
  self.box.y = actualY;
end

function Player:draw()
  love.graphics.setColor(0, 255, 0);
  love.graphics.rectangle("fill", self.box.x, self.box.y, self.box.w, self.box.h);
end