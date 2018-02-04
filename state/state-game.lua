require "player";

State_Game = {};

function State_Game:init()
	BumpWorld = Bump.newWorld(32);

	self.oceanImage = love.graphics.newImage("asset/image/ocean.png");
	self.beachImage = love.graphics.newImage("asset/image/beach.png");

	self.active = true;
end

function State_Game:enter()
	self.player = Player(self);

	self.oceanWavePosition = 0;
	self.oceanWaveDirection = -1;
	self.oceanWaveTimer = Timer.new();
	self.oceanWaveTimer:every(0.75, function() self:moveOceanWaves(); end);
end

function State_Game:focus(focused)
  if focused then
    self.active = true;
  else
    self.active = false;
  end
end

function State_Game:keypressed(key, unicode)
	if not self.active then
    return;
  end

	if key == KEY_LEFT then
    self.player.leftPressed = true;
  end

  if key == KEY_RIGHT then
    self.player.rightPressed = true;
  end

  if key == KEY_UP then
    self.player.upPressed = true;
  end

  if key == KEY_DOWN then
    self.player.downPressed = true;
  end

	if key == KEY_START then
		GameState.push(State_Pause);
	end
end

function State_Game:keyreleased(key, unicode)
	if not self.active then
    return;
  end

	if key == KEY_LEFT then
    self.player.leftPressed = false;
  end

  if key == KEY_RIGHT then
    self.player.rightPressed = false;
  end

  if key == KEY_UP then
    self.player.upPressed = false;
  end

  if key == KEY_DOWN then
    self.player.downPressed = false;
  end
end

function State_Game:gamepadpressed(joystick, button)
  if not self.active then
    return;
  end

	if button == GAMEPAD_LEFT then
    self.player.leftPressed = true;
  end

  if button == GAMEPAD_RIGHT then
    self.player.rightPressed = true;
  end

  if button == GAMEPAD_UP then
    self.player.upPressed = true;
  end

  if button == GAMEPAD_DOWN then
    self.player.downPressed = true;
  end

	if button == GAMEPAD_START then
		GameState.push(State_Pause);
  end
end

function State_Game:gamepadreleased(joystick, button)
  if not self.active then
    return;
  end

	if button == GAMEPAD_LEFT then
    self.player.leftPressed = false;
  end

  if button == GAMEPAD_RIGHT then
    self.player.rightPressed = false;
  end

  if button == GAMEPAD_UP then
    self.player.upPressed = false;
  end

  if button == GAMEPAD_DOWN then
    self.player.downPressed = false;
  end
end

function State_Game:gamepadaxis(joystick, axis, value)
	if not self.active then
    return;
  end

	if axis == "leftx" then -- X Movement
		self.player.gamepadVelocity.x = value;
	end

	if axis == "lefty" then -- Y Movement
		self.player.gamepadVelocity.y = value;
	end
end

function State_Game:update(dt)
	if not self.active then
    return;
  end

	self.oceanWaveTimer:update(dt);
	self.player:update(dt);
end

function State_Game:moveOceanWaves()
	self.oceanWavePosition = self.oceanWavePosition + self.oceanWaveDirection * OCEAN_MOVE_RATE;
	if self.oceanWavePosition == 0 then
		self.oceanWaveDirection = -1;
	elseif self.oceanWavePosition == -OCEAN_MOVE_RATE * 3 then
		self.oceanWaveDirection = 1;
	end
end

function State_Game:draw()
	CANVAS:renderTo(function()
		love.graphics.clear();
    love.graphics.setColor(255, 255, 255);
		love.graphics.draw(self.beachImage, 0, 0);
    love.graphics.draw(self.oceanImage, 0, self.oceanWavePosition);

		self.player:draw();
  end);

  love.graphics.setColor(255, 255, 255);
  love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end