-- 몬스터를 스폰시킬 데이터를 만든다

spawndata = 
{ 
	{
		{ x = 7, y = 23 , width = 2, height = 2, type = 1},
		{ x = 23, y = 23 , width = 2, height =2, type = 1},
		{ x = 23, y = 7 , width = 2, height = 2, type = 1},
		{ x = 7, y = 7 , width = 2, height = 2, type = 1},
	},
	
	{
		{ x = 5, y = 25 , width = 3, height = 3, type = 1},
		{ x = 25, y = 25 , width = 3, height =3, type = 1},
		{ x = 25, y = 5 , width = 3, height = 3, type = 1},
		{ x = 5, y = 5 , width = 3, height = 3, type = 1},
	},
	{
		{ x = 7, y = 23 , width = 2, height = 2, type = 1},
		{ x = 23, y = 23 , width = 2, height =2, type = 1},
		{ x = 23, y = 7 , width = 2, height = 2, type = 1},
		{ x = 7, y = 7 , width = 2, height = 2, type = 1},
		{ x = 5, y = 25 , width = 2, height = 2, type = 2},
		{ x = 25, y = 5 , width = 2, height = 2, type = 2},
	},
	
	{
		{ x = 5, y = 25 , width = 3, height = 3, type = 2},
		{ x = 25, y = 25 , width = 3, height =3, type = 2},
		{ x = 25, y = 5 , width = 3, height = 3, type = 2},
		{ x = 5, y = 5 , width = 3, height = 3, type = 2},
		{ x = 15, y = 27 , width = 1, height = 1, type = 3},
	},
	
	{
		{ x = 7, y = 23 , width = 4, height = 4, type = 2},
		{ x = 23, y = 23 , width = 4, height =4, type = 2},
		{ x = 23, y = 7 , width = 4, height = 4, type = 2},
		{ x = 7, y = 7 , width = 4, height = 4, type = 2},
		
		{ x = 15, y = 3 , width = 2, height = 2, type = 3},
		{ x = 15, y = 27 , width = 2, height = 2, type = 3},
	},
	
	{
		{ x = 20, y = 23 , width = 1, height = 1, type = 99},
	},
}

spawn_now = false

function SpawnMonster(world, spawnlevel)

	if spawnlevel > #spawndata then 
		return false
	end 
	
	spawn_now =  true
	local _spawn = spawndata[spawnlevel]
	for j = 1, #_spawn do 
		local spawn_info = _spawn[j]
		
		for _x = spawn_info.x, spawn_info.x + spawn_info.width - 1 do
			for _y = spawn_info.y, spawn_info.y + spawn_info.height - 1 do
			
				local x, y = world.map:GetTileCenterPosition(_x, _y)
				
				if spawn_info.type == 99 then 
					local e= Boss.create(world, spawn_info.type)
					e:setPosition(x, y)
					world:SpawnMonster(e)
				else 
					local e= Enemy.create(world, spawn_info.type)
					e:setPosition(x, y)
					world:SpawnMonster(e)
				end 
			
			end 
		end 
	end 
	
	spawn_now = false
	return true
end 