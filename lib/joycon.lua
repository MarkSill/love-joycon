local joycon = {
	joycons = {}
}

local buttons = {
	a = 2,
	b = 1,
	x = 4,
	y = 3,
	l = 5,
	r = 6,
	zl = 7,
	zr = 8,
	minus = 9,
	plus = 10,
	leftstick = 11,
	rightstick = 12,
	home = 13,
	capture = 14,
	merged_lr = 15,
	merged_zlr = 16
}

-- local xbox = {
-- 	a = 2,
-- 	b = 1,
-- 	x = 4,
-- 	y = 3,
-- 	back = 9,
-- 	guide = 13,
-- 	start = 10,
-- 	leftstick = 11,
-- 	rightstick = 12,
-- 	leftshoulder = 5,
-- 	rightshoulder = 6
-- }

local function ends(str, endStr)
	return endStr == "" or str:sub(-endStr:len()) == endStr
end

local function isLeft(js)
	return ends(js:getName(), "(L)")
end

local function getJoyConButton(button)
	for k, v in pairs(buttons) do
		if v == button then
			return k
		end
	end
end

local function convertToXbox(button)
	if button == "minus" then
		button = "back"
	elseif button == "home" then
		button = "guide"
	elseif button == "plus" then
		button = "start"
	end
	return button
end

local function createJoyCon(js)
	local jc = {
		left = isLeft(js),
		merged = nil, -- default to not merging Joy-Cons (this is set to the reference to the other Joy-Con when merged)
		id = js:getID()
	}
	return jc
end

local function getJoyCon(js)
	for _, v in ipairs(joycon.joycons) do
		if v.id == js:getID() then
			return v
		end
	end
end

local function getJoystick(jc)
	for _, v in ipairs(love.joystick.getJoysticks()) do
		if v:getID() == jc.id then
			return v
		end
	end
end

local function handleJoyCon(js, jc, button, pressed)
	local b = button
	local button, value = getJoyConButton(button)
	if jc.merged then
		if button == "l" or button == "r" then
			return false
		end
		if not jc.left then
			if button == "merged_lr" then
				button = "r"
			elseif button == "merged_zlr" then
				button = "zr"
			elseif button == "a" then
				button = "x"
			elseif button == "b" then
				button = "a"
			elseif button == "y" then
				button = "b"
			elseif button == "x" then
				button = "y"
			end
			jc = jc.merged
			js = getJoystick(jc)
		else
			if button == "merged_lr" then
				button = "l"
			elseif button == "merged_zlr" then
				button = "zl"
			elseif button == "a" then
				button = "dpdown"
			elseif button == "b" then
				button = "dpleft"
			elseif button == "y" then
				button = "dpup"
			elseif button == "x" then
				button = "dpright"
			end
		end
	else
		if button == "merged_lr" or button == "merged_zlr" then
			return false
		end
		if not jc.left then
			if button == "rightstick" then
				button = "leftstick"
			end
		end
	end
	if button == "zr" then
		button = "triggerright"
		if pressed then value = 1 else value = 0 end
	elseif button == "zl" then
		button = "triggerleft"
		if pressed then value = 1 else value = 0 end
	end
	button = convertToXbox(button)
	if value then
		if love.gamepadaxis then
			love.gamepadaxis(js, button, value)
		end
	elseif pressed then
		if love.gamepadpressed then
			love.gamepadpressed(js, button)
		end
	else
		if love.gamepadreleased then
			love.gamepadreleased(js, button)
		end
	end
	return true
end

function joycon.joystickpressed(js, button)
	local jc = getJoyCon(js)
	if jc then
		return handleJoyCon(js, jc, button, true)
	elseif js:getName() == "Pro Controller" then
		if button == buttons.capture then
			if love.gamepadpressed then
				love.gamepadpressed(js, "capture")
			end
		end
	end
	return false
end

function joycon.joystickreleased(js, button)
	local jc = getJoyCon(js)
	if jc then
		return handleJoyCon(js, jc, button)
	end
	return false
end

function joycon.joystickhat(js, hat, direction)
	local jc = getJoyCon(js)
	if jc then
		local actions = {direction:sub(1, 1)}
		if direction:len() == 2 then
			actions[2] = direction:sub(2, 2)
		end
		local x, y
		for _, action in ipairs(actions) do
			if action == "u" then
				y = 1
			elseif action == "d" then
				y = -1
			elseif action == "r" then
				x = 1
			elseif action == "l" then
				x = -1
			elseif action == "c" then
				x, y = 0, 0
			end
		end
		local xAxis, yAxis = "leftx", "lefty"
		if jc.merged then
			if not jc.left then
				xAxis, yAxis = "rightx", "righty"
				js = getJoystick(jc.merged)
			end
		end
		if love.gamepadaxis then
			if x then
				love.gamepadaxis(js, xAxis, x)
			end
			if y then
				love.gamepadaxis(js, yAxis, y)
			end
		end
		if x or y then
			return true
		end
	end
	return false
end

function joycon.joystickaxis(js, axis, value)
	return false -- Joy-Cons use hats instead of the axis with LOVE for some reason. Hopefully this'll be fixed in the future.
end

function joycon.joystickadded(js)
	local name = js:getName()
	local guid = js:getGUID()
	if name == "Pro Controller" then
		-- Pro Controller only needs its ABXY button mappings' changed.
		love.joystick.setGamepadMapping(guid, "a", "button", buttons.a)
		love.joystick.setGamepadMapping(guid, "b", "button", buttons.b)
		love.joystick.setGamepadMapping(guid, "x", "button", buttons.x)
		love.joystick.setGamepadMapping(guid, "y", "button", buttons.y)
	elseif name == "Joy-Con (R)" then -- Joy-Cons require a bit more work
		table.insert(joycon.joycons, createJoyCon(js))
	elseif name == "Joy-Con (L)" then
		table.insert(joycon.joycons, createJoyCon(js))
	else
		return false
	end
	return true
end

function joycon.merge(js1, js2)
	local jc1 = getJoyCon(js1)
	local jc2 = getJoyCon(js2)
	jc1.merged = jc2
	jc2.merged = jc1
end

function joycon.separate(js1)
	local jc = getJoyCon(js1)
	local js2 = getJoystick(jc.merged)
	jc.merged.merged = nil
	jc.merged = nil
end

function joycon.isJoyCon(js)
	return getJoyCon(js) ~= nil
end

function joycon.isLeftJoyCon(js)
	return isLeft(js)
end

return joycon
