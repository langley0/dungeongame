HitDamageText = Core.class(Sprite)


function HitDamageText.create()
	local t = HitDamageText.new()
	t.first = nil
	t.second = nil
	
	t:addEventListener(Event.ENTER_FRAME, t.Update, t)
	return t
end 

function HitDamageText:AddText(damage)
	-- 텍스트가 추가되면 기존 텍스트가 남아있는지 확인하자
	if self.first then 
		
		if self.second then 
			self.second.image:getParent():removeChild(self.second.image)
		end 
		
		self.first.image:getParent():removeChild(self.first.image)
		--[[
		-- first 를 second 로 옮긴다.
		self.second = self.first
		self.second.image:setScale(0.5, 0.5)
		self.second.image:setPosition(-64, -24)
		self.second.image:setTextColor(0xa0a0a0)]]
	end 
	
	-- first 에 추가한다
	local text = CreateText(damage.." DMG")
	text:setTextColor(0xff0000)
	text:setPosition(-64, -24)
	self.first = { time =0, image = text }
	self:addChild(self.first.image)
	
end 


function HitDamageText:Update(event)
	if IsPaused() then return end
	-- 텍스트가 있나?
	if self.first then 
		self.first.image:setScale(1 - self.first.time)
		self.first.image:setAlpha(1 - self.first.time)
		self.first.time = self.first.time + event.deltaTime
		
		if self.first.time > 2 then 
			self.first.image:getParent():removeChild(self.first.image)
			self.first = nil
		end
	end 
	
	if self.second then 
		self.second.image:setScale(2 - self.second.time)
		self.second.time = self.second.time + event.deltaTime
		
		if self.second.time > 2 then 
			self.second.image:getParent():removeChild(self.second.image)
			self.second = nil
		end
	end 
end 