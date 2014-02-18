Enemy = Core.class(Sprite)

local e_t = Texture.new("enemy/enemy02.png")

function Enemy.create(world, type)

	-- 네방향 플레이어 이미지를 만든다
	local down_bitmaps = {
		Bitmap.new(TextureRegion.new(e_t, 0,0,16,16)),
		Bitmap.new(TextureRegion.new(e_t, 16,0,16,16)) }
		
	for i = 1, #down_bitmaps do 
		down_bitmaps[i]:setAnchorPoint(0.5, 0.5)
		down_bitmaps[i]:setScale(SPRITE_SCALE,SPRITE_SCALE)
	end
	local down_movie = MovieClip.new({
		{ 1, 4, down_bitmaps[1] },
		{ 5, 8, down_bitmaps[2] }
	})
	down_movie:setGotoAction(8,1)
	
	
	local e = Enemy.new()
	
	e.down_movie = down_movie
	e.up_movie = down_movie
	e.right_movie = down_movie
	e.left_movie = down_movie
	
	e:addChild(down_movie)
	e.current_movie = down_movie
	e.stopped = true
	e.current_movie:stop()
	
	
	e.damage_text = HitDamageText.create()
	e.damage_text:setPosition(24, -10)
	e:addChild(e.damage_text)
	
	if type == 1 then 
		e.hp = 20
		e.hpmax = 20
		e.speed = 50
		e.exp = 1
	elseif type == 2 then 
		e.hp = 40
		e.hpmax = 40
		e.speed = 50
		e.exp = 2
	elseif type == 3 then 
		e.hp = 80
		e.hpmax = 80
		e.speed = 150
		e.exp = 4
	end
		
	e.world = world
	e.attack_sqrt = 64*64*1.5
	
	
	e:addEventListener(Event.ENTER_FRAME, e.Update, e)
	
	return e

end 

function Enemy:Die()
	
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
function Enemy:TargetPlayer(player)
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

function Enemy:MoveToPlayer(player)
	
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

function Enemy:Stop(force)

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

function Enemy:Update(event)

	if self.destroyed then return end
	
	if self.id == nil then 
		print("아이디 nil 발견!!")
	end 
	
	local world = self.world
	local x, y = self:getPosition()
	
	-- 이동을 한다
	
	if self.moving then 
		
		-- from 에서 to 로 이동하자,
		
		local oldx = x
		local oldy = y
		
		
		-- 이번에 이동할 거리를 구한다
		local length = event.deltaTime * self.speed
		
		-- 이동해야할 거리를 구한다
		local dx = self.moving.to_x - x
		local dy = self.moving.to_y - y
		
		local length2 = math.sqrt(dx*dx + dy*dy)
		
		-- 작은쪽을 선택한다
		length = math.min(length, length2)
	
		x = x + dx / length2 * length
		y = y + dy / length2 * length
		
		self:setPosition(x, y)
		-- 이동후에 멈춰야 하는지 확인한다
		local dx = self.moving.to_x - x
		local dy = self.moving.to_y - y
		
		if math.sqrt(dx*dx + dy*dy) <= 0.01 then 
			-- 다음이동을 만든다
			self.moving = nil
		end
	else 
		
		-- 플레이어와 거리를 구한다
		local player = world:GetPlayer() 
		local px, py = player:getPosition()
		
		local attack_range = 64
		
		if (px - x)* (px - x) + (py - y)*(py - y) < attack_range*attack_range then 
			-- 공격을 한다
			world:HitPlayer(5)
		else 
			-- 플레이어를 향해 움직인다
			self:MoveToPlayer(player)
		end 
	end
end 

function Enemy:ShowHP()
	
	if self.hp_bar == nil then 
		-- 체력 게이지
		local bar = GaugeBar.create(self.hpmax)
		bar:setPosition(-24, 26)
		self.hp_bar = bar
		self:addChild(self.hp_bar)
	end 
	
	self.hp_bar:Set(self.hp)
end 

function Enemy:HideHP()
	if self.hp_bar then 
		self:removeChild(self.hp_bar)
		self.hp_bar = nil
	end 
end 

function Enemy:Knockback(dx, dy)
	-- 현재 위치에서 x, y 만큼 넉백시킨다
	self.knockback = { dx = x, dy = y}
end 