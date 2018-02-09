playerCollision = function(player, other)
	return nil;
end

swimmerCollision = function(swimmer, other)
	if other.type == "corpse" then
		return "cross";
	end

	return nil;
end

sharkCollision = function(shark, other)
	if other.type == "corpse" then
		return "cross";
	end

	return nil;
end

hunterCollision = function(hunter, other)
	return nil;
end

victimFilter = function(other)
	if other.type == "swimmer" then
		return true;
	end

	if other.type == "corpse" then
		return true;
	end

	return false;
end

hunterTargetFilter = function(other)
	if other.type == "shark" and other.active then
		return true;
	end

	if other.type == "player" then
		return true;
	end

	return false;
end