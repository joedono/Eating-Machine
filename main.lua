Anim8 = require "lib/anim8";
Class = require "lib/hump/class";
GameState = require "lib/hump/gamestate";
VectorLite = require "lib/hump/vector-light";
Timer = require "lib/hump/timer";
Bump = require "lib/bump";
Inspect = require "lib/inspect";

require "lib/general";

require "config/collisions";
require "config/constants";

require "state/state-game";
require "state/state-losing";
require "state/state-lost";
require "state/state-pause";
require "state/state-splash-hive";
require "state/state-splash-love";
require "state/state-title";

function love.load()
	love.window.setFullscreen(FULLSCREEN);
	love.mouse.setVisible(true);
	love.graphics.setDefaultFilter("nearest", "nearest");

	CANVAS = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT);

	local w = love.graphics.getWidth();
	local h = love.graphics.getHeight();
	local scaleX = 1;
	local scaleY = 1;

	if FULLSCREEN then
		scaleX = w / SCREEN_WIDTH;
		scaleY = h / SCREEN_HEIGHT;
	end

	CANVAS_SCALE = math.min(scaleX, scaleY);
	CANVAS_OFFSET_X = w / 2 - (SCREEN_WIDTH * CANVAS_SCALE) / 2;
	CANVAS_OFFSET_Y = h / 2 - (SCREEN_HEIGHT * CANVAS_SCALE) / 2;

	GameState.registerEvents();
	GameState.switch(State_Splash_Hive);
end

function love.keypressed(key, unicode)
	if key == KEY_QUIT then
		love.event.quit();
	end
end

function love.gamepadpressed(joystick, button)
	if button == GAMEPAD_QUIT then
		love.event.quit();
	end
end