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
	self.str =1 
	self.int = 1
	self.def = 1
	self.dex = 1
	
	self.recharge = 0
	self.c_speed = 100
	
	self.weapon = Bow.create(self)
	
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
	self.str =1 
	self.int = 1
	self.def = 1
	self.dex = 1
	
	self.recharge = 0
	self.c_speed = 100
	
	self.weapon = Staff.create(self)
	
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

function Player.create(type)

	local p = Player.new()
	
	if type == "warrior" then 
		init_warrior(p)
	elseif type == "archer" then 
		init_archer(p)
	elseif type == "wizard" then 
		init_wizard(p)
	end 
		
	-- 플레이어용 라이트 리스트를 추가한다
	p.light = Bitmap.new(Texture.new("player/player_light.png"))
	p.light:setAnchorPoint(0.5,0.5)
	p.light:setScale(6,6)
	
	p.attack_delay = 0
	p.speed = 400
	
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

	if  self.weapon:CanFire() then 
		
		-- 가장 가까운 적을 찾는다
		local enemy = world:GetClosestEnemyFrom(x, y)
		if enemy then 
			
			local ex, ey = enemy:getPosition()
			local _dx = ex - x
			local _dy = ey - y
		
			-- 무기 사거리 안에 있는가?
			local distance = math.sqrt(_dx*_dx + _dy*_dy)
			if distance < self.weapon:GetRange() then 
				self.weapon:Fire(self, enemy, world)
			end 
		end 
	end 
	
	self.weapon:Update(event.deltaTime)
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
		
		
		max = LevelTable[self.level]
	end 
	
end 

function Player:OnHit(damage)
	
	-- 공격을 당했다.
	self.hp = self.hp - damage
	if self.hp <= 0 then 
		self.hp = 0
		-- 미션 실패이다.
		-- ?? 어떻게 할지는 미정
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