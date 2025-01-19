extends CanvasLayer

@onready var puzzle_board: PuzzleBoard = $VBoxContainer/HBoxContainer/Panel2/GameBoard

func _ready() -> void:
	visible = false
	PuzzleManager.connect("start_puzzle", start_puzzle)
	PuzzleManager.connect("puzzle_complete", puzzle_complete)

func start_puzzle(puzzle_no : int) -> void:
	get_tree().paused = true
	puzzle_board.load_puzzle(puzzle_no)
	visible = true

func puzzle_complete() -> void:
	await SceneTransition.fade_out()
	visible = false
	puzzle_board.puzzle_complete()
	await SceneTransition.fade_in()
	get_tree().paused = false
