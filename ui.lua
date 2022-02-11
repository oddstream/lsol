-- ui

local UI = {
	-- titlebar
	-- toast manager
	-- statusbar
}
UI.__index = UI

function UI.new()
	local o = {}
	setmetatable(o, UI)
	return o
end

function UI:layout()
end

function UI:update(dt)
end

function UI:draw()
end

return UI
