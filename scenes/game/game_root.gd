extends Node

const DEFAULT_SAVE_SLOT := 0

var _gs: Variant
var _eb: Variant
var _sm: Variant

@onready var day_system: DaySystem = $Systems/DaySystem
@onready var food_system: FoodSystem = $Systems/FoodSystem
@onready var npc_system: NpcSystem = $Systems/NpcSystem
@onready var route_system: RouteSystem = $Systems/RouteSystem
@onready var ending_system: EndingSystem = $Systems/EndingSystem

func _ready() -> void:
	_gs = get_node("/root/GameState")
	_eb = get_node("/root/EventBus")
	_sm = get_node("/root/SaveManager")
	if _gs == null or _eb == null or _sm == null:
		push_error("GameRoot: autoload nodes not available")
		return
	if day_system == null or food_system == null or npc_system == null or route_system == null or ending_system == null:
		push_error("GameRoot: system nodes not available")
		return
	# DreamSystem is referenced by DaySystem; existence checked here for safety.
	if not has_node("Systems/DreamSystem"):
		push_warning("GameRoot: DreamSystem node missing, dream mechanics may not work")
	_gs.state_changed.connect(_on_state_changed)
	_eb.dialogue_requested.connect(_on_dialogue_requested)
	_eb.route_requested.connect(_on_route_requested)
	_eb.rescue_requested.connect(_on_rescue_requested)
	_eb.sleep_requested.connect(_on_sleep_requested)
	_eb.save_requested.connect(_on_save_requested)
	_eb.load_requested.connect(_on_load_requested)
	_eb.clear_requested.connect(_on_clear_requested)
	_eb.ending_requested.connect(_on_ending_requested)
	_eb.game_reset_requested.connect(_on_game_reset_requested)
	if _gs.pending_day_start:
		day_system.start_day()
		_gs.pending_day_start = false

func _on_state_changed() -> void:
	ending_system.check_end_conditions()
	if _is_game_over():
		return
	# 路线走完后尝试切换到下一条
	if route_system.reached_end():
		route_system.try_advance_route()

func _on_dialogue_requested(npc_id: String) -> void:
	if npc_id.is_empty() or _is_game_over():
		return
	npc_system.talk_to(npc_id)
	_gs.add_clue("talked_%s" % npc_id)

func _on_route_requested(action: String) -> void:
	if _is_game_over():
		return
	if action == "forward":
		if food_system.spend(1):
			if _is_game_over():
				return
			route_system.move_forward()
	elif action == "back":
		if food_system.spend(1):
			if _is_game_over():
				return
			route_system.move_back()

func _on_rescue_requested(npc_id: String) -> void:
	if npc_id.is_empty() or _is_game_over():
		return
	if food_system.spend(1):
		if _is_game_over():
			return
		npc_system.rescue(npc_id)

func _on_sleep_requested() -> void:
	if _is_game_over():
		return
	if food_system.spend(1):
		if _is_game_over():
			return
		day_system.end_day()
		if _is_game_over():
			return
		day_system.start_day()

func _on_save_requested(slot_id: int) -> void:
	if not _sm.save_game(slot_id):
		push_warning("GameRoot: failed to save slot %d" % slot_id)

func _on_load_requested(slot_id: int) -> void:
	if not _sm.load_game(slot_id):
		push_warning("GameRoot: failed to load slot %d" % slot_id)

func _on_clear_requested(slot_id: int) -> void:
	if not _sm.clear_slot(slot_id):
		push_warning("GameRoot: failed to clear slot %d" % slot_id)

func _on_ending_requested(ending_id: String) -> void:
	if ending_id.is_empty():
		return
	ending_system.trigger_ending(ending_id)

func _on_game_reset_requested() -> void:
	_gs.reset_game()
	day_system.start_day()
	_gs.pending_day_start = false

func _is_game_over() -> bool:
	return not _gs.ending_id.is_empty()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_forward"):
		_eb.route_requested.emit("forward")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_back"):
		_eb.route_requested.emit("back")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("talk"):
		_eb.dialogue_requested.emit(_gs.selected_npc_id)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rescue"):
		_eb.rescue_requested.emit(_gs.selected_npc_id)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("sleep"):
		_eb.sleep_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("save"):
		_eb.save_requested.emit(DEFAULT_SAVE_SLOT)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("load"):
		_eb.load_requested.emit(DEFAULT_SAVE_SLOT)
		get_viewport().set_input_as_handled()
