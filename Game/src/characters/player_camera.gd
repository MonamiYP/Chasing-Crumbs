extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AreaManager.area_loaded.connect(set_camera_limits)

func set_camera_limits() -> void:
	var area_size : Vector2 = AreaManager.bg_size
	var player : Player = PlayerManager.player
	
	self.limit_left = 0
	self.limit_right = area_size.x
	self.limit_top = 0
	self.limit_bottom = area_size.y
