-- configuration file run before main.lua
-- see https://love2d.org/wiki/Config_Files

function love.conf(t)
	t.identity = 'LÖVE Solitaire' -- name of the save directory
	-- t.window.width = 1024
	-- t.window.height = 1024
	t.window.title = 'LÕVE Solitaire'

	-- The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS.
	-- The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	t.window.highdpi = true

	-- If set to true this allows the user to resize the game's window.
	-- In version 11.4 and later for Android, this also allows changing orientation between landscape and portrait.
	t.window.resizable = true

	t.modules.joystick = false
	t.modules.physics = false
end