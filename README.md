# love-joycon
This is a project that adds Joy-Con support to LÖVE. Additionally, the library remaps the Pro Controller to match its button layout and add support for the capture button.

This library doesn't work properly with Windows due to misnaming of the controllers. It looks to be a problem with SDL?

To run the demo on Windows, you have to register connected controllers manually. To register a Joy-Con, hold L/R + ZL/ZR, then click the joystick. To register a Pro Controller, hold L + R, then press the capture button.

## Usage
You need to pass the four `love.joystick*` functions' arguments to `joycon`.

```lua
function love.joystickpressed(joystick, button)
	joycon.joystickpressed(joystick, button)
end

function love.joystickreleased(joystick, button)
	joycon.joystickreleased(joystick, button)
end

function love.joystickaxis(joystick, axis, value)
	joycon.joystickaxis(joystick, axis, value) -- The library doesn't actually do anything with axes yet due to a bug out of my control. I recommend keeping this for future compatibility.
end

function love.joystickhat(joystick, hat, direction)
	joycon.joystickhat(joystick, axis, direction)
end
```

Once you've done that, you can get Joy-Con button presses through the regular `love.gamepad*` functions.

### Merging Joy-Cons
If you have two Joy-Cons you want to merge into a single controller, you can do so by passing each Joy-Con's joystick object to `joycon.merge(joystick1, joystick2)`. This remaps the Joy-Cons' buttons to match the new layout. To make the Joy-Cons seperate again, you call `joycon.separate(joystick)`. You can pass either joystick to this function.
