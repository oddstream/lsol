-- Settings.lua

local json = require 'json'
local log = require 'log'

local Settings = {}
Settings.__index = Settings

local filePath = love.filesystem.getWorkingDirectory() .. '/patience-settings.json'

function Settings.new()
	local o = {
		lastVersion = 0,
		lastVariant = 'Simple Simon',
		highlightMovable = true,
		cardTransitionStep = 0.025,
		cardRatio = 1.357,
		cardDesign = 'Regular',
		powerMoves = true,
		muteSound = false,
		mirrorBaize = false,
		baizeColor = 'DarkGreen',
		cardBackColor = 'CornflowerBlue',
		cardFaceColor = 'Ivory',
		cardBorderColor = 'Silver',
		cardFaceHighlightColor = 'Gold',
		clubColor = 'DarkBlue',
		diamondColor = 'DarkGreen',
		heartColor = 'Crimson',
		spadeColor = 'Black',
		fourColorCards = true,
	}
	setmetatable(o, Settings)

	o:load()
	log.info('last played with version', o.lastVersion)

	return o
end

function Settings:load()
	local file, msg = io.open(filePath, 'r')
	if file then
		local contents = file:read('*a')
		io.close(file)
		-- log.info('settings loaded from file', contents)
		local decoded = json.decode(contents)
		if not decoded then
			log.error('Settings.load() json not decoded')
		else
		for k,v in pairs(decoded) do
			-- trace('setting', k, v)
			self[k] = v
		end
	end
	-- any newly added settings not present in settings.json will be picked up from prototype object
	-- for k,v in pairs(self) do
	--   trace('self setting',k,v)
	-- end
	else
		log.error('cannot open', filePath, msg)
	end
end

function Settings:save()
	local file, msg = io.open(filePath, 'w')
	if file then
		self.lastVersion = _G.PATIENCE_VERSION
		file:write(json.encode(self, {indent=true}))
		log.info('settings written to', filePath)
		io.close(file)
	else
		log.error('cannot open', filePath, msg)
	end
end

function Settings:colorBytes(s)
	if not self[s] then
		log.error('No setting for', s)
		return 0.5, 0.5, 0.5
	end
	if not _G.PATIENCE_COLORS[self[s]] then
		log.error('No color for', s)
		return 0.5, 0.5, 0.5
	end
	return love.math.colorFromBytes(unpack(_G.PATIENCE_COLORS[self[s]]))
end

return Settings