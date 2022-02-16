-- Settings.lua

local json = require 'json'
local log = require 'log'

local Settings = {}
Settings.__index = Settings

local fname = 'settings.json'

function Settings.new()
	local o = {
		lastVersion = 0,
		lastVariant = 'Klondike',
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

--[[
	Each game is granted a single directory on the system where files can be saved through love.filesystem.
	This is the only directory where love.filesystem can write files.
	Files that are opened for write or append will always be created in the save directory.
	The same goes for other operations that involve writing to the filesystem, like createDirectory.
	Files that are opened for read will be looked for in the save directory, and then in the .love archive (in that order).
	So if a file with a certain filename (and path) exist in both the .love archive and the save folder, the one in the save directory takes precedence.
]]

function Settings:load()
	-- seems to automagically read from love.filesystem.getSaveDirectory()
	-- which is currently /home/gilbert/.local/share/love/patience
	local contents, size = love.filesystem.read(fname)
	if contents then
		local decoded = json.decode(contents)
		if not decoded then
			log.error('Settings.load() json not decoded')
		else
			for k,v in pairs(decoded) do
				-- trace('setting', k, v)
				self[k] = v
			end
		end
		log.info(size, 'bytes of settings loaded from', fname)
	-- any newly added settings not present in settings.json will be picked up from prototype object
	-- for k,v in pairs(self) do
	--   trace('self setting',k,v)
	-- end
	else
		if type(size) == 'string' then
			log.error(size)
		end
	end
end

function Settings:save()
	-- seems to automagically write to love.filesystem.getSaveDirectory()
	-- (creating the directory if needed)
	-- which is currently /home/gilbert/.local/share/love/patience
	self.lastVersion = _G.PATIENCE_VERSION
	self.lastVariant = _G.BAIZE.variantName
	local data = json.encode(self)
	local success, message = love.filesystem.write(fname, data)
	if success then
		log.info('settings written to', fname)
	else
		log.error(message)
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