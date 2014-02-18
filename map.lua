SPRITE_SCALE = 3

Map = Core.class(Sprite)

tilemap_texture = Texture.new("dungeon/tile04.png")


tilegrid = { 
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1},
	{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1},
	{1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1},
	{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
	{1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1},
	{1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1},
	{1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1},
	{1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1},
	{1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1},
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
	{1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
}

tileinfo = {  
	{ x = 1, y = 1 }, 
	{ x = 2, y = 1 }
}

function Map.create()

	local map = Map.new()
	map:setBlendMode(Sprite.MULTIPLY)
	
	map.width = 32
	map.height = 32
	map.tilewidth = 16
	map.tileheight = 16
	
	local tilemap = TileMap.new(map.width,map.height,tilemap_texture,map.tilewidth,map.tileheight)
	
	for i = 1, map.width do 
		for j = 1, map.height do 

			local info = 1
			tilemap:setTile(i, j, tileinfo[info].x, tileinfo[info].y, 0)
		end 
	end
	
	
	local movement_grid = {}
	for i = 1, map.width do 
		movement_grid[i] = {}
	end
	map.movement_grid = movement_grid
	
	
	tilemap:setScale(SPRITE_SCALE, SPRITE_SCALE)
	map:addChild(tilemap)
	
	return map

end 

function Map:GetTileIndexOnPosition(x, y)
	local xx = math.floor((x - 0.00001) / (self.tilewidth * SPRITE_SCALE)) + 1
	local yy = math.floor((y - 0.00001) / (self.tileheight * SPRITE_SCALE)) + 1 
	
	return xx, yy
	
end 

function Map:GetTileCenterPosition(index_x, index_y)
	return 
		((index_x - 1) * self.tilewidth + self.tilewidth / 2) * SPRITE_SCALE,
		((index_y - 1) * self.tileheight + self.tileheight/ 2)* SPRITE_SCALE
end 

function Map:IsMovableCell(x, y, ignore_monster)
	if x >= 1 and x <= self.width and 
		y >= 1 and y <= self.height then 
		
		if ignore_monster then 
			-- 옵스터클만 계산한다
			return true
		else 
			-- 몬스터끼리의 자리이동을계산한다
			if self.movement_grid[x][y] then 
				return false 
			else
				return true
			end 
		end 
	end 
	
	return false
end

count = 0

function Map:SetMovementGrid(unit, x, y)
	if x >= 1 and x <= self.width and 
		y >= 1 and y <= self.height then 
		
		if self.movement_grid[x][y] then 
			if unit == nil then 
				self.movement_grid[x][y] = nil
				count = count - 1
			elseif self.movement_grid[x][y]== unit then 
				-- 같은 곳에 넣으려고 한다. 아무것도 하지 않는다
			else 
				print("[!!!!!] movement grid 오류")
				print(x..","..y)
				
				return false
			end 
		else
			
			if unit then
				-- 기존위치를 제거한다
				if self.movement_grid[unit.movementtile.x][unit.movementtile.y] then 
					self.movement_grid[unit.movementtile.x][unit.movementtile.y] = nil
					count = count - 1
				else 
					print("기존위치에 아무것도 없다!!!")
				end 
				
				unit.movementtile.x = x
				unit.movementtile.y = y
			end 
			-- 빈곳에 들어간다
			self.movement_grid[x][y] = unit
			
			count = count + 1
		end 
		return true
	end 
	
	return false
end 