require "player";

require "hunter/manager-hunter";
require "prey/manager-prey";

State_Game = {};

function State_Game:init()
	BumpWorld = Bump.newWorld(32);

	self.oceanImage = love.graphics.newImage("asset/image/ocean.png");
	self.beachImage = love.graphics.newImage("asset/image/beach.png");

	self.hudFont = love.graphics.newFont(14);
	self.active = true;
end

function State_Game:enter()
	self.player = Player(self);
	self.preyManager = Manager_Prey(self);
	self.hunterManager = Manager_Hunter(self);

	self.oceanWavePosition = 0;
	self.oceanWaveDirection = -1;
	self.oceanWaveTimer = Timer.new();
	self.oceanWaveTimer:every(0.75, function() self:moveOceanWaves(); end);

	self.hunger = 100;
	self.attention = 0;
end

function State_Game:resume()
	self.player:resetKeys();
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

	if key == KEY_BITE then
		self.player.bitePressed = true;
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

	if key == KEY_BITE then
		self.player.bitePressed = false;
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

	if button == GAMEPAD_BITE then
		self.player.bitePressed = true;
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

	if button == GAMEPAD_BITE then
		self.player.bitePressed = false;
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
	self.preyManager:update(dt);
	self.hunterManager:update(dt, self.attention);

	self.hunger = self.hunger - dt * HUNGER_RATE;
	if self.hunger <= 0 then
		self:loseGame();
	end
end

function State_Game:moveOceanWaves()
	self.oceanWavePosition = self.oceanWavePosition + self.oceanWaveDirection * OCEAN_MOVE_RATE;
	if self.oceanWavePosition == 0 then
		self.oceanWaveDirection = -1;
	elseif self.oceanWavePosition == -OCEAN_MOVE_RATE * 3 then
		self.oceanWaveDirection = 1;
	end
end

function State_Game:spawnCorpse(x, y)
	self.attention = self.attention + ATTENTION_RATE;
	self.preyManager:spawnCorpse(x, y);

	if self.attention > 100 then
		self.attention = 100;
	end
end

function State_Game:eatCorpse(dt)
	self.hunger = self.hunger + dt * EAT_RATE;
	self.hunger = math.clamp(self.hunger, 0, 100);
end

function State_Game:killedShark()
	self.attention = 0;
	self.hunterManager:huntersLeave();
end

function State_Game:loseGame()
	print("lost game");
end

function State_Game:draw()
	CANVAS:renderTo(function()
		love.graphics.clear();
		love.graphics.setColor(255, 255, 255);
		love.graphics.draw(self.beachImage, 0, 0);
		love.graphics.draw(self.oceanImage, 0, self.oceanWavePosition);

		self.player:draw();
		self.preyManager:draw();
		self.hunterManager:draw();

		love.graphics.setFont(self.hudFont);
		love.graphics.setColor(255, 255, 255);
		love.graphics.print("Hunger", 5, 5);
		love.graphics.print("Attention", 5, 30);

		love.graphics.setColor(255, 0, 0);
		love.graphics.rectangle("fill", 80, 5, self.hunger, 18);
		love.graphics.setColor(255, 255, 0);
		love.graphics.rectangle("fill", 80, 30, self.attention, 18);
		love.graphics.setColor(255, 255, 255);
		love.graphics.rectangle("line", 80, 5, 100, 18);
		love.graphics.rectangle("line", 80, 30, 100, 18);
	end);

	love.graphics.setColor(255, 255, 255);
	love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end