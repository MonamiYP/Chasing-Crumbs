extends TextureButton
class_name Tile

var number : int

signal tile_pressed
signal slide_completed

func set_text(new_number: int) -> void:
	number = new_number
	$Number/Label.text = str(number)

func set_sprite(new_frame: int, s: float, tile_size: float) -> void:
	var sprite : Sprite2D = $Sprite2D

	update_size(s, tile_size)

	sprite.set_hframes(s)
	sprite.set_vframes(s)
	sprite.set_frame(new_frame)

func update_size(s: float, tile_size: float) -> void:
	var new_size : Vector2 = Vector2(tile_size, tile_size)
	set_size(new_size)
	$Number.set_size(new_size)
	$Number/ColorRect.set_size(new_size)
	$Number/Label.set_size(new_size)
	$Panel.set_size(new_size)

	var to_scale : Vector2 = s * (new_size / $Sprite2D.texture.get_size())
	$Sprite2D.set_scale(to_scale)

func slide_to(new_position : Vector2, duration : float) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "position", new_position, duration)
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	tween.connect("finished", _on_tween_completed)

func set_number_visible(state : bool) -> void:
	$Number.visible = state

func _on_tile_pressed() -> void:
	emit_signal("tile_pressed", number)

# Tile has finished sliding
func _on_tween_completed() -> void:
	emit_signal("slide_completed", number)
