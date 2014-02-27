Boss = Core.class(Sprite)

local e_t = Texture.new("enemy/enemy02.png")

function Boss.create(world, type)

	-- 네방향 플레이어 이미지를 만든다
	local down_bitmaps = {
		Bitmap.new(TextureRegion.new(e_t, 0,0,16,16)),
		Bitmap.new(TextureRegion.new(e_t, 16,0,16,16)) }
		
	for i = 1, #down_bitmaps do 
		down_bitmaps[i]:setAnchorPoint(0.5, 0.5)
		down_bitmaps[i]:setScale(SPRITE_SCALE * 3,SPRITE_SCALE * 3)
	end
	local down_movie = MovieClip.new({
		{ 1, 4, down_bitmaps[1] },
		{ 5, 8, down_bitmaps[2] }
	})
	down_movie:setGotoAction(8,1)
	
	
	local e = Boss.new()
	
	e.down_movie = down_movie
	e.up_movie = down_movie
	e.right_movie = down_movie
	e.left_movie = down_movie
	
	e:addChild(down_movie)
	e.current_movie = down_movie
	e.stopped = true
	e.current_movie:stop()
	
	
	e.damage_text = HitDamageText.create()
	e.damage_text:setPosition(24, -60)
	e:addChild(e.damage_text)
	
	if type == 99 then 
		e.hp = 2500
		e.hpmax = 2500
		e.speed = 300
		e.exp = 99
		e.attack_delay = 3
	end
		
	e.world = world
	e.attack_sqrt = 64*64*1.5
	e.attack_cooltime = 0
	
	e:addEventListener(Event.ENTER_FRAME, e.Update, e)
	
	
	
	return e

end 

function Boss:Die()
	
	if self.destroyed then return end
	
	self.destroyed = true
	
	local x, y = self:getPosition()
	local tx, ty = self.world.map:GetTileIndexOnPosition(x, y)
	
	-- 시체로 만든다
	self:getParent():removeChild(self)
	self:removeChild(self.current_movie)
	local bmp = Bitmap.new(TextureRegion.new(e_t, 32,0,16,16))
	bmp:setAnchorPoint(0.5,0.5)
	bmp:setScale(SPRITE_SCALE,SPRITE_SCALE)
	self:addChild(bmp)
	self.world.corpse_layer:addChild(self)
	
	
	-- 차지하고 있는 좌표를 지운다
	self.world.map:SetMovementGrid(nil, self.movementtile.x, self.movementtile.y)
	self.movementtile = nil
	
	

end 

-- 몬스터들은 플레이어를 타겟한다
function Boss:TargetPlayer(player)
	local vx = 0
	local vy = 0
	local me = self
	
	-- 활성화 되어 있나?
	me.awake =true
	if me.awake then 
		
		local player_x, player_y = player:getPosition()
		local me_x, me_y = me:getPosition()
		
		-- 자신과 플레이어와의 거리를 계산한다
		local dx = player_x - me_x
		local dy = player_y - me_y
		
		local distance_sqrt = dx*dx + dy*dy 
		local distance = math.sqrt(distance_sqrt)
	
		-- 플레이어가 자신의 인식거리 안에 있나?
		-- 필드로 구분
		
		--if distance_sqrt < 64*64*6*6 then 
			-- 공격가능 거리안이면 더이상 움직이지 않는다
			if distance_sqrt < me.attack_sqrt then 
				-- 움직이지 않는다
			else
				-- 방향으로 움직인다
				vx = dx
				vy = dy
			end 
		--end 
	end 
	-- 인식되지 않았으면 움직이지 않는다
	return vx, vy
end 

function Boss:MoveToPlayer(player)
	
	local me = self
	local world = self.world
	
	local vx, vy = self:TargetPlayer(player)

	if math.abs(vx) > math.abs(vy * 2) then 
		vy = 0
	end 
	
	if math.abs(vy) > math.abs(vx * 2) then 
		vx = 0
	end 
	
	local dx, dy
	
	if vx > 0 then 
		dx = 1
	elseif vx < 0 then 
		dx = -1
	else 
		dx = 0
	end 
	
	if vy > 0 then 
		dy = 1
	elseif vy < 0 then 
		dy = -1
	else 
		dy = 0
	end 
	
	-- 이동할까?
	if dx ~= 0 or dy ~= 0 then 
		
		local my_x, my_y = self:getPosition()
		local tilex, tiley = self.world.map:GetTileIndexOnPosition(my_x, my_y)
		
		local target_x = tilex + dx
		local target_y = tiley + dy
		
		-- 자신의 이동할 타일에 마킹을 한다
		if world.map:IsMovableCell(target_x, target_y) then 
			-- 이동할수 있다. 이동하면 된다
		else 
			
			-- 자신 주위에 8방향중에서 이동할수 있는 곳이 있나 찾는다.
			-- 어떻게든 변화를 주려는 시도
			target_x = tilex
			target_y = tiley		
			-- 테스트용 이동하지 않는다
			local player_x, player_y = player:getPosition()
			local player_tilex, player_tiley = self.world.map:GetTileIndexOnPosition(player_x, player_y)
			
			
			local old_length = math.abs(player_tilex - tilex) + math.abs(player_tiley - tiley)
			
			for ii = math.max(1, tilex - 1) , math.min(width, tilex + 1) do 
				for jj = math.max(1, tiley - 1) , math.min(height, tiley + 1) do 
					if world.map:IsMovableCell(ii, jj) then
						-- 비어있다.  거리를 계산한다
						
						local new_length = math.abs(player_tilex - ii) + math.abs(player_tiley - jj)
						
						if new_length < old_length  then 
							target_x = ii
							target_y = jj
						end
					end
				end 
			end 
		end 
		
		if target_x ~= tilex or target_y ~= tiley then 
		
			-- 이동 객체를 만든다
			
			local to_x, to_y = self.world.map:GetTileCenterPosition(target_x, target_y)
			
			self.moving = { 
				from_x = my_x,
				from_y = my_y,
				to_x = to_x,
				to_y = to_y}
				
			self.current_movie:play()	
			
			if me.movementtile == nil then 
				print("스폰중도 아닌데 타일정보가 nil??? "..me.id)
			end 
		
			-- 앞으로 이동할 위치에 마킹을 한다
			if self.world.map:SetMovementGrid(me, target_x, target_y) == false then 
				print("여기서 오류!")
				if self.destroyed then print("파괴되었음") end
			end 
			
			--print("from " .. my_x..","..my_y .."=>"..to_x..","..to_y)
		end 
	end 
	
end 

function Boss:Stop(force)

	self.tile_dx = 0
	self.tile_dy = 0

	if force then 
		--
	else 
		if self.moving then return end
	end 
	
	if self.current_movie then 
		self.current_movie:gotoAndStop(1)
		self.stopped = true
		self.moving = nil
	end 
end 

function Boss:UpdateAttack1(deltaTime)

	-- 공격 쿨타임인가
	if self.attack1_cooltime <= 0 then 
		-- 공격횟수가 다 되었나
		if self.attack1_count > 0 then 
			self.attack1_count = self.attack1_count - 1
			self.attack1_cooltime = 1
			
			-- 보스건 공격을 한다
			local attack = Boss_FireBallShot.create()
			attack:Use(self, self.world)
			
		else 
			-- 공격이 끝났다
			self.attacktype = 4
			self.attack4_rest = 0
		end 
	end 
	
	self.attack1_cooltime = self.attack1_cooltime - deltaTime
end 

function Boss:UpdateAttack2(deltaTime)
	
	
	if self.attack2_prepare_pre then 
		self.attack2_prepare_pre = false
		self.attack2_prepare = true
		self.attack2_prepare_time = 0
		
		self.attack2_prepare_text = CreateText("달려들거야!")
		self.attack2_prepare_text:setTextColor(0xffffff)
		self.attack2_prepare_text:setPosition(-64, -96)
		self:addChild(self.attack2_prepare_text)
		
	elseif self.attack2_prepare then 
		
		self.attack2_prepare_time =	self.attack2_prepare_time + deltaTime
		if self.attack2_prepare_time > 1.5 then 
		
			self.attack2_prepare = false
			self.attack2_dash = true
		end 
		
	elseif self.attack2_dash then 
	
		self:removeChild(self.attack2_prepare_text)
	
		-- 플레이어를 향해 공격할 준비를 하자
		local player = self.world:GetPlayer()
		local my_x, my_y = self:getPosition()
		local x, y = player:getPosition()
		
		local dx = x - my_x 
		local dy = y - my_y 
		
		-- 방향벡터로 캐릭터를 지나서 256 만큼 더 가자
		local length = math.max(1, math.sqrt(dx*dx +dy*dy))
		
		self.moving = { 
			from_x = my_x,
			from_y = my_y,
			to_x = x + dx / length * 256, 
			to_y = y + dy / length * 256}
		
		self.attack2_dash= false

	elseif self.moving then 
		
		local x , y = self:getPosition()
		
		-- from 에서 to 로 이동하자,
		local oldx = x
		local oldy = y
		
		
		-- 이번에 이동할 거리를 구한다
		local length = deltaTime * self.attack2_speed
		
		-- 이동해야할 거리를 구한다
		local dx = self.moving.to_x - x
		local dy = self.moving.to_y - y
		
		local length2 = math.max(math.sqrt(dx*dx + dy*dy), 1)
		
		-- 작은쪽을 선택한다
		length = math.min(length, length2)
	
		x = x + dx / length2 * length
		y = y + dy / length2 * length
		
		self:setPosition(x, y)
		-- 이동후에 멈춰야 하는지 확인한다
		local dx = self.moving.to_x - x
		local dy = self.moving.to_y - y
		
		if math.sqrt(dx*dx + dy*dy) <= 1 then 
			-- 다음이동을 만든다
			self.moving = nil
		end
		
		if self.attack2_hit == nil then 
			-- 플레이어를 때리를수 있는지 본다
			local px, py = self.world:GetPlayer():getPosition()
			local _dx = px -x 
			local _dy = py -y 
			
			-- 거리가?
			if(_dx*_dx + _dy*_dy) < 160 * 160 then 
				self.world:HitPlayer(25)
				self.attack2_hit = true 
			end 
		end 
	else
		-- 이동을 끝낸다
		self.attacktype =4
		self.attack4_rest = 0
	end 
end 


local function FinishExplode(self)

	self.attack3_explode:removeEventListener(Event.COMPLETE, FinishExplode, self)
	self.attack3_explode:getParent():removeChild(self.attack3_explode)
	self.attack3_explode = nil
end 

function Boss:UpdateAttack3(deltaTime)
	-- 불폭탄을 떨어트린다
	if self.attack3_step == 1 then
	
		self.attack3_prepare_text = CreateText("폭탄터진다!")
		self.attack3_prepare_text:setTextColor(0xffffff)
		self.attack3_prepare_text:setPosition(-64, -96)
		self:addChild(self.attack3_prepare_text)
	
		local bmp = Bitmap.new(Texture.new("boss_skill/boss_bomb_marker.png"))
		bmp:setAnchorPoint(0.5,0.5)
		bmp:setScale(6,6)
		self.attack3_step = 2
		
		local x, y = self.world.player:getPosition()
		self.attack3_maker = {x =x ,y =y, marker = bmp }
		
		bmp:setPosition(x, y)
		self.world.corpse_layer:addChild(bmp)
		self.attack3_time = 0
		
	elseif self.attack3_step == 2 then
		-- 기다린다
		if self.attack3_time > 1 then 
			self.attack3_step = 3
		else
			self.attack3_time = self.attack3_time + deltaTime
		end 
	elseif self.attack3_step == 3 then 
		self:removeChild(self.attack3_prepare_text)
		-- 폭탄을 터트린다
		self.attack3_maker.marker:getParent():removeChild(self.attack3_maker.marker)
		
		local fb_explode_texture = Texture.new("boss_skill/fireball_explode.png")
			
		local bitmaps = {
			Bitmap.new(TextureRegion.new(fb_explode_texture, 0,0,16,16)),
			Bitmap.new(TextureRegion.new(fb_explode_texture, 16,0,16,16)),
			Bitmap.new(TextureRegion.new(fb_explode_texture, 32,0,16,16)),
			Bitmap.new(TextureRegion.new(fb_explode_texture, 48,0,16,16)),
			Bitmap.new(TextureRegion.new(fb_explode_texture, 64,0,16,16)),
			Bitmap.new(TextureRegion.new(fb_explode_texture, 80,0,16,16)) }
			
		for i = 1, #bitmaps do 
			bitmaps[i]:setAnchorPoint(0.5, 0.5)
			bitmaps[i]:setScale(20,20)
		end 
		
		
		self.attack3_explode = MovieClip.new({
			{ 0, 2, bitmaps[1] },
			{ 2, 4, bitmaps[2] },
			{ 4, 6, bitmaps[3] },
			{ 6, 8, bitmaps[4] },
			{ 8, 10, bitmaps[5] },
			{ 10, 12, bitmaps[6] }
			})
			
		self.attack3_explode:setPosition(self.attack3_maker.x, self.attack3_maker.y)
		
		self.attack3_explode:addEventListener(Event.COMPLETE, FinishExplode, self)
		self.attack3_explode:setBlendMode(Sprite.ADD)
		self.attack3_explode:play()
		self.world.corpse_layer:addChild(self.attack3_explode)
		
		-- 대미지 계산
		local px, py = self.world:GetPlayer():getPosition()
		local _dx = self.attack3_maker.x  - px
		local _dy = self.attack3_maker.y  - py
		
		if (_dx*_dx + _dy*_dy) < 180 * 180 then 
			self.world:HitPlayer(999)
		end 
		
		-- 종료
		self.attacktype = 4
		self.attack4_rest = 0
	end 
end 


function Boss:Update(event)
	if IsPaused() then return end
	if self.destroyed then return end
	
	if self.id == nil then 
		print("아이디 nil 발견!!")
	end 
	
	local world = self.world
	local x, y = self:getPosition()
	
	-- 공격모드가 3개가 있다.
	if self.attacktype == 1 then 
		-- 총쏘기 공격을 한다
		self:UpdateAttack1(event.deltaTime)
	elseif self.attacktype == 2 then 
		-- 대쉬공격
		self:UpdateAttack2(event.deltaTime)
	elseif self.attacktype == 3 then 
		-- 불폭탄
		self:UpdateAttack3(event.deltaTime)
	elseif self.attacktype == 4 then 
		-- 1초동안 휴식
		self.attack4_rest = self.attack4_rest + event.deltaTime
		if self.attack4_rest > 1 then 
			self.attacktype = nil
		end 
	else 
		local value = math.random(100)
		if value < 10 then 
			-- 10%
			self.attacktype = 3
			self.attack3_step = 1
		elseif value < 20 then 
			-- 10%
			self.attacktype = 2
			self.attack2_hit = nil
			self.attack2_prepare_pre = true
			self.attack2_speed = 600
		elseif value < 50 then 
			self.attacktype = 1
			self.attack1_cooltime = 0
			self.attack1_count = 3
		else 
			self.attacktype = 4
			self.attack4_rest = 0
		end 
	end 
end 

function Boss:ShowHP()
	
	if self.hp_bar == nil then 
		-- 체력 게이지
		local bar = GaugeBar.create(self.hpmax)
		bar:setScale(3,3)
		bar:setPosition(-24*3, 26*3)
		self.hp_bar = bar
		self:addChild(self.hp_bar)
	end 
	
	self.hp_bar:Set(self.hp)
end 

function Boss:HideHP()
	if self.hp_bar then 
		self:removeChild(self.hp_bar)
		self.hp_bar = nil
	end 
end 

function Boss:Knockback(dx, dy)
	-- 보스는 넉백되지 않는다
end 