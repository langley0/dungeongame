Science_LaserBeam = Core.class(Sprite)

function Science_LaserBeam.create()
	local laserbeam =  Science_LaserBeam.new()

	laserbeam.name = "레이저빔"
	laserbeam.delay = 1.0
	laserbeam.cooltime = 0
	laserbeam.distance = 300
	laserbeam.flying_speed = 50
	laserbeam.type = "charge"
	
	laserbeam.activate = false
	laserbeam.stamina = 10
	
	return laserbeam
end

function Science_LaserBeam:Activate()
	self.activate = true
	self.direction = nil
	self.currentLaserbeam = nil
end

function Science_LaserBeam:Deactivate()
	self.activate = false
	self.direction = nil
	self.currentLaserbeam = nil
end

function Science_LaserBeam:CanUse(invoker, world)
	if self.cooltime  > 0 then 
		return false
	end 
	
	if invoker.stamina < self.stamina then
		return false
	end
	
	local x, y = invoker:getPosition()
	local target = world:GetClosestEnemyFrom(x, y)
	if target == nil then 
		return false
	end
	
	return true
end


function Science_LaserBeam:Update(deltaTime)
	self.cooltime  = self.cooltime - deltaTime
end 


-- 무기 공통함수
function Science_LaserBeam:Use(invoker, world)
	-- 현재 빔이 있고, 최대 길이가 아직 안되었다면
	if self.currentLaserbeam and self.currentLaserbeam:IsAvailable() then
		self.currentLaserbeam:ResetDisappearCooltime()
	else
		local x2, y2 = invoker:getPosition()
		local target = world:GetClosestEnemyFrom(x2, y2)
		if target == nil then return end
		
		local x, y = target:getPosition()
		local dx = x - x2
		local dy = y - y2
		
		local length = math.sqrt(dx*dx + dy*dy)
	
		if length < 0.1 then 
			-- 너무 붙어있다. 
			dx = 1
			dy = 0
		else
			dx = dx / length
			dy = dy / length
		end
		
		self.currentLaserbeam = LaserBeam.create(dx, dy, 1, self.flying_speed, self.distance, self.delay + 0.05, invoker, world)
		self.currentLaserbeam:setPosition(x2, y2)
		world.effect_layer:addChild(self.currentLaserbeam)
	end
	
	self.cooltime = self.delay
end 

local laserbeam_textures = {
	top = Texture.new("weapon/laserbeam/laserbeam_top.png"), -- height = 12 px
	mid = Texture.new("weapon/laserbeam/laserbeam_mid.png"), -- height = 24 px
	bot = Texture.new("weapon/laserbeam/laserbeam_bot.png"), -- height = 12 px
}

LaserBeam = Core.class(Sprite)

function LaserBeam.create(dx, dy, widthScale, speed, distance, disappearTime, invoker, world)
	local laserbeam = LaserBeam.new()
	
	laserbeam.moving = { x = dx, y = dy, speed = speed, distance = distance }
	laserbeam.world = world
	
	laserbeam.maxLength = distance
	laserbeam.disappearTime = disappearTime
	laserbeam.currentTime = 0
	laserbeam.disappeared = false
	laserbeam.length = 0
	laserbeam:setScaleX(widthScale)
	
	laserbeam.topSprite = Bitmap.new(laserbeam_textures.top)
	laserbeam.midSprite = Bitmap.new(laserbeam_textures.mid)
	laserbeam.midHeight = laserbeam_textures.mid:getHeight()
	laserbeam.botSprite = Bitmap.new(laserbeam_textures.bot)
	laserbeam:addChild(laserbeam.topSprite)
	laserbeam:addChild(laserbeam.midSprite)
	laserbeam:addChild(laserbeam.botSprite)
	
	laserbeam.topSprite:setAnchorPoint(0.5, 1)
	laserbeam.midSprite:setAnchorPoint(0.5, 1)
	laserbeam.midSprite:setScaleY(0)
	laserbeam.botSprite:setAnchorPoint(0.5, 0)
	
	laserbeam:addEventListener(Event.ENTER_FRAME, laserbeam.Update, laserbeam)
	
	--laserbeam.angleInRad = math.atan2(-dy, -dx) - math.pi * 0.5
	--local angleInDeg = math.deg(laserbeam.angleInRad)
	local angleInDeg = math.deg(math.atan2(-dy, -dx)) - 90
	laserbeam:setRotation(angleInDeg)
	laserbeam:setBlendMode(Sprite.ADD)
	
	laserbeam.invoker = invoker
	laserbeam.world = world
	laserbeam.damage = 2 + invoker.level
	
	return laserbeam
end

function LaserBeam:setPosition(x, y)
	Sprite.setPosition(self, x + 18, y + 1)
end

function LaserBeam:Update(event)
	self.currentTime = self.currentTime + event.deltaTime
	
	if self:IsAvailable() then
		-- 플레이어 따라서 이동
		local x2, y2 = self.invoker:getPosition()
		self:setPosition(x2, y2)
		
		-- 공격 -- 캡슐 모양임.
		local capsuleRange = {}
		capsuleRange.height = self.length
		capsuleRange.pointA = Vector2.new(x2, y2)
		capsuleRange.pointB = Vector2.new(x2 + self.length * self.moving.x, y2 + self.length * self.moving.y)
		capsuleRange.radius = 12
		
		self.world:HitCapsuleRange(capsuleRange, self.damage)
		
		-- 사라질 건지 계속 늘어날 건지 결정
		if self.disappearTime <= self.currentTime then
			self:SetDisappear()
		elseif self:CanAddLength() then
			local distance = self.moving.speed * event.deltaTime
			self:AddLength(distance)
		end
	else
		-- 사라지는 중입니다.
		if self.disappearState == 0 and self.currentTime > 0.2 then
			self:setScaleX(self:getScaleX() * 0.5)
		elseif self.disappearState == 1 and self.currentTime > 0.4 then
			self:setScaleX(self:getScaleX() * 0.5)
		elseif self.disappearState == 2 and self.currentTime > 6.0 then
			-- 사라진다.
			self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
			self:getParent():removeChild(self)
		end
	end
end

function LaserBeam:SetDisappear()
	self.disappeared = true
	self.currentTime = 0
	self.disappearState = 0
end

function LaserBeam:CanAddLength()
	return self.length < self.maxLength
end

function LaserBeam:IsAvailable()
	return not self.disappeared
end

function LaserBeam:ResetDisappearCooltime()
	self.currentTime = 0
end

function LaserBeam:AddLength(length)
	self.length = math.min(self.length + length, self.maxLength)
	local scale = self.length / self.midHeight
	
	self.topSprite:setPosition(0, -self.length)
	self.midSprite:setScaleY(scale)
end

