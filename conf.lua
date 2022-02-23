-- configuration file run before main.lua
-- see https://love2d.org/wiki/Config_Files

function love.conf(t)
	t.identity = 'patience' -- name of the save directory
	t.modules.joystick = false
	t.window.width = 1024
	t.window.height = 1024
	t.window.title = 'LÕVE Solitaire'
	t.window.resizable = true
	t.window.icon = 'assets/appicon.png'

	t.modules.joystick = false
	t.modules.physics = false
end