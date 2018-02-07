State_Title = {};

function State_Title:init()
	self.font = love.graphics.newFont(12);

	self.oceanImage = love.graphics.newImage("asset/image/ocean.png");
	self.beachImage = love.graphics.newImage("asset/image/beach.png");
	self.titleImage = love.graphics.newImage("asset/image/screen/title.png");

	self.sharkImage = love.graphics.newImage("asset/image/player.png");
	local grid = Anim8.newGrid(80, 80, self.sharkImage:getWidth(), self.sharkImage:getHeight());
	self.sharkAnimation = Anim8.newAnimation(grid("1-2", 1), 0.3);

	self.sharkPosition = {
		x = -100,
		y = 300
	};

	local bloodImage = love.graphics.newImage("asset/image/effect/corpse-blood.png");
	local bloodEffect = love.graphics.newParticleSystem(bloodImage, 600);
	bloodEffect:setColors(
		150, 0, 0, 100,
		200, 0, 0, 150,
		200, 0, 0, 100,
		150, 0, 0, 0
	);
	bloodEffect:setInsertMode("bottom");
	bloodEffect:setLinearAcceleration(-10, -5, 10, 5);
	bloodEffect:setParticleLifetime(3, 4);
	bloodEffect:setSizes(0.5, 2);

	self.titleEffect = bloodEffect:clone();
	self.titleEffect:setPosition(295, 195);
	self.titleEffect:setAreaSpread("uniform", 200, 20);
	self.titleEffect:setEmissionRate(200);

	self.subTitleEffect = bloodEffect:clone();
	self.subTitleEffect:setPosition(295, 425);
	self.subTitleEffect:setAreaSpread("uniform", 70, 5);
	self.subTitleEffect:setEmissionRate(20);
end

function State_Title:enter()
	self.oceanWavePosition = 0;
	self.oceanWaveDirection = -1;
	self.oceanWaveTimer = Timer.new();
	self.oceanWaveTimer:every(0.75, function() self:moveOceanWaves(); end);

	self.sharkMovementTimer = Timer.new();
	self.sharkRepeatTimer = Timer.new();
	self.sharkRepeatTimer:every(10, function() self:startSharkMovement(); end);
end

function State_Title:keypressed(key, unicode)
	GameState.switch(State_Game);
end

function State_Title:gamepadpressed(joystick, button)
	GameState.switch(State_Game);
end

function State_Title:update(dt)
	self.oceanWaveTimer:update(dt);
	self.sharkRepeatTimer:update(dt);
	self.sharkMovementTimer:update(dt);
	self.sharkAnimation:update(dt);

	self.titleEffect:update(dt);
	self.subTitleEffect:update(dt);
end

function State_Title:moveOceanWaves()
	self.oceanWavePosition = self.oceanWavePosition + self.oceanWaveDirection * OCEAN_MOVE_RATE;
	if self.oceanWavePosition == 0 then
		self.oceanWaveDirection = -1;
	elseif self.oceanWavePosition == -OCEAN_MOVE_RATE * 3 then
		self.oceanWaveDirection = 1;
	end
end

function State_Title:startSharkMovement()
	self.sharkPosition.x = -50;
	self.sharkPosition.y = love.math.random(200, 350);
	self.sharkMovementTimer:clear();
	self.sharkMovementTimer:tween(5, self.sharkPosition, { x = SCREEN_WIDTH + 100 });
end

function State_Title:draw()
	CANVAS:renderTo(function()
		love.graphics.clear();

		love.graphics.setColor(255, 255, 255);
		love.graphics.draw(self.beachImage, 0, 0);
		love.graphics.draw(self.oceanImage, 0, self.oceanWavePosition);

		love.graphics.setColor(0, 0, 0, 100);
		self.sharkAnimation:draw(self.sharkImage, self.sharkPosition.x, self.sharkPosition.y);

		love.graphics.setColor(255, 255, 255);
		love.graphics.draw(self.titleEffect, 0, 0);
		love.graphics.draw(self.subTitleEffect, 0, 0);

		love.graphics.setColor(255, 255, 255);
		love.graphics.draw(self.titleImage, 0, 0);
	end);

	love.graphics.setColor(255, 255, 255);
	love.graphics.draw(CANVAS, CANVAS_OFFSET_X, CANVAS_OFFSET_Y, 0, CANVAS_SCALE, CANVAS_SCALE);
end