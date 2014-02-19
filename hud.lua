PlayerHUD = Core.class(Sprite)

function PlayerHUD.create()

	local texture = Texture.new("dungeon/player_hud.png")
	local hud = PlayerHUD.new()
	hud.portrait = Bitmap.new(TextureRegion.new(texture, 0, 0, 92, 92))
	hud.hp_bar = Bitmap.new(TextureRegion.new(texture, 93, 43, 256, 21))
	hud.stamina_bar = Bitmap.new(TextureRegion.new(texture, 93, 68, 256, 21))
	
	hud.hp_bar:setAnchorPoint(0,0.5)
	hud.stamina_bar:setAnchorPoint(0,0.5)
	
	hud.hp_bar:setPosition(92,42)
	hud.stamina_bar:setPosition(92,65)
	
	
	hud:addChild(hud.portrait)
	hud:addChild(hud.hp_bar)
	hud:addChild(hud.stamina_bar)
	
	hud:addEventListener(Event.ENTER_FRAME, hud.Update, hud)
	hud:setPosition(50,620)
	
	return hud
end 

function PlayerHUD:SetPlayer(player)

	self.player = player
	
end 

function PlayerHUD:Update(event)
	if self.player then 
		-- hp 와 stamina 의 상태를 체크한다
		self.hp_bar:setScale(self.player.hp / self.player.hp_max, 1)
	end 
end 