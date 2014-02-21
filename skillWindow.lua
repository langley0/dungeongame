
SkillWindow = Core.class(Sprite)

local skill_window_bg_texture = Texture.new("skill/skillwindow/skill_window_bg.png")
local skill_frame_texture = Texture.new("skill/skillwindow/skill_frame.png")
local skillup_buttoon_texture = Texture.new("skill/skillwindow/skillup_button.png")

local temp_skillimage_texture = Texture.new("skill/skillwindow/sample_skill_image.png")

function SkillWindow:init()
	local bg = Bitmap.new(skill_window_bg_texture)
	self:addChild(bg)
	
	self.width = bg:getWidth()
	self.height = bg:getHeight()
	
	-- skill window의 위치는 화면 정중앙이다.
	local cx = application:getContentWidth()
	local cy = application:getContentHeight()
	self:setPosition((cx-self.width) * 0.5, (cy-self.height) * 0.5)
	
	local windowTitle = CreateTextWithSize("SKILL", 48)
	windowTitle:setPosition(40, 70)
	windowTitle:setTextColor(0xffffff)
	self:addChild(windowTitle)
	
	local skillPointText = CreateTextWithSize("Skill Point : ", 28)
	skillPointText:setPosition(450, 70)
	skillPointText:setTextColor(0xffffff)
	self:addChild(skillPointText)
	
	self.skillList = {}
	self.buttonList = {}
end

function SkillWindow:AddSkill(skillData)
	-- 일단은 스크롤하는 거 없이 스킬은 최대 10종류까지만이라고 하고 간다.
	
	local newSkillIndex = #self.skillList + 1
	
	local getSkillFramePosition = function(skillIndex)
		local x = 65
		if skillIndex > 5 then
			x = 450
		end
		
		local y = 90
		local j = (skillIndex - 1) % 5
		y = y + j * 100
		
		return x, y
	end
	
	local x, y = getSkillFramePosition(newSkillIndex)
	
	local skillFrameLayer = Sprite.new()
	skillFrameLayer:setPosition(x, y)
	
	local skillframe = Bitmap.new(skill_frame_texture)
	skillFrameLayer:addChild(skillframe)
	local skillImage = Bitmap.new(temp_skillimage_texture)
	skillImage:setAnchorPoint(0.5, 0.5)
	local halfHeight = skillframe:getHeight() * 0.5
	skillImage:setPosition(halfHeight, halfHeight)
	skillFrameLayer:addChild(skillImage)
	
	local skillname = CreateTextWithSize(skillData.name, 20)
	skillname:setPosition(63, 24)
	skillname:setTextColor(0xffffff)
	skillFrameLayer:addChild(skillname)
	
	local skilllevel = CreateTextWithSize("("..skillData.level.."/"..skillData.maxlevel..")", 17)
	skilllevel:setPosition(70 + skillname:getWidth(), 24)
	skilllevel:setTextColor(0xffffff)
	skillFrameLayer:addChild(skilllevel)
	
	-- textwrap 등으로 나중에 바꿔야.
	local skilldesc = CreateTextWithSize(skillData.desc, 14)
	skilldesc:setPosition(68, skillname:getHeight() + 22)
	skilldesc:setTextColor(0xffffff)
	skillFrameLayer:addChild(skilldesc)
	
	self:addChild(skillFrameLayer)
	
	self.skillList[newSkillIndex] = {
		id = newSkillIndex, -- 나중에 스킬 아이디가 있다면 그걸..?
		level = skillData.level,
		maxlevel = skillData.maxlevel,
		levelText = skilllevel,
	}
	
	-- level up button
	if skillData.level < skillData.maxlevel then
		local newSkillButtonIndex = #self.buttonList + 1
		-- 기본적으로는 disable 상태임.
		local skillupButton = Bitmap.new(skillup_buttoon_texture)
		skillupButton:setAnchorPoint(0, 0.5)
		skillupButton:setPosition(x + skillframe:getWidth() + 10, y + halfHeight)
		self:addChild(skillupButton)
		
		self.buttonList[newSkillButtonIndex] = {
			skillIndex = newSkillIndex,
			button = skillupButton,
			window = self,
		}
	end
end

function SkillWindow:SetUsableSkillPoint(sp)
	self.sp = sp
	-- reset을 위해 기록해둠.
	self.initialSP = sp
	
	self.spText = CreateTextWithSize(sp, 28)
	self.spText:setPosition(595, 70)
	self.spText:setTextColor(0xffffff)
	self:addChild(self.spText)
	
	self:SetButtonState()
end

function SkillWindow:SetButtonState()
	local touchedFunc = function(self, event)
		if self.button:hitTestPoint(event.touch.x, event.touch.y) then
			event:stopPropagation()
			self.window:SkillLevelUp(self.skillIndex)
		end
	end
	
	if self.sp > 0 then
		-- 이벤트 달아준다.
		for i = 1, #self.buttonList do
			self.buttonList[i].button:addEventListener(Event.TOUCHES_BEGIN, touchedFunc, self.buttonList[i])
		end
	else
		-- 없앤다.
		for i = 1, #self.buttonList do
			self:removeChild(self.buttonList[i].button)
			self.buttonList[i] = nil
		end
	end
end

function SkillWindow:SkillLevelUp(skillIndex)
	-- 스킬 레벨 올리기 전에 마지막 체크. sp 있는지, 스킬이 레벨업할 수 있는 상태인지.
	if self.sp <= 0 then
		print("skill point is 0 or less than 0. cannot level up skill.")
		return
	end
	
	if skillIndex <= 0 or skillIndex > #self.skillList then
		print("wrong skill index.")
		return
	end
	
	local skill = self.skillList[skillIndex]
	if skill.level >= skill.maxlevel then
		print("skill level is max. cannot level up skill.")
	end
	
	-- 이제 올리자.
	self.sp = self.sp - 1
	skill.level = skill.level + 1
	
	skill.levelText:setText("("..skill.level.."/"..skill.maxlevel..")")
	if skill.level == skill.maxlevel then
		-- 스킬 버튼 찾아서 제거한다.
		for i = 1, #self.buttonList do
			local button = self.buttonList[i]
			if button.skillIndex == skillIndex then
				-- 찾았다.
				self:removeChild(button.button)
				-- 버튼 리스트는 리스트 내 순서가 없으므로 맨 마지막과 바꾸고 nil로 채운다.
				local lastButtonIndex = #self.buttonList
				if i ~= lastButtonIndex then
					self.buttonList[i] = self.buttonList[lastButtonIndex]
					self.buttonList[lastButtonIndex] = nil
				else
					self.buttonList[i] = nil
				end
				break
			end
		end
	end
	
	self.spText:setText(self.sp)
	
	if self.sp == 0 then
		-- 버튼 상태를 바꾼다.
		self:SetButtonState()
	end
end

-- 창을 닫을 때라던가, 스킬 레벨 업 완료를 누르면
-- 실제 스킬 정보에 반영되어야 하는데
-- 현재는 구현되지 않음. 그냥 창 내에서만 정보가 바뀔 뿐임.
function SkillWindow.create(skills, usable_point)
	local window = SkillWindow.new()
	
	for i = 1, #skills do
		window:AddSkill(skills[i])
	end
	
	-- set usable skill point
	window:SetUsableSkillPoint(usable_point)
	
	return window
end