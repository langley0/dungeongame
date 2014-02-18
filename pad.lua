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
	
	
	
	local texture = Texture.new("pad/fire_button.png")
	local fire_off = Bitmap.new(TextureRegion.new(texture, 0, 0, 96,96))
	local fire_on = Bitmap.new(TextureRegion.new(texture, 96, 0, 96,96))
	
	fire_off:setScale(1.5,1.5)
	fire_off:setPosition(1050, 550)
	
	fire_on:setScale(1.5,1.5)
	fire_on:setPosition(1050, 550)
	
	
	
	p.fire_off_image = fire_off
	p.fire_on_image = fire_on
	p.fire_on = nil
	p:addChild(p.fire_off_image)
	
	
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
	end
end

function Pad:SetStick(x, y)
	if self.show then 
		local cx, cy = self.stick_base:getPosition()
		
		-- 방향을 잡고 노멀라이즈 한다
		local dx = x - cx
		local dy = y - cy
		
		local length = math.sqrt(dx*dx + dy*dy)
		if length < 5 then 
			dx = 0
			dy = 0
		else 
			dx = dx / length 
			dy = dy / length
		end 
		
		self.stick:setPosition(dx * 60, dy *60)
		self.dx = dx
		self.dy = dy
		
		return dx, dy
	else 
		return 0, 0
	end 

end 

function Pad:StartFire(id)
	if self.fire_on then 
		-- go on 
	else 
		self:removeChild(self.fire_off_image)
		self:addChild(self.fire_on_image)
		
		self.fire_on = id
	end 
end 

function Pad:StopFire(id)
	if self.fire_on == id then 
		-- go on 
		self:removeChild(self.fire_on_image)
		self:addChild(self.fire_off_image)
		
		self.fire_on = nil
	end 
end 