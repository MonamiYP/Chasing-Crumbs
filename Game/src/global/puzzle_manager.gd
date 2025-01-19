extends Node

var current_puzzle_npc : NPC

signal start_puzzle
signal puzzle_complete
signal puzzle_giveup

func _ready() -> void:
	puzzle_complete.connect(_puzzle_complete)

func load_puzzle(puzzle_no : int) -> void:
	emit_signal("start_puzzle", puzzle_no)

func _puzzle_complete() -> void:
	current_puzzle_npc.current_key = "PuzzleComplete"

func _puzzle_giveup() -> void:
	current_puzzle_npc.current_key = "PuzzleGiveup"
