-- main.lua

local json = require 'json'
local log = require 'log'

local Baize = require 'baize'
local Stats = require 'stats'
local UI = require 'ui'
local Util = require 'util'

_G.LSOL_VERSION = '24'
_G.LSOL_VERSION_DATE = '2022-08-25'

if not _G.table.contains then
  function _G.table.contains(tab, val)
    for index, value in ipairs(tab) do
      if value == val then
        return true, index
      end
    end
    return false, 0
  end
end

if not _G.string.split then
	function _G.string.split (inputstr, sep)
		if sep == nil then
			sep = '%s'
		end
		local t = {}
		for str in string.gmatch(inputstr, '([^' .. sep ..']+)') do
			table.insert(t, str)
		end
		return t
	end
end

_G.LSOL_DEFAULT_SETTINGS = {
	debug = false,
	lastVersion = 0,
	variantName = 'Klondike',
	simpleCards = false,
	powerMoves = true,
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
}

_G.LSOL_VARIANTS = {
	Accordian = {file='accordian.lua', cc=4},
	['Agnes Bernauer'] = {file='agnes.lua', cc=2, bernauer=true},
	['Agnes Sorel'] = {file='agnes.lua', cc=4, sorel=true},
	Algerian = {file='algerian.lua', easy=true, cc=4},
	Alhambra = {file='alhambra.lua', cc=2},
	['American Toad'] = {file='amtoad.lua', cc=4},
	Athena = {file='klondike.lua', athena=true, cc=2},
	Assembly = {file='assembly.lua', cc=1},
	Australian = {file='australian.lua', cc=4},
	['Baker\'s Dozen'] = {file='bakers.lua', cc=1},
	['Baker\'s Dozen (Wide)'] = {file='bakers.lua', wide=true, cc=1, statsName='Baker\'s Dozen'},
	['Beleaguered Castle'] = {file='castle.lua', cc=1},
	['Busy Aces'] = {file='forty.lua', cc=4, tabs=12, cardsPerTab=1, dealAces=false},
	['Flat Castle'] = {file='castle.lua', cc=1, flat=true, statsName='Beleaguered Castle'},
	Bisley = {file='bisley.lua', cc=4},
	['Black Hole'] = {file='blackhole.lua', cc=1},
	Blockade = {file='blockade.lua', cc=4},
	-- ['Bisley Debug'] = {file='bisley.lua', cc=4, debug=true},
	Canfield = {file='canfield.lua', cc=2},
	Cruel = {file='cruel.lua', cc=4, subtype='Cruel'},
	Perseverance = {file='cruel.lua', cc=4, subtype='Perseverance'},
	['Rainbow Canfield'] = {file='canfield.lua', cc=1, rainbow=true},
	['Storehouse Canfield'] = {file='canfield.lua', cc=4, storehouse=true},
	Duchess = {file='duchess.lua', cc=2},
	-- ['Debug Klon'] = {file='debug.lua', cc=4, spiderLike=false},
	-- ['Debug Spid'] = {file='debug.lua', cc=4, spiderLike=true},
	['Eight Off'] = {file='eightoff.lua', cc=4},
	['Eight Off Relaxed'] = {file='eightoff.lua', cc=4, relaxed=true},
	Freecell = {file='freecell.lua', cc=2, bakers=false, relaxed=true},
	['Double Freecell'] = {file='freecell.lua', cc=2, relaxed=true, double=true},
	['Chinese Freecell'] = {file='freecell.lua', cc=4, relaxed=false, chinese=true},
	['Selective Freecell'] = {file='freecell.lua', cc=2, relaxed=true, selective=true},
	['Blind Freecell'] = {file='freecell.lua', cc=2, relaxed=true, blind=true},
	['Easy Freecell'] = {file='freecell.lua', cc=2, relaxed=true, easy=true},
	['Sea Haven Towers'] = {file='seahaven.lua', cc=4},
	['Baker\'s Game'] = {file='freecell.lua', bakers=true, cc=4, relaxed=false},
	['Baker\'s Game Relaxed'] = {file='freecell.lua', bakers=true, cc=4, relaxed=true},
	Gate = {file='gate.lua', cc=2},
	Klondike = {file='klondike.lua', cc=2},
	Thoughtful = {file='klondike.lua', cc=2, thoughtful=true},
	Whitehead = {file='klondike.lua', cc=2, whitehead=true},
	Gargantua = {file='klondike.lua', cc=2, gargantua=true},
	['Triple Klondike'] = {file='klondike.lua', cc=2, triple=true},
	['Klondike (Turn Three)']  = {file='klondike.lua', cc=2, turn=3},
	['Forty Thieves'] = {file='forty.lua', cc=4, tabs=10, cardsPerTab=4},
	['Forty and Eight'] = {file='forty.lua', cc=4, tabs=10, cardsPerTab=5, recycles=1},
	Josephine = {file='forty.lua', cc=4, tabs=10, cardsPerTab=4, josephine=true},
	Limited = {file='forty.lua', cc=4, tabs=12, cardsPerTab=3},
	Frog = {file='frog.lua', cc=1},
	Fly = {file='frog.lua', cc=1, dealAllAces=true},
	['Little Spider'] = {file='littlespider.lua', cc=2},
	['Little Spider (Fanned)'] = {file='littlespider.lua', cc=2, fanned=true},
	Lucas = {file='forty.lua', cc=4, tabs=13, cardsPerTab=3, dealAces=true},
	Martha = {file='martha.lua', cc=2},
	['Miss Milligan'] = {file='miss milligan.lua', cc=2},
	['Mount Olympus'] = {file='mount olympus.lua', cc=4},
	Giant = {file='miss milligan.lua', giant=true, cc=2},
	Penguin = {file='penguin.lua', cc=4},
	['Red and Black'] = {file='redandblack.lua', cc=2},
	['Royal Cotillion'] = {file='royal cotillion.lua', cc=4},
	Pyramid = {file='pyramid.lua', relaxed=false, cc=2},
	['Pyramid Relaxed'] = {file='pyramid.lua', relaxed=true, cc=2},
	Rosamund = {file='rosamund.lua', cc=2},
	Scorpion = {file='scorpion.lua', cc=4},
	Wasp = {file='scorpion.lua', cc=4, relaxed=true},
	['Simple Simon'] = {file='simplesimon.lua', cc=4},
	Spider = {file='spider.lua', packs=2, cc=4, suitFilter={'♣','♦','♥','♠'}},
	['Spider One Suit'] = {file='spider.lua', cc=1, packs=8, suitFilter={'♠'}},
	['Spider Two Suits'] = {file='spider.lua', cc=2, packs=4, suitFilter={'♥', '♠'}},
	Spiderette = {file='spider.lua', spiderette=true, cc=4, packs=1},
	['Spiderette One Suit'] = {file='spider.lua', spiderette=true, cc=1, packs=4, suitFilter={'♠'}},
	['Spiderette Two Suits'] = {file='spider.lua', spiderette=true, cc=2, packs=2, suitFilter={'♥', '♠'}},
	['Good Thirteen'] = {file='thirteens.lua', packs=1, cc=1},
	['Classic Westcliff'] = {file='westcliff.lua', cc=2, classic=true},
	['American Westcliff'] = {file='westcliff.lua', cc=2, american=true},
	Easthaven = {file='westcliff.lua', cc=2, easthaven=true},
	['Tri Peaks'] = {file='tripeaks.lua', cc=2},
	['Tri Peaks Open'] = {file='tripeaks.lua', open=true, cc=2},
	Yukon = {file='yukon.lua', cc=2},
	['Yukon Relaxed'] = {file='yukon.lua', cc=2, relaxed=true},
	['Yukon Cells'] = {file='yukon.lua', cc=2, cells=true},
	['Russian'] = {file='yukon.lua', cc=4, russian=true},
	['Crimean'] = {file='crimean.lua', cc=4, crimean=true},
	['Ukrainian'] = {file='crimean.lua', cc=4, ukrainian=true},
	['Usk'] = {file='usk.lua', cc=2, relaxed=false},
	['Usk Relaxed'] = {file='usk.lua', cc=2, relaxed=true},
	['Somerset'] = {file='somerset.lua', cc=2, relaxed=true},
}

_G.VARIANT_TYPES = {
	-- '> All' and maybe '> Favorites' will automatically be added
	['> Animals'] = {'Scorpion','Wasp','Spider One Suit','Spider Two Suits','Spider','Little Spider','Penguin','Frog','Fly'},
	['> Canfields'] = {'American Toad','Canfield','Duchess','Gate','Rainbow Canfield','Storehouse Canfield'},
	['> Easier'] = {'Accordian','American Toad','American Westcliff','Blockade','Classic Westcliff','Gate','Lucas','Martha','Mount Olympus','Spider One Suit','Red and Black','Tri Peaks','Tri Peaks Open','Wasp','Usk Relaxed','Easy Freecell'},
	['> Forty Thieves'] = {'Forty Thieves','Josephine','Limited','Lucas','Forty and Eight','Busy Aces','Red and Black'},
	['> Freecells'] = {'Blind Freecell','Easy Freecell','Selective Freecell','Chinese Freecell','Double Freecell', 'Eight Off','Eight Off Relaxed','Freecell','Baker\'s Game','Baker\'s Game Relaxed','Sea Haven Towers'},
	['> Klondikes'] = {'Athena','Gargantua','Triple Klondike','Klondike','Klondike (Turn Three)','Easthaven', 'Classic Westcliff','American Westcliff','Agnes Bernauer','Thoughtful','Whitehead'},
	['> People'] = {'Agnes Bernauer','Agnes Sorel','Athena','Baker\'s Game','Baker\'s Game Relaxed','Josephine','Martha','Miss Milligan','Rosamund'},
	['> Places'] = {'Algerian','Alhambra','Australian','Mount Olympus','Yukon','Yukon Relaxed','Russian','Crimean','Ukrainian','Usk','Usk Relaxed','Somerset'},
	['> Popular'] = {'Klondike', 'Forty Thieves','Freecell','Spider','Yukon','Tri Peaks'},
	['> Puzzlers'] = {'Beleaguered Castle','Flat Castle','Eight Off','Freecell','Penguin','Simple Simon','Baker\'s Dozen','Baker\'s Dozen (Wide)'},
	['> Redealers'] = {'Cruel','Perseverance','Usk','Usk Relaxed'},
	['> Spiders'] = {'Spider One Suit','Spider Two Suits', 'Spider','Little Spider','Little Spider (Fanned)','Spiderette','Spiderette One Suit','Spiderette Two Suits'},
}

local function createAllVariants()

	local lst = {}
	local kLongest = ''
	for k,_ in pairs(_G.LSOL_VARIANTS) do
		table.insert(lst, k)
		if #k > #kLongest then
			kLongest = k
		end
	end
	-- log.info('Longest variant name is ', kLongest)	-- Little Spider (Fanned)

	-- sorting happens after widgets are added to types/variants drawers
	_G.VARIANT_TYPES['> All'] = lst
	-- for k,_ in pairs(_G.VARIANT_TYPES) do
	-- 	print(k)
	-- 	for k2,v2 in pairs(v) do
	-- 		print(k2, v2)
	-- 	end
	-- end
end

local function createFavoriteVariants(stats)

	-- can only sort a table of keys with numeric indexes, not an associative array
	local tab = {}
	for k, _ in pairs(stats) do
		if stats[k].won and stats[k].lost then
			table.insert(tab, {vname=k, played=stats[k].won + stats[k].lost})
		end
	end

	if #tab > 2 then
		-- log.info('presort', #tab)
		-- for i, v in ipairs(tab) do
		-- 	log.info(i, v.vname, v.played)
		-- end

		-- compare function receives two arguments
		-- and must return true if the first argument should come first in the sorted array
		table.sort(tab, function(a,b) return a.played > b.played end)

		-- log.info('postsort', #tab)
		-- for i, v in ipairs(tab) do
		-- 	log.info(i, v.vname, v.played)
		-- end

		local lst = {}
		local num = math.min(7, #tab)
		for i = 1, num do
			table.insert(lst, tab[i].vname)
		end
		_G.VARIANT_TYPES['> Favorites'] = lst
		-- beware - this short list will be alpha sorted before it's displayed
	end
end

_G.LSOL_COLORS = {
	-- Basic colors (complete)
	White = {255,255,255},
	Silver = {192,192,192},
	Gray = {128,128,128},
	Black = {0,0,0},
	Red = {255,0,0},
	Maroon = {128,0,0},
	Yellow = {255,255,0},
	Olive = {128,128,0},
	Lime = {0,255,0},
	Green = {0,128,0},
	Aqua = {0,255,255},
	Teal = {0,128,128},
	Blue = {0,0,255},
	Navy = {0,0,128},
	Fuchsia = {255,0,255},
	Purple = {128,0,128},

	-- Pink colors (complete)
	MediumVioletRed = {199, 21, 133},
	DeepPink = {255,20,147},
	PaleVioletRed = {219, 112, 147},
	HotPink = {255,105,180},
	LightPink = {255,182,203},
	Pink = {255,192,203},

	-- Red colors (complete)
	DarkRed = {139,0,0},
	 -- Red
	Firebrick = {178,34,34},
	Crimson = {220,20,60},
	IndianRed = {205,92,92},
	LightCoral = {240,128,128},
	Salmon = {250,128,114},
	DarkSalmon = {233,150,122},
	LightSalmon = {255,160,122},

	-- Orange colors (complete)
	OrangeRed = {255,69,0},
	Tomato = {255, 99, 71},
	DarkOrange = {255, 140, 0},
	Coral = {255, 127, 80},
	Orange = {255, 165, 0},

	-- Yellow colors (complete)
	DarkKhaki = {189, 183, 107},
	Gold = {255,215,0},
	Khaki = {240, 230, 140},
	PeachPuff = {255, 218, 185},
	-- Yellow
	PaleGoldenrod = {238, 232, 170},
	Moccasin = {255, 228, 181},
	PapayaWhip = {255, 239, 213},
	LightGoldenrodYellow = {250, 250, 210},
	LemonChiffon = {255, 250, 205},
	LightYellow = {255, 255, 224},

	-- Brown colors (complete)
	-- Maroon
	Brown = {165, 42, 42},
	SaddleBrown = {139, 69, 19},
	Sienna = {160, 82, 45},
	Chocolate = {210, 105, 30},
	DarkGoldenrod = {184, 134, 11},
	Peru = {205, 133, 63},
	RosyBrown = {188, 143, 143},
	Goldenrod = {218, 165, 32},
	SandyBrown = {244, 164, 96},
	Tan = {210, 180, 140},
	Burlywood = {222, 184, 135},
	Wheat = {245, 222, 179},
	NavajoWhite = {255, 222, 173},
	Bisque = {255, 228, 196},
	BlanchedAlmond = {255, 235, 205},
	Cornsilk = {255, 248, 220},

	-- Green colors (complete)
	DarkGreen = {  0, 100,   0},
	-- Green
	DarkOliveGreen = { 85, 107,  47},
	ForestGreen = { 34, 139,  34},
	SeaGreen = { 46, 139,  87},
	-- Olive
	OliveDrab = {107, 142,  35},
	MediumSeaGreen = { 60, 179, 113},
	LimeGreen = { 50, 205,  50},
	-- Lime
	SpringGreen = {  0, 255, 127},
	MediumSpringGreen = {  0, 250, 154},
	DarkSeaGreen = {143, 188, 143},
	MediumAquamarine = {102, 205, 170},
	YellowGreen = {154, 205,  50},
	LawnGreen = {124, 252,   0},
	Chartreuse = {127, 255,   0},
	LightGreen = {144, 238, 144},
	GreenYellow = {173, 255,  47},
	PaleGreen = {152, 251, 152},

	-- Cyan colors (complete)
	-- Teal
	DarkCyan = {0, 139, 139},
	LightSeaGreen = {32, 178, 170},
	CadetBlue = {95, 158, 160},
	DarkTurquoise = {0, 206, 209},
	MediumTurquoise = {72, 209, 204},
	Turquoise = {64, 224, 208},
	-- Aqua
	Cyan = {0, 255, 255},
	Aquamarine = {127, 255, 212},
	PaleTurquoise = {175, 238, 238},
	LightCyan = {224, 255, 255},

	-- Blue colors (complete)
	-- Navy
	DarkBlue = {0,   0, 139},
	MediumBlue = {0,   0, 205},
	-- Blue
	MidnightBlue = {25,  25, 112},
	RoyalBlue = {65, 105, 225},
	SteelBlue = {70, 130, 180},
	DodgerBlue = {30, 144, 255},
	DeepSkyBlue = {0, 191, 255},
	CornflowerBlue = {100, 149, 237},
	SkyBlue = {135, 206, 235},
	LightSkyBlue = {135, 206, 250},
	LightSteelBlue = {176, 196, 222},
	LightBlue = {173, 216, 230},
	PowderBlue = {176, 224, 230},

	-- Purple, violet, and magenta colors (complete)
	Indigo = {75,   0, 130},
	-- Purple
	DarkMagenta = {139,   0, 139},
	DarkViolet = {148,   0, 211},
	DarkSlateBlue = {72,  61, 139},
	BlueViolet = {138,  43, 226},
	DarkOrchid = {153,  50, 204},
	-- Fuchsia
	Magenta = {255,   0, 255},
	SlateBlue = {106,  90, 205},
	MediumSlateBlue = {123, 104, 238},
	MediumOrchid = {186,  85, 211},
	MediumPurple = {147, 112, 219},
	Orchid = {218, 112, 214},
	Violet = {238, 130, 238},
	Plum = {221, 160, 221},
	Thistle = {216, 191, 216},
	Lavender = {230, 230, 250},

	-- White colors (complete)
	MistyRose = {255, 228, 225},
	AntiqueWhite = {250, 235, 215},
	Linen = {250, 240, 230},
	Beige = {245, 245, 220},
	WhiteSmoke = {245, 245, 245},
	LavenderBlush = {255, 240, 245},
	OldLace = {253, 245, 230},
	AliceBlue = {240, 248, 255},
	Seashell = {255, 245, 238},
	GhostWhite = {248, 248, 255},
	Honeydew = {240, 255, 240},
	FloralWhite = {255, 250, 240},
	Azure = {240, 255, 255},
	MintCream = {245, 255, 250},
	Snow = {255, 250, 250},
	Ivory = {255, 255, 240},

	-- Gray and black colors (complete)
	-- Black
	DarkSlateGray = {47,79,79},
	DimGray = {105,105,105},
	SlateGray = {112, 128, 144},
	-- Gray
	LightSlateGray = {119, 136, 153},
	DarkGray = {169, 169, 169},
	-- Silver
	LightGray = {211, 211, 211},
	Gainsboro = {220, 220, 220},

	UiBackground = {0x32,0x32,0x32,0xff},
	UiForeground = {0xff,0xff,0xff,0xff},
	UiGrayedOut = {0x80,0x80,0x80,0xff},
}

--[[
	Using Acme (semi-bold) for card ordinals and pile labels
	Alternatives:
		CARDC___.TTF (also includes suit symbols)
		RobotoSlab-SemiBold.ttf (more traditional card look)
		RobotoCondensed-Regular.ttf
	https://fonts.google.com/
]]

-- _G.ORD_FONT = 'assets/fonts/RobotoCondensed-Regular.ttf'
_G.ORD_FONT = 'assets/fonts/Acme-Regular.ttf'
_G.SUIT_FONT = 'assets/fonts/DejaVuSans.ttf'
_G.UI_MEDIUM_FONT = 'assets/fonts/Roboto-Medium.ttf'
_G.UI_REGULAR_FONT = 'assets/fonts/Roboto-Regular.ttf'

_G.LSOL_SOUNDS = {
	deal = love.audio.newSource('assets/sounds/cardFan1.wav', 'static'),
	load = love.audio.newSource('assets/sounds/cardFan2.wav', 'static'),
	move1 = love.audio.newSource('assets/sounds/cardPlace3.wav', 'static'),
	move2 = love.audio.newSource('assets/sounds/cardPlace4.wav', 'static'),
	move3 = love.audio.newSource('assets/sounds/cardPlace1.wav', 'static'),
	move4 = love.audio.newSource('assets/sounds/cardPlace2.wav', 'static'),
	undo = love.audio.newSource('assets/sounds/cardOpenPackage2.wav', 'static'),
	menushow = love.audio.newSource('assets/sounds/cardSlide1.wav', 'static'),
	menuhide = love.audio.newSource('assets/sounds/cardSlide2.wav', 'static'),
	uitap =  love.audio.newSource('assets/sounds/cardSlide8.wav', 'static'),
	complete = love.audio.newSource('assets/sounds/complete.wav', 'static'),
	blip = love.audio.newSource('assets/sounds/249895__alienxxx__blip2.wav', 'static'),
	fail = love.audio.newSource('assets/sounds/237422__plasterbrain__hover-1.ogg', 'static'),
}

_G.ORD2STRING = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

_G.consoleLogMessages = {}

function _G.consoleLog(msg)
	table.insert(_G.consoleLogMessages, 1, msg)
end

function _G.drawConsoleLogMessages()
	love.graphics.setColor(1,1,1,1)
	local y = (_G.UI_SAFEY + _G.UI_SAFEH) - _G.STATUSBARHEIGHT
	for i = 1, #_G.consoleLogMessages do
		y = y - 24
		if y < _G.TITLEBARHEIGHT then
			break
		end
		love.graphics.print(_G.consoleLogMessages[i], 8, y)
	end
end

-- ~/.local/share/love/LÖVE Solitaire/settings.json
local settingsFname = 'settings.json'

local function loadSettings()
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
	for k, v in pairs(_G.LSOL_DEFAULT_SETTINGS) do
		if settings[k] == nil then	-- don't use 'not'
			log.info('adding setting', k, '=', v)
			settings[k] = v
		end
	end

	local retiredSettings = {'highlightMovable','shortCards','oneColorCards','twoColorcards','fourColorCards'}
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

function _G.saveSettings()
	_G.SETTINGS.lastVersion = _G.LSOL_VERSION
	if love.system.getOS() ~= 'Android' then
		local x, y, i = love.window.getPosition()
		local w, h = love.window.getMode()
		_G.SETTINGS.windowX = x
		_G.SETTINGS.windowY = y
		_G.SETTINGS.windowWidth = w
		_G.SETTINGS.windowHeight = h
		_G.SETTINGS.displayIndex = i
	end
	local success, message = love.filesystem.write(settingsFname, json.encode(_G.SETTINGS))
	if success then
		-- log.info('wrote to', settingsFname)
	else
		log.error(message)
	end
end

local function createWindowIcon()
	local size = 32	-- small size let the OS fuzz it up
	local heart = '♥'

	local canvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas

	love.graphics.setColor(love.math.colorFromBytes(unpack(_G.LSOL_COLORS['HotPink'])))
	local fnt = love.graphics.newFont(_G.SUIT_FONT, size)
	love.graphics.setFont(fnt)
	local w = fnt:getWidth(heart)
	local h = fnt:getHeight()

	love.graphics.print(heart, size/2 - w/2, size/2 - h/2)

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas:newImageData()
end

function love.load(args)
--[[
Lua (and some engines based on it, like LÖVE) has output buffered by default,
so if you only print a small number of bytes,
you may see the results only after the script is completed.

If you want to see the print output immediately,
add io.stdout:setvbuf("no") to your script,
which will turn the buffering off.

There may be a small performance penalty as the output will be flushed after each print.
]]

-- required for ZeroBrane
--[[
	io.stdout:setvbuf('no')	-- 'no', 'full' or 'line'

	if args then
		for k, v in pairs(args) do
			print(k, v)
		end
		if arg[#arg] == "-debug" then require("mobdebug").start() end
	end
]]

--[[
	print(Util.lerp(1.0, 0.0, 0.25))
	print(Util.lerp(1.0, 0.0, 0.5))
	print(Util.lerp(1.0, 0.0, 0.75))

	print(Util.lerp(0.0, 1.0, 0.25))
	print(Util.lerp(0.0, 1.0, 0.5))
	print(Util.lerp(0.0, 1.0, 0.75))
]]
	math.randomseed(os.time())

	--[[
		Lenovo Tab M10 HD Gen 2		800 x 1280 pixels, 16:10 ratio (~149 ppi density)
		https://www.gsmarena.com/lenovo_tab_m10_hd_gen_2-10406.php

		Motorola Moto G4			1080 x 1920 pixels, 16:9 ratio (~401 ppi density)
		https://www.gsmarena.com/motorola_moto_g4-8103.php

		Motorola Moto G31			1080 x 2400 pixels, 20:9 ratio (~411 ppi density)
		https://www.gsmarena.com/motorola_moto_g31-11225.php
		DPIScale = 2.625
	]]

	_G.UI_SCALE = 1
	local DPIScale = love.window.getDPIScale()
	if DPIScale > 1 then
		_G.UI_SCALE = 1 - (DPIScale/10)	-- so a DPIScale of 3 would scale the UI from 1.0 to 0.7
	end

	-- _G.consoleLog(string.format('DPIScale %f, UI_SCALE %f', DPIScale, _G.UI_SCALE))

	-- https://love2d.org/forums/viewtopic.php?f=3&t=84348&p=215242&hilit=rounded+rectangle#p215242
	local limits = love.graphics.getSystemLimits( )
	-- log.info(limits.canvasmsaa)	-- 16
	-- log.info(limits.texturesize)	-- 16384
	-- log.info(limits.multicanvas)	-- 8

	-- turn off anti-aliasing to stop Gargantua stock black corners problem
	-- default is 'linear', linear', 1
	-- print('defaultFilter', love.graphics.getDefaultFilter( ))
	love.graphics.setDefaultFilter('nearest', 'nearest', 1)

	_G.SETTINGS = loadSettings()

	if args then
		for _, v in ipairs(args) do	-- using ipairs ignores the -ve args (-1 embedded boot.lua, -2 love)
			local t = _G.string.split(v, '=')
			if #t == 2 then
				local set = t[1]
				local val = t[2]
				if _G.SETTINGS[set] then
					log.info('setting', set, 'to', val)
					_G.SETTINGS[set] = val
				else
					log.error('unknown setting', set)
				end
			else
				log.warn('ignoring', v)
			end
		end
	end

--[[
	do
		local width, height, flags = love.window.getMode( )
		print('width', width, 'height', height)
		for k, v in pairs(flags) do
			print(k, '=', v)
		end
	end
]]

	-- trying to use antialiasing to get rid of jagged rounded rectangles
	-- https://love2d.org/forums/viewtopic.php?f=3&t=84348&p=215242&hilit=rounded+rectangle&sid=6ce64568192cd62b80b22ec79b4fdcda

	do
		local s = _G.SETTINGS
		if love.system.getOS() == 'Android' then
			-- w, h seem to be ignored when resizable=true, window is sized by Android
			-- set w, h when resizable=false to get correct orientation
			local opts = {usedpiscale=true, msaa=limits.canvasmsaa, resizable=s.allowOrientation}
			local w, h = love.window.getSafeArea()
			love.window.setMode(w, h, opts)
		else
			love.window.setIcon(createWindowIcon())

			-- log.info('limits.canvasmsaa', limits.canvasmsaa)	-- 16 on BLACKBOX
			local opts = {resizable=true, minwidth=640, minheight=480, msaa=limits.canvasmsaa}
			if s.windowWidth and s.windowHeight then
				love.window.setMode(s.windowWidth, s.windowHeight, opts)
			else
				love.window.setMode(1080/2, 1920/2, opts)
			end
		end
	end

	_G.TITLEBARHEIGHT = 48 * _G.UI_SCALE
	_G.STATUSBARHEIGHT = 24 * _G.UI_SCALE
	_G.UIFONTSIZE = 22 * _G.UI_SCALE
	_G.UIFONTSIZE_TITLEBAR = 22  * _G.UI_SCALE
	_G.UIFONTSIZE_SMALL = 14  * _G.UI_SCALE

	-- default lineStyle is 'smooth'
	-- print('default lineStyle = ', love.graphics.getLineStyle())
	-- love.graphics.setLineStyle('rough')

	_G.UI_SAFEX,
	_G.UI_SAFEY,
	_G.UI_SAFEW,
	_G.UI_SAFEH = love.window.getSafeArea()

	-- _G.consoleLog(string.format('safe area %d %d %d %d', love.window.getSafeArea()))
	-- _G.consoleLog(string.format('safe area toPixels %d %d %d %d',
	-- 	love.window.toPixels(_G.UI_SAFEX),
	-- 	love.window.toPixels(_G.UI_SAFEY),
	-- 	love.window.toPixels(_G.UI_SAFEW),
	-- 	love.window.toPixels(_G.UI_SAFEH)
	-- ))
	-- implies safe area returns scaled values (which we want to work in), window size reported in pixels

	-- preload the recycle icons
	-- https://materialdesignicons.com/icon/restart (>1 recycles)
	-- https://materialdesignicons.com/icon/restart-off (no more recycles)
	-- https://materialdesignicons.com/icon/restart-alert (one remaining recycle)
	do
		local fname = 'assets/icons/restart.png'
		local imageData = love.image.newImageData(fname)
		if not imageData then
			log.error('could not load', fname)
		else
			_G.LSOL_ICON_RESTART = love.graphics.newImage(imageData)
		end
		fname = 'assets/icons/restart-off.png'
		imageData = love.image.newImageData(fname)
		if not imageData then
			log.error('could not load', fname)
		else
			_G.LSOL_ICON_RESTART_OFF = love.graphics.newImage(imageData)
		end
	end

	_G.BAIZE = Baize.new()

	-- love.handlers['permissionButton'] = function(text)
	-- 	log.trace('event handler', text)
	-- end

	_G.BAIZE.stats = Stats.new()
	createAllVariants()
	createFavoriteVariants(_G.BAIZE.stats)
	_G.BAIZE.ui = UI.new()

	love.graphics.setBackgroundColor(Util.getColorFromSetting('baizeColor'))

	_G.BAIZE.ui:updateWidget('title', _G.SETTINGS.variantName)

	_G.BAIZE:loadUndoStack()
	if _G.BAIZE.undoStack then
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.SETTINGS.variantName)
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			if _G.SETTINGS.mirrorBaize then
				_G.BAIZE:mirrorSlots()
			end
			_G.BAIZE:layout()
			-- don't reset
			-- don't startGame
			_G.BAIZE.ui:toast('Resuming a saved game of ' .. _G.SETTINGS.variantName, 'load')
			_G.BAIZE:undo()	-- pop extra state written when saved, will updateUI
		else
			os.exit()
		end
	else
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.SETTINGS.variantName)
		if not _G.BAIZE.script then
			_G.SETTINGS.variantName = 'Klondike'	-- TODO save settings
			_G.BAIZE.script = _G.BAIZE:loadScript(_G.SETTINGS.variantName)
		end
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			if _G.SETTINGS.mirrorBaize then
				_G.BAIZE:mirrorSlots()
			end
			_G.BAIZE:layout()
			_G.BAIZE:resetState()
			_G.BAIZE.ui:toast('Starting a new game of ' .. _G.SETTINGS.variantName, 'deal')
			_G.BAIZE.script:startGame()
			_G.BAIZE:undoPush()
			_G.BAIZE:updateStatus()
			_G.BAIZE:updateUI()
		else
			os.exit()
		end
	end

	if _G.SETTINGS.lastVersion == 0 then
		_G.BAIZE.ui:toast(string.format('Welcome to %s', love.filesystem.getIdentity()))
	elseif _G.SETTINGS.lastVersion ~= _G.LSOL_VERSION then
		_G.BAIZE.ui:toast(string.format('%s version updated from %d to %d', love.filesystem.getIdentity(), _G.SETTINGS.lastVersion, _G.LSOL_VERSION))
	end

	-- _G.BAIZE.ui:toast(string.format('safe x=%d y=%d w=%d h=%d', love.window.getSafeArea()))
	--[[
	print(love.filesystem.getAppdataDirectory())	-- /home/gilbert/.local/share/
	print(love.filesystem.getSourceBaseDirectory())	-- /home/gilbert
	print(love.filesystem.getUserDirectory())	-- /home/gilbert/
	print(love.filesystem.getWorkingDirectory())	-- /home/gilbert/patience
	print(love.filesystem.getSaveDirectory())	-- /home/gilbert/.local/share/love/patience
]]
end

function love.update(dt_seconds)
	_G.BAIZE:update(dt_seconds)
end

function love.draw()
	_G.BAIZE:draw()
end

function love.resize(w, h)
	-- _G.consoleLog(string.format('resize %d %d', w, h))
	-- w, h = love.window.getMode()
	-- _G.consoleLog(string.format('window %d %d', w, h))
	-- _G.consoleLog(string.format('safe area %d %d %d %d', love.window.getSafeArea()))

	_G.BAIZE.backgroundCanvas = nil	-- will be recreated by Baize:draw()
	_G.BAIZE:layout()
end

function love.keyreleased(key)
	-- log.info(key)
	if key == 'u' then
		_G.BAIZE:undo()
	elseif key == 'c' then
		_G.BAIZE:collect()
	elseif key == 'h' then
		_G.BAIZE:hint()
	elseif key == 'n' then
		_G.BAIZE:newDeal()
		-- _G.BAIZE.ui:showFAB{icon='star', baizeCmd='newDeal'}
	elseif key == 'r' then
		_G.BAIZE:restartDeal()
	elseif key == 'b' then
		if love.keyboard.isDown('lshift') or love.keyboard.isDown('lctrl') then
			_G.BAIZE:gotoBookmark()
		else
			_G.BAIZE:setBookmark()
		end
	elseif key == 'd' and love.keyboard.isDown('lctrl') then
		_G.SETTINGS.debug = not _G.SETTINGS.debug
		_G.saveSettings()
		_G.BAIZE:createCardTextures()
	end

	if love.system.getOS() == 'Android' then
		if key == 'escape' then		-- Android return/back?
			love.event.quit(0)
		elseif key == 'home' then
			love.event.quit(0)
		elseif key == 'menu' then
			_G.BAIZE.ui:toggleMenuDrawer()
		elseif key == 'search' then
			_G.BAIZE.ui:showVariantTypesDrawer()
		end
	else
		if key == 'escape' then
			_G.BAIZE.ui:hideDrawers()
			_G.BAIZE.ui:cancelModalDialog()
		end
	end

	if _G.SETTINGS.debug then
		if key == 't' then
			_G.BAIZE.ui:toast(string.format('Toast %f', math.random()))
		elseif key == 'up' then
			_G.BAIZE:startSpinning()
		elseif key == 'down' then
			_G.BAIZE:stopSpinning()
		elseif key == 'f' then
			_G.BAIZE.ui:showFAB{icon='star', baizeCmd='newDeal'}
		-- elseif key == 'm' then
		-- 	local result = _G.BAIZE:getPermission('This game will count as a loss. Continue?')
		-- 	log.trace(result)
		elseif key == '8' and love.keyboard.isDown('lctrl') then
			for _, tab in ipairs(_G.BAIZE.tableaux) do
				table.sort(tab.cards, function(a,b) return a.ord > b.ord end)
				tab:refan()
			end
			_G.BAIZE:updateStatus()
			_G.BAIZE:updateUI()
		elseif key == '9' and love.keyboard.isDown('lctrl') then
			for _, tab in ipairs(_G.BAIZE.tableaux) do
				table.sort(tab.cards, function(a,b) return a.ord < b.ord end)
				tab:refan()
			end
			_G.BAIZE:updateStatus()
			_G.BAIZE:updateUI()
		elseif key == '0' and love.keyboard.isDown('lctrl') then
			for _, tab in ipairs(_G.BAIZE.tableaux) do
				for i = #tab.cards, 2, -1 do
					local j = math.random(i)
					if i ~= j then
						tab.cards[i], tab.cards[j] = tab.cards[j], tab.cards[i]
					end
				end
				tab:refan()
			end
			_G.BAIZE:updateStatus()
			_G.BAIZE:updateUI()

			-- see Card measureTime
		elseif key == 'q' then
			local flipTimeTotal = 0
			local lerpTimeTotal = 0
			local flipCountTotal = 0
			local lerpCountTotal = 0
			for _, c in ipairs(_G.BAIZE.deck) do
				flipTimeTotal = flipTimeTotal + c.flipTime
				flipCountTotal = flipCountTotal + c.flipCount
				lerpTimeTotal = lerpTimeTotal + c.lerpTime
				lerpCountTotal = lerpCountTotal + c.lerpCount
			end
			log.info('flip total=', flipCountTotal, 'time=', flipTimeTotal, 'avg=', flipTimeTotal / flipCountTotal)
			log.info('lerp total=', lerpCountTotal, 'time=', lerpTimeTotal, 'avg=', lerpTimeTotal / lerpCountTotal)

		end
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	_G.BAIZE:mousePressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
	_G.BAIZE:mouseMoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button, istouch, presses)
	_G.BAIZE:mouseReleased(x, y, button)
end

function love.wheelmoved(x, y)
	local drw = _G.BAIZE.ui:findOpenDrawer()
	if drw then
		drw:startDrag()
		drw:dragBy(0, y*24)
		drw:stopDrag()
	else
		_G.BAIZE:startDrag()
		_G.BAIZE:dragBy(x*24, y*24)
		_G.BAIZE:stopDrag()
	end
end

function love.displayrotated(index, orientation)
	-- https://love2d.org/wiki/love.displayrotated

	-- Due to a bug in LOVE 11.3, the orientation value is boolean true instead. A workaround is as follows:
	-- orientation = love.window.getDisplayOrientation(index)

	-- _G.consoleLog(string.format('displayrotated %d %s', index, orientation))

	_G.BAIZE.backgroundCanvas = nil	-- will be recreated by Baize:draw()
	_G.BAIZE:layout()

	-- if _G.SETTINGS.debug then
	-- 	_G.BAIZE.ui:toast('displayrotated ' .. tostring(orientation))
	-- 	_G.BAIZE.ui:toast(string.format('safe x=%d y=%d w=%d h=%d', love.window.getSafeArea()))
	-- end
end

function love.quit()
	-- no args
	-- don't save stats here (with _G.BAIZE.stats:save()) because never quite sure when app quits
	-- or is forced-stopped; instead, save stats when they change

	_G.saveSettings()	-- in case window has moved or resized

	-- don't save completed game, to stop win being recorded when it's reloaded
	if --[[ #_G.BAIZE.undoStack == 1 or ]] _G.BAIZE.status == 'complete' then
		_G.BAIZE:rmUndoStack()
	else
		_G.BAIZE:saveUndoStack()
	end
	return false	-- allow app to quit
end
