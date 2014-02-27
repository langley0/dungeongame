stage:setBackgroundColor(0.2,0.2,0.2)

function StartPlay(lobby, player)
	
	-- 게임을 시작한다
	stage:removeChild(lobby)
	Lobby.destroy(lobby)
	current_player= player
	
	-- 
	local world = World.create()
	world.GotoLobby = RetunToLobby
	world:EnterPlayer(player)
	stage:addChild(world)
	
	world:ResetStageTo(1)
	
	world_destroyed = nil
	stage:addChild(gamemenu)

end

function RetunToLobby(world)
	
	stage:removeChild(world)
	stage:removeChild(gamemenu)
	StartLobby()
	

end 

function StartLobby()
	local lobby = Lobby.create()
	lobby.StartPlay = StartPlay
	stage:addChild(lobby)
end 

gamemenu = GameMenu.create()
StartLobby()
