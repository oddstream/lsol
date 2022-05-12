-- stats
-- Ira, Evi

local json = require 'json'
local log = require 'log'

local Stats = {}
Stats.__index = Stats

local fname = 'statistics.json'

function Stats.new()
	local o = {}

	local info = love.filesystem.getInfo(fname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		local contents, size = love.filesystem.read(fname)
		if not contents then
			log.error(size)
		else
			-- log.info('loaded', size, 'bytes from', fname)
			local ok
			ok, o = pcall(json.decode, contents)
			if not ok then
				log.error('error decoding', fname, o)
				o = {}
			end
		end
	else
		log.info('not loading', fname)
	end
	return setmetatable(o, Stats)
end

function Stats:save()
	local success, message = love.filesystem.write(fname, json.encode(self))
	if success then
		-- log.info('wrote to', fname)
	else
		log.error(message)
	end
end

local function averagePercent(s)
	local played = s.won + s.lost
	if played > 0 then
		return (s.sumPercents + (s.won * 100)) / played
	end
	return 0
end

--[[
	Won, Lost, CurrStreak, BestStreak, WorstStreak int   `json:",omitempty"`
	Percents                                       []int `json:",omitempty"`
	// Won is number of games with 100%
	// Lost is number of games with % less than 100
	// Won + Lost is total number of games played (won or abandoned)
	// average % is ((sum of Percents) + (100 * Won)) / (Won+Lost)
]]
function Stats:findVariant(v)
	if not self[v] then
		self[v] = {
			won = 0,
			lost = 0,
			currStreak = 0,
			bestStreak = 0,
			worstStreak = 0,
			sumPercents = 0,
			bestPercent = 0,
			bestMoves = 0,
			worstMoves = 0,
			sumMoves = 0,
		}
	end
	return self[v]
end

local function statsName(v)
	if _G.LSOL_VARIANTS[v].statsName then
		log.info('recording', v, 'as', _G.LSOL_VARIANTS[v].statsName)
		v = _G.LSOL_VARIANTS[v].statsName
	end
	return v
end

function Stats:recordWonGame(v, moves)
	v = statsName(v)
	local s = self:findVariant(v)

	s.won = s.won + 1

	if s.currStreak < 0 then
		s.currStreak = 1
	else
		s.currStreak = s.currStreak + 1
	end
	if s.currStreak > s.bestStreak then
		s.bestStreak = s.currStreak
	end

	s.bestPercent = 100

	if s.bestMoves == 0 or moves < s.bestMoves then
		s.bestMoves = moves
	end
	if s.worstMoves == 0 or moves > s.worstMoves then
		s.worstMoves = moves
	end
	s.sumMoves = s.sumMoves + moves

	-- _G.BAIZE.ui:toast('Recording a completed game of', v)
end

function Stats:recordLostGame(v, percent)
	v = statsName(v)
	local s = self:findVariant(v)

	s.lost = s.lost + 1

	if s.currStreak > 0 then
		s.currStreak = -1
	else
		s.currStreak = s.currStreak - 1
	end
	if s.currStreak < s.worstStreak then
		s.worstStreak = s.currStreak
	end

	if percent > s.bestPercent then
		s.bestPercent = percent
	end
	s.sumPercents = s.sumPercents + percent

	_G.BAIZE.ui:toast(string.format('Recording a lost (%d%%) game of %s', percent, v), 'fail')
end

--[[
function Stats:log(v)
	v = statsName(v)
	local s = self:findVariant(v)
	log.info('played', s.won + s.lost, 'won', s.won, 'lost', s.lost)
	log.info('average percent', averagePercent(s), 'best percent', s.bestPercent)
	if s.currStreak > 1 then
		log.info('on a winning streak of', s.currStreak)
	elseif s.currStreak < 1 then
		log.info('on a losing streak of', s.currStreak)
	end
end
]]

function Stats:strings(v)
	v = statsName(v)
	local s = self:findVariant(v)
	local strs = {}
	if s.won + s.lost == 0 then
		table.insert(strs, 'You have not played this before')
	else
		table.insert(strs, string.format('Played: %u', s.won+s.lost))
		table.insert(strs, string.format('Won: %u', s.won))
		table.insert(strs, string.format('Lost: %u', s.lost))

		local winRate = s.won / (s.won+s.lost) * 100
		table.insert(strs, string.format('Win rate: %d%%', winRate))

		local avp = averagePercent(s)
		if avp < 100 then
			table.insert(strs, string.format('Average complete: %d%%', averagePercent(s)))
		end
		if s.bestPercent < 100 then
			-- not yet won a game
			table.insert(strs, 'You have yet to win a game')
			table.insert(strs, string.format('Best percent: %d', s.bestPercent))
		else
			-- won at least one game
			table.insert(strs, string.format('Best number of moves: %d', s.bestMoves))
			table.insert(strs, string.format('Worst number of moves: %d', s.worstMoves))
			table.insert(strs, string.format('Average number of moves: %d', s.sumMoves / s.won))
		end
		if s.currStreak > 0 then
			table.insert(strs, string.format('You are on a winning streak of %d', s.currStreak))
		elseif s.currStreak < 0 then
			table.insert(strs, string.format('You are on a losing streak of %d', s.currStreak))
		end
	end
	return strs
end

function Stats:reset(v)
	v = statsName(v)
	self[v] = nil
end

return Stats
