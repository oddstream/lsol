-- stats
-- Ira, Evi

local json = require 'json'
local log = require 'log'

local Stats = {}
Stats.__index = Stats

local fname = 'statistics.json'

function Stats.new()
	local o = {}
	setmetatable(o, Stats)

	local info = love.filesystem.getInfo(fname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		local contents, size = love.filesystem.read(fname)
		if not contents then
			log.error(size)
		else
			log.info('loaded', size, 'bytes from', fname)
			o = json.decode(contents)
			return setmetatable(o, Stats)
		end
	else
		log.info('not loading', fname)
	end
	return o
end

function Stats:save()
	local success, message = love.filesystem.write(fname, json.encode(self))
	if success then
		log.info('wrote to', fname)
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
		}
	end
	return self[v]
end

function Stats:recordWonGame(v)
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

	log.info('recorded a won game of', v)
end

function Stats:recordLostGame(v, percent)
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

	log.info('recorded a lost game of', v)
end

function Stats:log(v)
	local s = self:findVariant(v)
	log.info('played', s.won + s.lost, 'won', s.won, 'lost', s.lost)
	log.info('average percent', averagePercent(s), 'best percent', s.bestPercent)
	if s.currStreak > 1 then
		log.info('on a winning streak of', s.currStreak)
	elseif s.currStreak < 1 then
		log.info('on a losing streak of', s.currStreak)
	end
end

function Stats:strings(v)
	local s = self:findVariant(v)
	local strs = {}
	if s.won + s.lost == 0 then
		table.insert(strs, string.format('You have not played %s before', v))
	else
		table.insert(strs, string.format('Played: %u, won: %u, lost %u', s.won+s.lost, s.won, s.lost))
		local avp = averagePercent(s)
		if avp < 100 then
			table.insert(strs, string.format('Average percent: %d', averagePercent(s)))
		end
		if s.bestPercent < 100 then
			table.insert(strs, string.format('Best percent: %d', s.bestPercent))
		end
		if s.currStreak > 0 then
			table.insert(strs, string.format('You are on a winning streak of %d', s.currStreak))
		elseif s.currStreak < 0 then
			table.insert(strs, string.format('You are on a losing streak of %d', s.currStreak))
		end
	end
	return strs
end

return Stats
