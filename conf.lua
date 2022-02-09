-- configuration file run before main.lua
-- see https://love2d.org/wiki/Config_Files

function love.conf(t)
	t.identity = 'patience' -- name of the save directory
	t.modules.joystick = false
	t.window.width = 1024
	t.window.height = 1024
	t.window.title = 'Patience'
	-- TODO add t.window.icon
end