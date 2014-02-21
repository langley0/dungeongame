StatWindow = Core.class(Sprite)

local stat_window_bg_texture = Texture.new("windows/window_bg.png")
local stat_frame_texture = Texture.new("windows/statwindow/stat_frame.png")

local temp_character_portrait_texture = Texture.new("windows/statwindow/sample_character_portrait.png")
local temp_skillimage_texture = Texture.new("windows/skillwindow/sample_skill_image.png")

function StatWindow:init()
	local bg = Bitmap.new(stat_window_bg_texture)
	self:addChild(bg)
	
	self.width = bg:getWidth()
	self.height = bg:getHeight()
	
	-- stat window의 위치는 화면 정중앙이다.
	local cx = application:getContentWidth()
	local cy = application:getContentHeight()
	self:setPosition((cx-self.width) * 0.5, (cy-self.height) * 0.5)
	
	local windowTitle = CreateTextWithSize("STATS", 48)
	windowTitle:setPosition(self.width - 40 - windowTitle:getWidth(), 70)
	windowTitle:setTextColor(0xffffff)
	self:addChild(windowTitle)
end

function StatWindow:SetCharactorInfo(portrait, name, class)
	-- portrait
	local portrait = Bitmap.new(portrait)
	portrait:setAnchorPoint(0.5, 0.5)
	portrait:setPosition(140, 180)
	self:addChild(portrait)
	
	-- name, class
	local nameText = CreateTextWithSize(name, 26)
	nameText:setPosition(140 - nameText:getWidth() * 0.5, 340)
	nameText:setTextColor(0xffffff)
	self:addChild(nameText)
	
	local classText = CreateTextWithSize(class, 22)
	classText:setPosition(210 - classText:getWidth(), 370)
	classText:setTextColor(0xffffff)
	self:addChild(classText)

end

function StatWindow:SetTotalStatCount(count)
	-- 스탯 처음 나올 위치 계산 때문에 필요함.
	self.startY = 130
	self.spacingY = 50
	if count > 16 then
		self.startY = self.startY - self.spacingY
	end
	
	self.newStatIndex = 1
end

function StatWindow:AddStat(statData)
	-- 여기 처음 호출하기 전에 SetStatCount가 호출되어야 함.
	local getStatFramePosition = function(statIndex)
		local x
		
		if statIndex % 2 == 1 then
			x = 255
		else
			x = 610
		end
		
		local y = self.startY
		local j = math.floor((statIndex - 1) * 0.5)
		
		y = y + j * self.spacingY
		
		return x, y
	end
	
	local frameLayer = Sprite.new()
	local x, y = getStatFramePosition(self.newStatIndex)
	frameLayer:setPosition(x, y)
	self:addChild(frameLayer)
	
	local statframe = Bitmap.new(stat_frame_texture)
	frameLayer:addChild(statframe)
	
	local halfFrameWidth = statframe:getWidth() * 0.5
	local statname = CreateTextWithSize(statData.name.." :", 20)
	statname:setPosition(halfFrameWidth - statname:getWidth() - 3, 28)
	statname:setTextColor(0xffffff)
	frameLayer:addChild(statname)
	local statvalue = CreateTextWithSize(statData.value, 20)
	statvalue:setPosition(halfFrameWidth + 3, 28)
	statvalue:setTextColor(0x00ff00)
	frameLayer:addChild(statvalue)
	
	self.newStatIndex = self.newStatIndex + 1
end

function StatWindow.create(stats)
	local window = StatWindow.new()
	
	window:SetCharactorInfo(temp_character_portrait_texture, "하마는입이커", "SPACEMAN")
	
	local statCount = #stats
	window:SetTotalStatCount(statCount)
	
	for i = 1, #stats do
		window:AddStat(stats[i])
	end
	
	-- 창의 배경 바깥 영역을 터치하면 사라지기.
	local touchFunc = function(self, event)
		if not self:hitTestPoint(event.touch.x, event.touch.y) then
			event:stopPropagation()
			self:removeFromParent()
		end
	end
	window:addEventListener(Event.TOUCHES_BEGIN, touchFunc, window)
	
	return window
end