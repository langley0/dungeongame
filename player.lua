-- 레벨 6까지밖에 못만들었다..
LevelTable = {}
LevelTable[1] = 10
LevelTable[2] = 25
LevelTable[3] = 45
LevelTable[4] = 70
LevelTable[5] = 100
LevelTable[6] = 99999999 


SPRITE_SCALE = 3
Player = Core.class(Sprite)

local function init_warrior(self)

	self.name = "WARRIOR"
	self.level = 1
	self.exp = 0
	
	self.hp_max = 100
	self.hp = self.hp_max
	self.str =1 
	self.int = 1
	self.def = 1
	self.dex = 1
	
	self.recharge = 0
	self.c_speed = 100
	
	self.weapon = Sword.create(self)
	
	local p_texture = Texture.new("player/warrior.png")
	local bitmaps = {
		Bitmap.new(TextureRegion.new(p_texture, 0,0,16,16)),
		Bitmap.new(TextureRegion.new(p_texture, 16,0,16,16)) }
		
	for i = 1, #bitmaps do 
		bitmaps[i]:setAnchorPoint(0.5, 0.5)
		bitmaps[i]:setScale(SPRITE_SCALE,SPRITE_SCALE)
	end
	local movie = MovieClip.new({
		{ 1, 4, bitmaps[1] },
		{ 5, 8, bitmaps[2] }
	})
	
	movie:setGotoAction(8,1)
	
	self:addChild(movie)
	self.movie = movie
	self.movie:stop()
	self.stopped = true
	
	
end 

local function init_archer(self)

	self.name = "ARCHER"
	self.level = 1
	self.exp = 0
	
	self.hp_max = 100
	self.hp = self.hp_max
	
	self.stamina_max = 100
	self.stamina = self.stamina_max
	self.stamina_recovery = 10
	self.last_stamina_used = 0
	
	self.str =1 
	self.int = 1
	self.def = 1
	self.dex = 1
	
	self.recharge = 0
	self.c_speed = 100
	
	-- 스킬 설정 
	self.skill_A = Bow_BasicAttack.create()
	self.skill_B = Bow_Multishot.create()
	
	self.skills = {}
	self.skills[1] = self.skill_A
	self.skills[2] = self.skill_B
	
	-- 텍스쳐 설정
	local p_texture = Texture.new("player/archer.png")
	local bitmaps = {
		Bitmap.new(TextureRegion.new(p_texture, 0,0,16,16)),
		Bitmap.new(TextureRegion.new(p_texture, 16,0,16,16)) }
		
	for i = 1, #bitmaps do 
		bitmaps[i]:setAnchorPoint(0.5, 0.5)
		bitmaps[i]:setScale(SPRITE_SCALE,SPRITE_SCALE)
	end
	local movie = MovieClip.new({
		{ 1, 4, bitmaps[1] },
		{ 5, 8, bitmaps[2] }
	})
	
	movie:setGotoAction(8,1)
	
	self:addChild(movie)
	self.movie = movie
	self.movie:stop()
	self.stopped = true
	
end 

local function init_wizard(self)
	
	self.name = "WIZARD"
	self.level = 1
	self.exp = 0
	
	self.hp_max = 100
	self.hp = self.hp_max
	
	self.stamina_max = 100
	self.stamina = self.stamina_max
	self.stamina_recovery = 30
	self.last_stamina_used = 0
	
	
	self.str =1 
	self.int = 1
	self.def = 1
	self.dex = 1
	
	self.recharge = 0
	self.c_speed = 100
	
	-- 스킬 설정 
	self.skill_A = Magic_IceBolt.create()
	self.skill_B = Magic_FrozenOrb.create()
	
	self.skills = {}
	self.skills[1] = self.skill_A
	self.skills[2] = self.skill_B

	---
	local p_texture = Texture.new("player/wizard.png")
	local bitmaps = {
		Bitmap.new(TextureRegion.new(p_texture, 0,0,16,16)),
		Bitmap.new(TextureRegion.new(p_texture, 16,0,16,16)) }
		
	for i = 1, #bitmaps do 
		bitmaps[i]:setAnchorPoint(0.5, 0.5)
		bitmaps[i]:setScale(SPRITE_SCALE,SPRITE_SCALE)
	end
	local movie = MovieClip.new({
		{ 1, 4, bitmaps[1] },
		{ 5, 8, bitmaps[2] }
	})
	
	movie:setGotoAction(8,1)
	
	self:addChild(movie)
	self.movie = movie
	self.movie:stop()
	self.stopped = true
	
end 

local function init_spaceman(self)
	
	self.name = "SPACEMAN"
	self.level = 1
	self.exp = 0
	
	self.hp_max = 100
	self.hp = self.hp_max
	
	self.stamina_max = 100
	self.stamina = self.stamina_max
	self.stamina_recovery = 10
	self.last_stamina_used = 0
	
	
	self.str =1 
	self.int = 1
	self.def = 1
	self.dex = 1
	
	self.recharge = 0
	self.c_speed = 100
	
	-- 스킬 설정 
	self.skill_A = Science_EnergyBall.create()
	self.skill_B = Science_LaserBeam.create()
	
	self.skills = {}
	self.skills[1] = self.skill_A
	self.skills[2] = self.skill_B

	---
	local p_texture = Texture.new("player/spaceman.png")
	local bitmaps = {
		Bitmap.new(TextureRegion.new(p_texture, 0,0,16,16)),
		Bitmap.new(TextureRegion.new(p_texture, 16,0,16,16)) }
		
	for i = 1, #bitmaps do 
		bitmaps[i]:setAnchorPoint(0.5, 0.5)
		bitmaps[i]:setScale(SPRITE_SCALE,SPRITE_SCALE)
	end
	local movie = MovieClip.new({
		{ 1, 4, bitmaps[1] },
		{ 5, 8, bitmaps[2] }
	})
	
	movie:setGotoAction(8,1)
	
	self:addChild(movie)
	self.movie = movie
	self.movie:stop()
	self.stopped = true

	--
	self.friends = {}
	self.AddFriend = function(self, newFriend)
		-- 상호 연결
		local index = #self.friends + 1
		self.friends[index] = newFriend
		
		local midAngle = math.pi * 0.5
		local angle = math.pi / 6 * math.ceil(index * 0.5)
		if index % 2 == 1 then
			angle = midAngle - angle
		else
			angle = midAngle + angle
		end
		local distance = 60
		local dx, dy = distance * math.cos(angle), distance * math.sin(angle)
		
		newFriend:AddLinkToPlayer(self, dx, dy)
		newFriend:SetNearnessToPlayer(false)
	end
		
	self.GetFriends = function(self)
		return self.friends
	end
	
	self.LevelUpProcedure = function(self)
		local newFriend = SpaceFriend.create()
		self:AddFriend(newFriend)
		self.world:EnterFriend(newFriend)
	end
end 

function Player.create(type)

	local p = Player.new()
	
	if type == "warrior" then 
		init_warrior(p)
	elseif type == "archer" then 
		init_archer(p)
	elseif type == "wizard" then 
		init_wizard(p)
	elseif type == "spaceman" then 
		init_spaceman(p)
	end 
		
	-- 플레이어용 라이트 리스트를 추가한다
	p.light = Bitmap.new(Texture.new("player/player_light.png"))
	p.light:setAnchorPoint(0.5,0.5)
	p.light:setScale(6,6)
	
	p.attack_delay = 0
	p.speed = 400
	
	-- 방향 표시기
	local d_bitmap = Bitmap.new(Texture.new("player/direction.png"))
	d_bitmap:setAnchorPoint(0.5,0.5)
	d_bitmap:setAlpha(0.5)
	
	p.direction = { x = 1, y = 0, rad = 0, image =  d_bitmap}
	p.lockon = nil
	
	
	do 
		local lockon_texture = Texture.new("player/lockon.png")
		p.lockon = Sprite.new()
		p.lockon.lockon_red = Bitmap.new(TextureRegion.new(lockon_texture, 0, 0, 16,32))
		p.lockon.lockon_red:setAnchorPoint(0.5,0.75)
		p.lockon.lockon_red:setScale(3,3)
		
		p.lockon.lockon_green = Bitmap.new(TextureRegion.new(lockon_texture, 16, 0, 16,32))
		p.lockon.lockon_green:setAnchorPoint(0.5,0.75)
		p.lockon.lockon_green:setScale(3,3)
		
		p.lockon:addChild(p.lockon.lockon_red)
	end 
	return p
end 

function Player:Warp(x, y)
	-- 타일 x,y 로 워프시킨다
	if self.world.map:IsMovableCell(x, y, true) then 
		self:Stop(true) -- 강제 정지시킨다
		local to_x, to_y = self.world.map:GetTileCenterPosition(x, y)
		
		self:setPosition(to_x, to_y)
		self.light:setPosition(to_x, to_y)
		self.world:LocateCenter(to_x, to_y)
		self.lockon:setPosition(to_x, to_y)
	end 
end 

function Player:Move2(x, y)
	if x == 0 and y == 0 then 
		self:Stop()
	else 
		self.moving2 = { dx = x, dy = y }
		
		if self.stopped then 
			self.movie:play()
			self.stopped = false
		end 
	end 
	
end 

function Player:Stop()
	self.moving2 = nil
	
	self.movie:gotoAndStop(1)
	self.stopped = true

end 

function Player:Update(event)
	if IsPaused() then return end
	if self.dead then return end
	
	
	local world = self.world
	local x, y = self:getPosition()
	
	-- 이동을 한다
	if self.moving2 then 
		-- 이번에 이동할 거리를 구한다
		local length = event.deltaTime * self.speed
		
		x = length * self.moving2.dx + x
		y = length * self.moving2.dy + y
		
		-- 캐릭터를 중심으로 화면을 위치시킨다
		world:LocateCenter(x, y)
		self:setPosition(x, y)
		-- 라이트 위치를 업데이트
		self.light:setPosition(x, y)
	end 
	
	-- 방향업데이트
	if self.direction then 
		if self.moving2 then 
			self.direction.x = self.moving2.dx
			self.direction.y = self.moving2.dy
			self.direction.rad = math.atan2(self.direction.y, self.direction.x)
		end 
	end 
	
	-- 타겟을 검색한다
	local enemy = world:GetClosestEnemyFrom(x, y)
	local lockon_x, lockon_y
	if enemy then 
		lockon_x, lockon_y = enemy:getPosition()
	else 
		-- 캐릭터의 이동방향 앞쪽 48*5 를 목표로 한다. 나중에 사거리로 변경
		lockon_x = self.direction.x * 48*5  + x
		lockon_y = self.direction.y * 48*5  + y
	end 
	-- 락온을 타겟으로 이동시킨다
	local lockon_x2, lockon_y2 = self.lockon:getPosition()
	local lockon_dx = lockon_x - lockon_x2
	local lockon_dy = lockon_y - lockon_y2
	local l_len = math.sqrt(lockon_dx*lockon_dx + lockon_dy*lockon_dy)
	if l_len > 1 then
		lockon_dx = lockon_dx / l_len
		lockon_dy = lockon_dy / l_len
		local _dist = math.min(l_len, self.speed*2*event.deltaTime)
		self.lockon:setPosition(lockon_x2 + lockon_dx* _dist , lockon_y2 + lockon_dy* _dist )
	end 
	
	if enemy and l_len <= 24 then 
		if self.lockon.lockon_green:getParent() ~= self.lockon then 
			self.lockon:removeChild(self.lockon.lockon_red)
			self.lockon:addChild(self.lockon.lockon_green)
		end 
	else 
		if self.lockon.lockon_red:getParent() ~= self.lockon then 
			self.lockon:removeChild(self.lockon.lockon_green)
			self.lockon:addChild(self.lockon.lockon_red)
		end 
	end 
	
	-- 스킬사용을 확인한다
	local charge_skill_used
	for i = 1, #self.skills do 
		local skill = self.skills[i]
		if skill.activate then 
			-- 차지스킬이다!
			if skill:CanUse(self, world) then 
				skill:Use(self, world)
				-- 차지 스킬은 두개를 동시에 쓸일이 있나?
				charge_skill_used = true
				-- 스태미너 처리
				self.stamina = self.stamina - skill.stamina
				self.last_stamina_used = event.time
	
				break
			end 
		end 
	end 
	
	if charge_skill_used then 
		-- 
	else
		-- 기본 오토 패시브 스킬을 사용한다
		for i = 1, #self.skills do 
			local skill = self.skills[i]
			if skill.type == "autopassive" then 
				-- 오토 스킬사용
				if skill:CanUse(self, world) then 
					skill:Use(self, world)
				end 
			end
		end
	end 
	
	for i = 1, #self.skills do 
		local skill = self.skills[i]
		skill:Update(event.deltaTime)
	end
	
	-- 스태미너 회복
	if self.stamina < self.stamina_max and 
		self.last_stamina_used + 2 <=  event.time then 
		-- 스태미너 회복을 시작한다
		self.stamina = math.min(self.stamina_max, self.stamina + self.stamina_recovery * event.deltaTime)
	end 
end 


function Player:AddExp(exp)
	
	self.exp = self.exp + exp
	local max = LevelTable[self.level]
	
	while self.exp >= max  do
		self.exp = self.exp - max
		self.level = self.level + 1
		
		-- 레벨업!!! 화려한 이펙트를 보여준다
		local effect = TimeEffect.create(lvup_texture, 3, Sprite.ADD)
		self:addChild(effect) -- 알아서 파괴된다
		
		if self.LevelUpProcedure then
			self:LevelUpProcedure()
		end
		
		max = LevelTable[self.level]
	end 
	
end 



function Player:OnHit(damage)
	
	-- 공격을 당했다.
	self.hp = self.hp - damage
	if self.hp <= 0 then 
		self.hp = 0
		-- 사망 
		self:Stop()
		self.dead = true
		
	else 
		if self.hiteffect then 
			if self.hiteffect.finished then 
				-- 아무것도 안한다
			else 
				-- 이펙트를 강제로 종료시킨다
				self.hiteffect:Finish()
			end 
		end 
		
		self.hiteffect = TimeEffect.create(player_hit_texture, 0.5, Sprite.MULTIPLY)
		self.hiteffect:setScale(3, 3)
		self:addChild(self.hiteffect)
	end
end 