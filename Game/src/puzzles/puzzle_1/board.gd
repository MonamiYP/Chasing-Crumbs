extends Control

@export var game_size : int = 2
@export var tile_size : int = 200
@export var tile_scene: PackedScene
@export var slide_duration : float = 0.1

var board : Array = []
var tiles : Array[Tile] = []
var empty_tile_pos : Vector2 = Vector2()
var is_animating : bool = false
var tiles_animation : int = 0

var number_visible : bool = false

enum GAME_STATES { START, COMPLETED }
var game_state : GAME_STATES = GAME_STATES.START

func _ready() -> void:
	tile_size = floor(get_size().x / game_size)
	set_size(Vector2(tile_size*game_size, tile_size*game_size))
	generate_board()
	scramble_board()

func generate_board() -> void:
	var counter : int = 1
	board = []
	for r in range(game_size):
		board.append([])
		for c in range(game_size):
			if (counter == game_size*game_size): # Find empty cell
				board[r].append(0)
				empty_tile_pos = Vector2(c, r)
			else:
				board[r].append(counter)

				var tile : Tile = tile_scene.instantiate()
				tile.set_position(Vector2(c * tile_size, r * tile_size))
				tile.set_text(counter)
				tile.set_sprite(counter-1, game_size, tile_size)
				tile.set_number_visible(number_visible)
				tile.tile_pressed.connect(_on_tile_pressed)
				tile.slide_completed.connect(_on_tile_slide_completed)
				add_child(tile)
				tiles.append(tile)

			counter += 1

func is_board_solved() -> bool:
	var counter : int = 1
	for r in range(game_size):
		for c in range(game_size):
			if (board[r][c] != counter):
				if r == c and c == game_size - 1 and board[r][c] == 0:
					return true
				else:
					return false
			counter += 1
	return true

func get_gridpos_by_value(value : int) -> Vector2:
	for r in range(game_size):
		for c in range(game_size):
			if (board[r][c] == value):
				return Vector2(c, r)
	return Vector2.ZERO

func get_tile_by_value(value : int) -> Tile:
	for tile in tiles:
		if str(tile.number) == str(value):
			return tile
	return null

func _on_tile_pressed(number : int) -> void:
	if is_animating:
		return

	var tile_pos : Vector2 = get_gridpos_by_value(number)
	empty_tile_pos = get_gridpos_by_value(0)

	# Check clicked position in row or column of empty tile
	if (tile_pos.x != empty_tile_pos.x and tile_pos.y != empty_tile_pos.y):
		return

	# Slide all tiles in clicked row or column
	var dir : Vector2 = Vector2(sign(tile_pos.x - empty_tile_pos.x), sign(tile_pos.y - empty_tile_pos.y))
	var start : Vector2 = Vector2(min(tile_pos.x, empty_tile_pos.x), min(tile_pos.y, empty_tile_pos.y))
	var end : Vector2 = Vector2(max(tile_pos.x, empty_tile_pos.x), max(tile_pos.y, empty_tile_pos.y))
	for r in range(end.y, start.y - 1, -1):
		for c in range(end.x, start.x - 1, -1):
			if board[r][c] == 0:
				continue
			var current_tile: Tile = get_tile_by_value(board[r][c])
			current_tile.slide_to((Vector2(c, r)-dir) * tile_size, slide_duration)
			is_animating = true
			tiles_animation += 1
	
	if tile_pos.y == empty_tile_pos.y: # Clicked in same row as as empty tile
		if dir.x == -1:
			board[tile_pos.y] = slide_row(board[tile_pos.y], 1, start.x)
		else:
			board[tile_pos.y] = slide_row(board[tile_pos.y], -1, end.x)

	if tile_pos.x == empty_tile_pos.x: # Clicked in same column as empty tile
		var col : Array = []
		for r in range(game_size):
			col.append(board[r][tile_pos.x])

		if dir.y == -1:
			col = slide_column(col, 1, start.y)
		else:
			col = slide_column(col, -1, end.y)

		for r in range(game_size):
			board[r][tile_pos.x] = col[r]

	if is_board_solved():
		game_state = GAME_STATES.COMPLETED
		await get_tree().create_timer(0.5).timeout
		PuzzleManager.puzzle_complete.emit()

func is_board_solvable(flat: Array) -> bool:
	var parity : int = 0
	var grid_width : int = game_size
	var row : int = 0
	var blank_row : int = 0
	for i in range(game_size*game_size):
		if i % grid_width == 0:
			row += 1

		if flat[i] == 0:
			blank_row = row
			continue

		for j in range(i+1, game_size*game_size):
			if flat[i] > flat[j] and flat[j] != 0:
				parity += 1

	if grid_width % 2 == 0:
		if blank_row % 2 == 0:
			return parity % 2 == 0
		else:
			return parity % 2 != 0
	else:
		return parity % 2 == 0

func scramble_board() -> void:
	reset_board()

	# Generate a flat board with values 0 to game_size*game_size-1
	var temp_flat_board : Array = []
	for i in range(game_size*game_size - 1, -1, -1):
		temp_flat_board.append(i)

	randomize()
	temp_flat_board.shuffle()
	while not is_board_solvable(temp_flat_board):
		randomize()
		temp_flat_board.shuffle()
		
	# Convert flat 1d board to 2d board
	for r in range(game_size):
		for c in range(game_size):
			board[r][c] = temp_flat_board[r*game_size + c]
			if board[r][c] != 0:
				set_tile_position(r, c, board[r][c])
	empty_tile_pos = get_gridpos_by_value(0)

func reset_board() -> void:
	board = []
	for r in range(game_size):
		board.append(([]))
		for c in range(game_size):
			board[r].append(r*game_size + c + 1)
			if r*game_size + c + 1 == game_size * game_size:
				board[r][c] = 0
			else:
				set_tile_position(r, c, board[r][c])
	empty_tile_pos = get_gridpos_by_value(0)

func set_tile_position(r: int, c: int, val: int) -> void:
	var object: Tile = get_tile_by_value(val)
	object.set_position(Vector2(c, r) * tile_size)

func _process(_delta : float) -> void:
	var is_pressed : bool = true
	var dir : Vector2 = Vector2.ZERO
	if (Input.is_action_just_pressed("left")):
		dir.x = 1
	elif (Input.is_action_just_pressed("right")):
		dir.x = -1
	elif (Input.is_action_just_pressed("up")):
		dir.y = 1
	elif (Input.is_action_just_pressed("down")):
		dir.y = -1
	else:
		is_pressed = false
		
	if is_pressed:
		empty_tile_pos = get_gridpos_by_value(0)

		var nr : int = int(empty_tile_pos.y + dir.y)
		var nc : int = int(empty_tile_pos.x + dir.x)
		if (nr == -1 or nc == -1 or nr >= game_size or nc >= game_size):
			return
		_on_tile_pressed(board[nr][nc])

func slide_row(row : Array, dir : int, index : int) -> Array:
	var empty_index : int = row.find(0)
	if dir == 1: # slide towards the right
		var pre : Array = row.slice(0, index)
		var mid : Array = row.slice(index, empty_index)
		var end : Array = row.slice(empty_index+1, row.size())
		return pre + [0] + mid + end
	else: # slide towards the left
		var pre : Array = row.slice(0, empty_index)
		var mid : Array = row.slice(empty_index+1, index+1)
		var end : Array = row.slice(index+1, row.size())
		return pre + mid + [0] + end

func slide_column(col : Array, dir : int, limiter : int) -> Array:
	var empty_index : int = col.find(0)

	if dir == 1: # Slide down
		var pre : Array = col.slice(0, limiter)
		var mid : Array = col.slice(limiter, empty_index)
		var end : Array = col.slice(empty_index+1, col.size())
		return pre + [0] + mid + end
	else: # Slide up
		var pre : Array = col.slice(0, empty_index)
		var mid : Array = col.slice(empty_index+1, limiter+1)
		var end : Array = col.slice(limiter+1, col.size())
		return pre + mid + [0] + end

func _on_tile_slide_completed(_number : int) -> void:
	tiles_animation -= 1
	if tiles_animation == 0:
		is_animating = false

func set_tile_numbers(state : GAME_STATES) -> void:
	number_visible = state
	for tile in tiles:
		tile.set_number_visible(state)

func update_size(new_size : int) -> void:
	game_size = new_size

	tile_size = floor(get_size().x / game_size)
	for tile in tiles:
		tile.queue_free()
	tiles = []
	generate_board()
	scramble_board()
