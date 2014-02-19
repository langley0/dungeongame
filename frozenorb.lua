Magic_FrozenOrb = Core.class(Sprite)

function Magic_FrozenOrb.create()
	local orb =  Magic_FrozenOrb.new()

	orb.name = "프로즌오브"
	orb.delay = 0.3 -- 여긴 대충 쓴값
	orb.cooltime = 0
	orb.distance = 300
	orb.flying_speed = 100
	orb.type = "action"
	
	orb.stamina = 50
	
	-- 아래 내용을 Use에서 플레이어 레벨에 따라 바꿔줄 수 있어야 할 것도 같지만 일단은 이렇게..
	orb.fireCountPerRound = 6 -- 한바퀴 돌 동안 뿌릴 개수
	orb.rotatingTime = 0.5 -- 프로즌오브 한바퀴 회전하는데 걸리는 시간
	orb.finalFireCount = orb.fireCountPerRound * 2 -- 마지막 사라질 때 뿜을 개수
	
	orb.iceboltData = {}
	orb.iceboltData.flying_speed = 300
	orb.iceboltData.distance = 200
	orb.iceboltData.level = 1
	
	return orb
end


-- 무기 공통함수
function Magic_FrozenOrb:CanUse(invoker, world)
	-- 쿨타임만 계산한다
	if self.cooltime  > 0 then 
		return false
	end
	
	if self.stamina > invoker.stamina then
		return false
	end
	
	return true
end

function Magic_FrozenOrb:GetRange()
	return self.distance
end 

function Magic_FrozenOrb:Update(deltaTime)
	self.cooltime  = self.cooltime - deltaTime
end 

function Magic_FrozenOrb:Use(invoker, world)
	--print("여기서 프로즌 오브 발사")
	local x2, y2 = invoker:getPosition()
	
	local target = world:GetClosestEnemyFrom(x2, y2)
	if target == nil then return end 
	
	invoker.stamina = invoker.stamina - self.stamina
	
	-- 프로즌 오브를 발사한다
	local x, y = target:getPosition()
	local dx = x - x2
	local dy = y - y2
	
	local length = math.sqrt(dx*dx + dy*dy)
	
	if length < 0.1 then 
		-- 너무 붙어있다. 적당히 발사하자
		dx = 1
		dy = 0
	else 
		dx = dx / length
		dy = dy / length
	end 
	
	local frozenOrb = FrozenOrb.create(dx, dy, self.flying_speed, self.distance, self.rotatingTime, self.fireCountPerRound, self.finalFireCount, self.iceboltData, world)
	frozenOrb:setPosition(x2, y2)
	world.effect_layer:addChild(frozenOrb)
	
	self.cooltime = self.delay
end 

local frozenOrb_texture = Texture.new("weapon/magicbolt.png")

local frozenOrb_textures = {
	Texture.new("weapon/frozenorb/frozenorb_0.png"),
	Texture.new("weapon/frozenorb/frozenorb_1.png"),
}


FrozenOrb = Core.class(Sprite)
function FrozenOrb.create(x, y, speed, distance, rotatingTime, fireCountPerRound, finalFireCount, iceboltData, world)
	
	local frozenOrb = FrozenOrb.new()
	
	-- 타겟방향으로 날라간다
	frozenOrb.moving = { x = x, y = y, speed = speed, distance = distance }
	frozenOrb.world = world
	
	frozenOrb:addEventListener(Event.ENTER_FRAME, frozenOrb.Update, frozenOrb)
	frozenOrb.flying_distance = 0
	
	-- 내부적으로 아이스볼트 쏠 때 사용할 정보
	frozenOrb.fireCountPerRound = fireCountPerRound
	frozenOrb.fireTime = rotatingTime / frozenOrb.fireCountPerRound	
	frozenOrb.fireAngleDiff = 2 * math.pi / frozenOrb.fireCountPerRound
	frozenOrb.currentFireAngle = 0
	frozenOrb.iceboltData = iceboltData
	
	-- 마지막 쏘는 정보.
	frozenOrb.finalFireCount = finalFireCount
	
	frozenOrb.frames = {}
	for i = 1, #frozenOrb_textures, 1 do
		local frame = Bitmap.new(frozenOrb_textures[i])
		frame:setAnchorPoint(0.5, 0.5)
		frame:setBlendMode(Sprite.ADD)
		frozenOrb.frames[i] = frame
	end
	
	frozenOrb.currentFrame = 1
	frozenOrb.image = frozenOrb.frames[frozenOrb.currentFrame]
	frozenOrb:addChild(frozenOrb.image)
	
	frozenOrb.frameChangeTime = frozenOrb.fireTime / #frozenOrb.frames
	frozenOrb.frameTime = 0
	
	return frozenOrb
	
end

function FrozenOrb:Update(event)
	local x, y = self:getPosition()
	
	local distance = self.moving.speed *event.deltaTime
	
	-- 오브가 날라간다
	local x2 = self.moving.x * distance + x
	local y2 = self.moving.y * distance + y
	
	self:setPosition(x2, y2)
	
	-- 정해진 간격으로 스프라이트를 교체하고, 아이스볼트를 발사한다.
	self.frameTime = self.frameTime + event.deltaTime
	
	self.flying_distance = self.flying_distance + distance
	if self.flying_distance > self.moving.distance then 
		-- 사거리가 넘어가면 
		-- 마지막 시원하게 쏘고
		self:FinalFire()
		-- 사라진다
		self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
		self:getParent():removeChild(self)
	else
		if self.frameTime >= self.frameChangeTime then
			-- 프레임 변경
			self.isFired = false
			self.currentFrame = self.currentFrame + 1
			if self.currentFrame == #self.frames then
				-- 마지막 프레임일 때 쏜다.
				self:Fire()
			elseif self.currentFrame > #self.frames then
				self.currentFrame = 1
				self.frameTime = 0
			end
			self:removeChild(self.image)
			self.image = self.frames[self.currentFrame]
			self:addChild(self.image)
		end
	end
end

function FrozenOrb:Fire()
	
	local direction = self.currentFireAngle

	local x2, y2 = self:getPosition()
	local r = self.image:getWidth() * 0.6
	
	local dx, dy = math.cos(direction), -math.sin(direction)
	
	local icebolt = IceBolt.create(dx, dy, self.iceboltData.flying_speed, self.iceboltData.distance, self.iceboltData.level, self.world)
	icebolt:setPosition(x2 + dy * r, y2 - dx * r)
	self.world.effect_layer:addChild(icebolt)
	
	self.currentFireAngle = self.currentFireAngle + self.fireAngleDiff
	
end

function FrozenOrb:FinalFire()

	local direction = 0
	local fireAngleDiff = 2 * math.pi / self.finalFireCount
	local x2, y2 = self:getPosition()
	local r = self.image:getWidth() * 0.6
	
	for i = 1, self.finalFireCount, 1 do
		local dx, dy = math.cos(direction), -math.sin(direction)
	
		local icebolt = IceBolt.create(dx, dy, self.iceboltData.flying_speed, self.iceboltData.distance, self.iceboltData.level, self.world)
		icebolt:setPosition(x2 + dy * r, y2 - dx * r)
		self.world.effect_layer:addChild(icebolt)
		
		direction = direction + fireAngleDiff
	end

end