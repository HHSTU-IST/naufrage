extends Node

@onready var day_system = $Systems/DaySystem
@onready var ending_system = $Systems/EndingSystem

func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)
	GameState.ending_changed.connect(_on_ending_changed)
	day_system.start_day()

func _on_state_changed() -> void:
	ending_system.check_end_conditions()

func _on_ending_changed(ending_id: String) -> void:
	print("ending:", ending_id)