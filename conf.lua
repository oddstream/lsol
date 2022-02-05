-- configuration file run before main.lua
-- see https://love2d.org/wiki/Config_Files

function love.conf(t)
	t.identity = 'solvi' -- name of the save directory
	t.modules.joystick = false
	t.window.width = 1024
	t.window.height = 768
	t.window.title = 'Solitaire'
	-- TODO add t.window.icon
end