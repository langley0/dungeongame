stage:setBackgroundColor(0.2,0.2,0.2)


function StartPlay(lobby, player)
	
	-- 게임을 시작한다
	stage:removeChild(lobby)
	Lobby.destroy(lobby)
	current_player= player
	
	-- 
	local world = World.create()
	world:EnterPlayer(player)
	stage:addChild(world)
	
	world:ResetStageTo(1)
end


function StartLobby()
	local lobby = Lobby.create()
	lobby.StartPlay = StartPlay
	stage:addChild(lobby)
end 

StartLobby()
