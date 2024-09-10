-- configuration file run before main.lua
-- see https://love2d.org/wiki/Config_Files

function love.conf(t)
	t.identity = 'LÖVE Solitaire' -- name of the save directory
	-- t.window.width = 1024
	-- t.window.height = 1024
	t.window.title = 'LÖVE Solitaire'

	-- The highdpi window flag must be enabled to use the full pixel density of a Retina screen on Mac OS X and iOS.
	-- The flag currently does nothing on Windows and Linux, and on Android it is effectively always enabled.
	t.window.highdpi = true
	t.window.usedpiscale = true			-- Enable automatic DPI scaling when highdpi is set to true as well (boolean)

	-- If set to true this allows the user to resize the game's window.
	-- In version 11.4 and later for Android, this also allows changing orientation between landscape and portrait.
	t.window.resizable = true

	t.accelerometerjoystick = false		-- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
	t.audio.mic = false					-- Request and use microphone capabilities in Android (boolean)
	t.audio.mixwithsystem = true		-- Keep background music playing when opening LOVE (boolean, iOS and Android only)

	t.modules.joystick = false
	t.modules.physics = false
	t.modules.video = false
end