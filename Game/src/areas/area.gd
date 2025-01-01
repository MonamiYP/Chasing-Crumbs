extends Node2D

func _ready() -> void:
	load_area()

func free_area() -> void:
	PlayerManager.unparent_player(self)
	queue_free()

func load_area() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	AreaManager.area_load_started.connect(free_area)
