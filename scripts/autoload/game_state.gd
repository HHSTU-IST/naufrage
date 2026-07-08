extends Node

var _cdb: Variant

signal state_changed
signal day_changed(day: int)
signal food_changed(food: int)
signal clue_added(clue_id: String)
signal ending_changed(ending_id: String)
signal route_changed(route_id: String)
signal npc_state_changed(npc_id: String, state_value: int)
signal flag_changed(flag_name: String, value: Variant)

const DEFAULT_DAY := 1
const DEFAULT_FOOD := 15

var current_day: int = DEFAULT_DAY
var max_day: int = 15
var food: int = DEFAULT_FOOD
var starting_food: int = DEFAULT_FOOD
var is_dream_today: bool = false
var current_route: String = "west"
var route_distance: int = 0
var selected_npc_id: String = ""
var npc_states: Dictionary = {}
var clues: Array = []
var flags: Dictionary = {}
var ending_id: String = ""
var pending_day_start: bool = false


func _ready() -> void:
	_cdb = get_node("/root/ConfigDB")

func reset_game() -> void:
	if _cdb != null:
		var config: GameConfig = _cdb.get_game_config() as GameConfig
		if config != null:
			max_day = config.max_day
			starting_food = config.starting_food
		else:
			max_day = 15
			starting_food = DEFAULT_FOOD
	else:
		push_warning("GameState: ConfigDB not available, using default values")
		max_day = 15
		starting_food = DEFAULT_FOOD
	current_day = DEFAULT_DAY
	food = starting_food
	is_dream_today = false
	current_route = "west"
	route_distance = 0
	selected_npc_id = ""
	npc_states = {}
	clues = []
	flags = {}
	ending_id = ""
	pending_day_start = true
	state_changed.emit()
	day_changed.emit(current_day)
	food_changed.emit(food)
	route_changed.emit(current_route)
	ending_changed.emit(ending_id)


func to_save_dict() -> Dictionary:
	return {
		"current_day": current_day,
		"max_day": max_day,
		"starting_food": starting_food,
		"food": food,
		"is_dream_today": is_dream_today,
		"current_route": current_route,
		"route_distance": route_distance,
		"selected_npc_id": selected_npc_id,
		"npc_states": npc_states,
		"clues": clues,
		"flags": flags,
		"ending_id": ending_id,
	}


func apply_save_dict(data: Dictionary) -> void:
	current_day = int(data.get("current_day", DEFAULT_DAY))
	max_day = int(data.get("max_day", 15))
	starting_food = int(data.get("starting_food", DEFAULT_FOOD))
	food = int(data.get("food", DEFAULT_FOOD))
	is_dream_today = bool(data.get("is_dream_today", false))
	current_route = String(data.get("current_route", "west"))
	route_distance = int(data.get("route_distance", 0))
	selected_npc_id = String(data.get("selected_npc_id", ""))
	npc_states = data.get("npc_states", {})
	clues = data.get("clues", [])
	flags = data.get("flags", {})
	ending_id = String(data.get("ending_id", ""))
	pending_day_start = false
	state_changed.emit()
	day_changed.emit(current_day)
	food_changed.emit(food)
	route_changed.emit(current_route)
	ending_changed.emit(ending_id)


func advance_day() -> void:
	current_day += 1
	day_changed.emit(current_day)
	state_changed.emit()


func set_food(value: int) -> void:
	food = max(value, 0)
	food_changed.emit(food)
	state_changed.emit()


func change_food(delta: int) -> void:
	set_food(food + delta)


func set_dream_today(value: bool) -> void:
	is_dream_today = value
	state_changed.emit()


func set_route(route_id: String) -> void:
	current_route = route_id
	route_changed.emit(current_route)
	state_changed.emit()


func set_route_distance(value: int) -> void:
	route_distance = max(value, 0)
	state_changed.emit()


func set_selected_npc(npc_id: String) -> void:
	selected_npc_id = npc_id
	state_changed.emit()


func set_npc_state(npc_id: String, state_value: int) -> void:
	npc_states[npc_id] = state_value
	npc_state_changed.emit(npc_id, state_value)
	state_changed.emit()


func get_npc_state(npc_id: String, default_value: int = 0) -> int:
	return int(npc_states.get(npc_id, default_value))


func add_clue(clue_id: String) -> void:
	if clue_id in clues:
		return
	clues.append(clue_id)
	clue_added.emit(clue_id)
	state_changed.emit()


func set_flag(flag_name: String, value: Variant) -> void:
	flags[flag_name] = value
	flag_changed.emit(flag_name, value)
	state_changed.emit()


func clear_flag(flag_name: String) -> void:
	if not flags.has(flag_name):
		return
	flags.erase(flag_name)
	flag_changed.emit(flag_name, null)
	state_changed.emit()


func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name)


func set_ending(value: String) -> void:
	ending_id = value
	ending_changed.emit(ending_id)
	state_changed.emit()
