require("lib.love_helper")
joycon = require("joycon")

local leftJoyCon, rightJoyCon
local log = {}

function l.update(dt)
	for _, js in ipairs(lj.getJoysticks()) do
		if joycon.isJoyCon(js) or js:isGamepad() then
		else
			if js:isDown(joycon.buttons.merged_lr) and js:isDown(joycon.buttons.merged_zlr) then
				if js:isDown(joycon.buttons.leftstick) then
					joycon.registerController(js, "Joy-Con (L)")
				elseif js:isDown(joycon.buttons.rightstick) then
					joycon.registerController(js, "Joy-Con (R)")
				end
			elseif js:isDown(js, joycon.buttons.capture) and js:isDown(js, joycon.buttons.l) and js:isDown(js, joycon.buttons.r) then
				joycon.registerController(js, "Pro Controller")
			end
		end
	end
end

function l.draw()
	lg.print("Press + on the right Joy-Con and - on the left Joy-Con, then home to merge. Press the capture button to separate.")
	for i, v in ipairs(log) do
		lg.print(v, 0, i * 15)
	end
end

function l.keypressed(key, scancode, isRepeat)
	if key == "escape" then
		le.quit()
	end
end

function l.gamepadpressed(js, button)
	table.insert(log, js:getName() .. ": " .. button)
	-- print(js:getName(), button)
	if joycon.isJoyCon(js) then
		if button == "back" then
			leftJoyCon = js
		elseif button == "start" then
			rightJoyCon = js
		elseif button == "guide" and leftJoyCon and rightJoyCon then
			joycon.merge(leftJoyCon, rightJoyCon)
		elseif button == "capture" and leftJoyCon and rightJoyCon then
			joycon.separate(leftJoyCon)
		end
	end
end

function l.joystickadded(js)
	joycon.joystickadded(js)
end

function l.joystickpressed(js, button)
	joycon.joystickpressed(js, button)
end

function l.joystickreleased(js, button)
	joycon.joystickreleased(js, button)
end

function l.joystickhat(js, hat, direction)
	joycon.joystickhat(js, hat, direction)
end

function l.joystickaxis(js, axis, value)
	joycon.joystickaxis(js, axis, value)
end

function l.gamepadaxis(js, axis, value)
	print(js:getName(), axis, value)
end
