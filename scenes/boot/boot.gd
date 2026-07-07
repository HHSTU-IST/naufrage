extends Node

var _gs: Node
var _sm: Node

func _ready() -> void:
	_gs = get_node("/root/GameState")
	_sm = get_node("/root/SaveManager")
	if not _restore_saved_game():
		_gs.reset_game()
	get_tree().change_scene_to_file("res://scenes/game/game_root.tscn")

func _restore_saved_game() -> bool:
	if not _sm.has_save(0):
		return false
	if not _sm.load_game(0):
		return false
	_gs.pending_day_start = false
	return true
