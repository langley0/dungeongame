GaugeBar = Core.class(Sprite)

local bar_texture = Texture.new("enemy/enemy_hp_bar.png")
local bar_texture_frame = Texture.new("enemy/enemy_hp_bar_frame.png")

function GaugeBar.create(max)

	local bar = GaugeBar.new()
	
	local frame = Bitmap.new(bar_texture_frame)
	local value_bar = Bitmap.new(bar_texture)
	value_bar:setBlendMode(Sprite.MULTIPLY)
	bar:addChild(frame)
	bar:addChild(value_bar)
	
	bar.max = max
	bar.current = max
	
	bar.bar = value_bar
	
	return bar

end 

function GaugeBar:Set(value)
	-- 0 과 max 로 컬링
	value  = math.max(0, math.min(value, self.max))
	local scale = value / self.max
	self.bar:setScale(scale, 1)
end 