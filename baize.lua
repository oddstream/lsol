-- baize

local Baize = {
	-- variantName

	-- script
	-- piles

	-- cells
	-- discards
	-- foundations
	-- reserves
	-- stock
	-- tableaux
	-- waste

	-- numberOfCards (in lieu of a card library)
	-- undoStack
	-- bookmark
}
Baize.__index = Baize

function Baize.new()
	local o = {variantName = 'Freecell'}
	setmetatable(o, Baize)
	return o
end

local Variants = {
	Freecell = {file = 'freecell.lua', params={}},
	Klondike = {file = 'klondike.lua', params={}},
	['Simple Simon'] = {file = 'simplesimon.lua', params = {}},
}

function Baize:loadScript()
	for v, _ in pairs(Variants) do
		print(v)
	end
	local vinfo = Variants[self.variantName]
	if not vinfo then
		print('ERROR Unknown variant', self.variantName)
		return nil
	end
	local fname = 'variants/' .. vinfo.file
	print('looking for file', fname)

	local info = love.filesystem.getInfo('variants', 'directory')
	if not info then
		print('ERROR no variants directory')
		return nil
	end

	info = love.filesystem.getInfo(fname, 'file')
	if not info then
		print('ERROR no file called', fname)
		return nil
	end

	local ok, chunk, result
	ok, chunk = pcall(love.filesystem.load, fname) -- load the chunk safely
	if not ok then
		print('ERROR ' .. tostring(chunk))
		return nil
	else
		ok, result = pcall(chunk) -- execute the chunk safely
	end

	if not ok then -- will be false if there is an error
		print('ERROR ' .. tostring(result))
		return nil
	end

	return result
end

function Baize:createPiles()
	self.piles = {}

	-- are these weak tables?
	self.cells = {}
	self.discards = {}
	self.foundations = {}
	self.reserves = {}
	self.stock = nil
	self.tableaux = {}
	self.waste = nil

	self.script:buildPiles()
	-- layout
	-- update UI (title and status bars)
end

function Baize:stateSnapshot()
	local t = {}
	for _, pile in ipairs(self.piles) do
		table.insert(t, #pile)
	end
	return t
end

return Baize
