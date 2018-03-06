l = love
la = l.audio
le = l.event
lf = l.filesystem
lfn = l.font
lg = l.graphics
li = l.image
lj = l.joystick
lk = l.keyboard
lmt = l.math
lm = l.mouse
lp = l.physics
lso = l.sound
ls = l.system
lth = l.thread
lt = l.timer
lto = l.touch
lv = l.video
lw = l.window

package.path = package.path .. ";lib/?.lua;lib/?/init.lua"

osName = ls.getOS():lower()
local extension = "so"
if osName == "windows" then
	extension = "dll"
end
package.cpath = package.cpath .. ";lib/natives/" .. osName .. "/?." .. extension
