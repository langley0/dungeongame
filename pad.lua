Pad = Core.class(Sprite)


function Pad.create()

	local p = Pad.new()
	
	p.ring = Bitmap.new(Texture.new("pad/vpad_ring.png"))
	p.ring:setAnchorPoint(0.5, 0.5)
	p.ring:setScale(3, 3)
	
	p.stick = Bitmap.new(Texture.new("pad/vpad_stick.png"))
	p.stick:setAnchorPoint(0.5, 0.5)
	p.stick:setScale(3, 3)

	p.stick_base = Sprite.new()
	p.stick_base:addChild(p.ring)
	p.stick_base:addChild(p.stick)

	p.show = false
	
	p.skills = {}
	
	local skill1 = {}
	local skill2 = {}
	
	p.skills[1] = skill1
	p.skills[2] = skill2
	
	local texture = Texture.new("pad/fire_button.png")
	do 
		local fire_off = Bitmap.new(TextureRegion.new(texture, 0, 0, 96,96))
		local fire_on = Bitmap.new(TextureRegion.new(texture, 96, 0, 96,96))
		
		fire_off:setAnchorPoint(0.5,0.5)
		fire_off:setScale(1.5,1.5)
		fire_off:setPosition(850, 550)
		
		fire_on:setAnchorPoint(0.5,0.5)
		fire_on:setScale(1.5,1.5)
		fire_on:setPosition(850, 550)
		
		skill1.fire_off_image = fire_off
		skill1.fire_on_image = fire_on
		skill1.fire_on = nil
	end 

	do 
		local fire_off = Bitmap.new(TextureRegion.new(texture, 0, 0, 96,96))
		local fire_on = Bitmap.new(TextureRegion.new(texture, 96, 0, 96,96))
		
		fire_off:setAnchorPoint(0.5,0.5)
		fire_off:setScale(1.5,1.5)
		fire_off:setPosition(1050, 550)
		
		fire_on:setAnchorPoint(0.5,0.5)
		fire_on:setScale(1.5,1.5)
		fire_on:setPosition(1050, 550)
		
		skill2.fire_off_image = fire_off
		skill2.fire_on_image = fire_on
		skill2.fire_on = nil
	end
	
	
	p:addChild(skill1.fire_off_image)
	p:addChild(skill2.fire_off_image)
	
	p:addEventListener(Event.ENTER_FRAME,p.Update, p)
	
	
	return p
end


function Pad:ShowStick(x, y)

	if self.show == false then 
		
		self.stick_base:setPosition(x, y)
		self:addChild(self.stick_base)
		self.show = true
		
		-- 중앙에 맞춘다
		self.stick:setPosition(0, 0)
	end
end

function Pad:Hide()
	if self.show then 
		self:removeChild(self.stick_base)
		self.show = false
		self.dx = nil
		self.dy = nil
		self.lastevent = nil
	end
end

function Pad:SetStick(x, y)
	if self.show then 
		local cx, cy = self.stick_base:getPosition()
		
		self.lastevent = { x = x, y = y }
		
		-- 방향을 잡고 노멀라이즈 한다
		local dx = x - cx
		local dy = y - cy
		
		local length = math.sqrt(dx*dx + dy*dy)
		if length < 1 then 
			dx = 0
			dy = 0
		else 
			dx = dx / length 
			dy = dy / length
		end 
		
		length = math.min(length, 60)
		
		self.stick:setPosition(dx * length, dy *length)
		dx = dx * length / 60
		dy = dy * length / 60
		self.dx = dx
		self.dy = dy
		
		return dx, dy
	else 
		return 0, 0
	end 

end 

function Pad:OnTouchBegin(event, player, world)
	
	for i = 1, #self.skills do
		local skill = self.skills[i]
		if skill.fire_off_image:hitTestPoint(event.touch.x, event.touch.y) then 
		
			if skill.skill.type == "charge" then
				skill.touchid = event.touch.id
				skill.skill:Activate()
				
				self:removeChild(skill.fire_off_image)
				self:addChild(skill.fire_on_image)
			elseif skill.skill.type == "action" then
				skill.touchid = event.touch.id
				if skill.skill:CanUse(player, world) then 
					skill.skill:Use(player, world)
				end
				
				self:removeChild(skill.fire_off_image)
				self:addChild(skill.fire_on_image)
			end 
			
			return true
		end 
	end 
	
	return false
	
end 

function Pad:OnTouchEnd(event)

	for i = 1, #self.skills do
		local skill =self.skills[i]
		if skill.touchid == event.touch.id then 
			if skill.skill.activate then 
				skill.skill:Deactivate()
			end 
			
			self:removeChild(skill.fire_on_image)
			self:addChild(skill.fire_off_image)
			
			skill.touchid = nil
		end 
	end 
end 

function Pad:AssignSkill(index, skill)

	local _skill = self.skills[index]
	_skill.skill = skill
	if skill.type == "autopassive" then 
		-- 패시브 상태로 만든다
		local auto_text = CreateSmallText("AUTO")
		auto_text:setPosition(-auto_text:getWidth() / 2, 70)
		auto_text:setTextColor(0xffffff)
		
		
		self:removeChild(_skill.fire_off_image)
		self:addChild(_skill.fire_on_image)
		
		_skill.fire_on_image:addChild(auto_text)
	end 
	
	local name_text = CreateSmallText(skill.name)
	name_text:setPosition(-name_text:getWidth() / 2, 0)
	name_text:setTextColor(0xffffff)
	
	local name_text2 = CreateSmallText(skill.name)
	name_text2:setPosition(-name_text2:getWidth() / 2, 0)
	name_text2:setTextColor(0xffffff)
	
	_skill.fire_on_image:addChild(name_text)
	_skill.fire_off_image:addChild(name_text2)
end 

function Pad:Update(event)
	
	-- 패드의 중심을 현재 터치한곳으로 조금씩 이동시킨다
	if self.lastevent then 
		-- 현재 중심에서 마지막터치한 곳으로의 이동값
		local x, y = self.stick_base:getPosition()
		local dx = self.lastevent.x - x 
		local dy = self.lastevent.y - y
		
		local length = math.sqrt(dx*dx + dy*dy)
		if length > 60 then 
			-- 이동을 한다
			x = x + event.deltaTime * dx / length * 128
			y = y + event.deltaTime * dy / length * 128
			
			self.stick_base:setPosition(x, y)
		end
	end 

end