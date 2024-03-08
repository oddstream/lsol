-- settings
-- cannot be a class because it's saved to json
-- which complains of circular reference when __index is set

local json = require 'json'
local log = require 'log'

---@class Settings
local Settings = {}

local settingsFname = 'settings.json'	-- ~/.local/share/love/LÖVE Solitaire/settings.json

local defaultSettings = {
		debug = false,
		lastVersion = 0,
		variantName = 'Klondike',
		simpleCards = false,
		powerMoves = true,
		autoCollect = false,
		safeCollect = false,
		muteSounds = false,
		mirrorBaize = false,
		baizeColor = 'ForestGreen',
		cardBackColor = 'CornflowerBlue',
		cardFaceColor = 'Ivory',
		clubColor = 'DarkGreen',
		diamondColor = 'DarkBlue',
		heartColor = 'Crimson',
		spadeColor = 'Black',
		hintColor = 'Gold',
		autoColorCards = false,
		cardRoundness = 12,
		cardOutline = true,
		-- DefaultRatio = 1.444
		-- BridgeRatio  = 1.561
		-- PokerRatio   = 1.39
		-- OpsoleRatio  = 1.5556 // 3.5/2.25
		cardRatioPortrait = 1.444,
		cardRatioLandscape = 1.39,
		cardScrunching = true,
		allowOrientation = true,	-- requires restart
		gradientShading = true,
		aniSpeed = 0.5,
}

---@return table
function Settings.load()
	local settings
	local info = love.filesystem.getInfo(settingsFname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		local contents, size = love.filesystem.read(settingsFname)
		if not contents then
			log.error(size)
		else
			-- log.info('loaded', size, 'bytes from', settingsFname)
			local ok
			ok, settings = pcall(json.decode, contents)
			if not ok then
				-- settings is now an error message
				log.error('error decoding', settingsFname, settings)
				settings = nil
			end
		end
	else
		log.info('not loading', settingsFname)
	end
	-- add any settings we have added to the default set which aren't yet in the settings.json
	if not settings then
		log.info('creating new settings')
		settings = {}
	end
	for k, v in pairs(defaultSettings) do
		if settings[k] == nil then	-- don't use 'not'
			log.info('adding setting', k, '=', v)
			settings[k] = v
		end
	end

	local retiredSettings = {'highlightMovable','shortCards','oneColorCards','twoColorcards','fourColorCards','cardTransitionStep'}
	for _, rs in ipairs(retiredSettings) do
		if settings[rs] ~= nil then
			log.info('retiring setting', rs)
			settings[rs] = nil
		end
	end

	if settings.debug then
		log.info('settings:')
		for k, v in pairs(settings) do
			log.info(k, v, ':', type(v))
		end
	end
	return settings
end

function Settings.save(settings)
	settings.lastVersion = _G.LSOL_VERSION
	if love.system.getOS() ~= 'Android' then
		local x, y, i = love.window.getPosition()
		local w, h = love.window.getMode()
		settings.windowX = x
		settings.windowY = y
		settings.windowWidth = w
		settings.windowHeight = h
		settings.displayIndex = i
	end
	local success, message = love.filesystem.write(settingsFname, json.encode(settings))
	if success then
		-- log.info('wrote to', settingsFname)
	else
		log.error(message)
	end
end

return Settings
