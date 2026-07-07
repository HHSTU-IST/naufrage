extends Node
class_name EndingSystem

func check_end_conditions() -> void:
	if GameState.food <= 0:
		trigger_ending("ending_starve")
	elif GameState.current_day > GameState.MAX_DAY:
		trigger_ending("ending_timeout")

func trigger_ending(ending_id: String) -> void:
	if GameState.ending_id == ending_id:
		return
	GameState.set_ending(ending_id)