extends Node

@onready var day_system = $Systems/DaySystem
@onready var food_system = $Systems/FoodSystem
@onready var npc_system = $Systems/NpcSystem
@onready var route_system = $Systems/RouteSystem
@onready var ending_system = $Systems/EndingSystem

func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)
	GameState.ending_changed.connect(_on_ending_changed)
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	EventBus.route_requested.connect(_on_route_requested)
	EventBus.rescue_requested.connect(_on_rescue_requested)
	EventBus.sleep_requested.connect(_on_sleep_requested)
	EventBus.save_requested.connect(_on_save_requested)
	EventBus.load_requested.connect(_on_load_requested)
	day_system.start_day()

func _on_state_changed() -> void:
	ending_system.check_end_conditions()

func _on_ending_changed(ending_id: String) -> void:
	print("ending:", ending_id)

func _on_dialogue_requested(npc_id: String) -> void:
	if npc_id.is_empty():
		return
	npc_system.talk_to(npc_id)
	GameState.add_clue("talked_%s" % npc_id)

func _on_route_requested(action: String) -> void:
	if action == "forward":
		if food_system.spend(1):
			route_system.move_forward()
	elif action == "back":
		if food_system.spend(1):
			route_system.move_back()
	GameState.state_changed.emit()

func _on_rescue_requested(npc_id: String) -> void:
	if npc_id.is_empty():
		return
	if food_system.spend(1):
		npc_system.rescue(npc_id)
		GameState.state_changed.emit()

func _on_sleep_requested() -> void:
	if food_system.spend(1):
		day_system.end_day()
		day_system.start_day()

func _on_save_requested(slot_id: int) -> void:
	SaveManager.save_game(slot_id)

func _on_load_requested(slot_id: int) -> void:
	if SaveManager.load_game(slot_id):
		day_system.start_day()