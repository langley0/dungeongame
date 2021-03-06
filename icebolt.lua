Magic_IceBolt = Core.class(Sprite)

function Magic_IceBolt.create()
	local icebolt =  Magic_IceBolt.new()

	icebolt.name = "아이스볼트"
	icebolt.delay = 1.0
	icebolt.cooltime = 0
	icebolt.distance = 500
	icebolt.flying_speed = 350
	icebolt.type = "autopassive"
	
	return icebolt
end


-- 무기 공통함수
function Magic_IceBolt:CanUse(invoker, world)
	-- 쿨타임만 계산한다
	if self.cooltime  > 0 then 
		return false
	end 
	
	return true
end

function Magic_IceBolt:GetRange()
	return self.distance
end 

function Magic_IceBolt:Update(deltaTime)
	self.cooltime  = self.cooltime - deltaTime
end 


-- 무기 공통함수
function Magic_IceBolt:Use(invoker, world)
	
	local x2, y2 = invoker:getPosition()
	
	local target = world:GetClosestEnemyFrom(x2, y2)
	if target == nil then return end 
	
	-- 아이스볼트를 발사한다
	local x, y = target:getPosition()
	local dx = x - x2
	local dy = y - y2
	
	local length = math.sqrt(dx*dx + dy*dy)
	
	if length < 0.1 then 
		-- 너무 붙어있다. 화살을 적당히 발사하자
		dx = 1
		dy = 0
	else 
		dx = dx / length
		dy = dy / length
	end 
	
	-- 스피드를 곱해서 적당히 발사하자
	local icebolt = IceBolt.create(dx, dy, self.flying_speed, self.distance, invoker.level, world, 0.8 + invoker.level*0.3 )
	icebolt:setPosition(x2, y2)
	world.effect_layer:addChild(icebolt)
	
	self.cooltime = self.delay
end 

local icebolt_texture = Texture.new("weapon/icebolt.png")


IceBolt = Core.class(Sprite)
function IceBolt.create(x, y, speed, distance, level, world, size_scale)

	local icebolt = IceBolt.new()
	
	icebolt.image = Bitmap.new(icebolt_texture)
	icebolt.image:setAnchorPoint(0.5, 0.5)
	icebolt.image:setScale(size_scale, size_scale)
	icebolt.image:setRotation(math.deg(math.atan2(y, x)))
	icebolt.image:setBlendMode(Sprite.ADD)
	icebolt:addChild(icebolt.image)
	
	-- 타겟방향으로 날라간다
	icebolt.moving = { x = x, y = y, speed = speed, distance = distance }
	icebolt.world = world
	icebolt.damage = 6 + level * 2
	
	icebolt:addEventListener(Event.ENTER_FRAME, icebolt.Update, icebolt)
	icebolt.flying_distance = 0
	
	-- 영향 범위
	icebolt.hitRadius = level * 1.5 -- 일단은 이렇게...
	icebolt.explosionSize = level * 1.5
	
	return icebolt

end

function IceBolt:Update(event)
	if IsPaused() then return end
	local x, y = self:getPosition()
	
	local distance = self.moving.speed *event.deltaTime
	
	-- 화살이 날라간다
	local x2 = self.moving.x * distance + x
	local y2 = self.moving.y * distance + y
	
	
	self:setPosition(x2, y2)
	
	-- 적과 충돌했는지 확인
	local world = self.world
	local enemy = world:GetEnemyOnPosition(x2, y2)
	
	if enemy then 
	
		world:HitRange(x2, y2, self.hitRadius, self.damage)
		
		-- 폭! 발! 효과 만들고
		self:makeHitExplosion()
		
		-- 사라진다
		self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
		self:getParent():removeChild(self)
		
	else 
		self.flying_distance = self.flying_distance + distance
		if self.flying_distance > self.moving.distance then 
			-- 사거리가 넘어가면 사라진다
			self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
			self:getParent():removeChild(self)
		end 
	end 
	
end 

function IceBolt:makeHitExplosion()
	local x, y = self:getPosition()
	local explosionSprite = ExplosionSprite.new(self.explosionSize)
	explosionSprite:setPosition(x, y)
	self:getParent():addChild(explosionSprite)
end

local icebolt_hit_explosion_textures = {
	Texture.new("weapon/icebolt_hit_explosion/icebolt_hit_0.png"),
	Texture.new("weapon/icebolt_hit_explosion/icebolt_hit_1.png"),
	Texture.new("weapon/icebolt_hit_explosion/icebolt_hit_2.png"),
}

ExplosionSprite = Core.class(Sprite)
function ExplosionSprite:init(scale)
	
	self.frames = {}
	for i = 1, #icebolt_hit_explosion_textures, 1 do
		local frame = Bitmap.new(icebolt_hit_explosion_textures[i])
		frame:setAnchorPoint(0.5, 0.85)
		frame:setScale(scale, scale)
		frame:setBlendMode(Sprite.ADD)
		self.frames[i] = frame
	end
	
	self.currentFrame = 1
	self.endFrame = #self.frames
	
	self.curentSubFrame = 0
	self.endSubFrame = 5
	
	self:addEventListener(Event.ENTER_FRAME, self.update, self)
	self:addChild(self.frames[self.currentFrame])
	
end

function ExplosionSprite:update()
	self.curentSubFrame = self.curentSubFrame + 1
	if self.curentSubFrame == self.endSubFrame then
		self:removeChild(self.frames[self.currentFrame])
		self.currentFrame = self.currentFrame + 1
		self.curentSubFrame = 0
		
		if self.currentFrame > self.endFrame then
			self:selfDestroy()
		else
			self:addChild(self.frames[self.currentFrame])
		end
	end
end

function ExplosionSprite:selfDestroy()
	self:removeEventListener(Event.ENTER_FRAME, self.update, self)
	self:removeFromParent()
	--self:removeChild(self.frames[self.currentFrame])
	--self.frames = nil
end

