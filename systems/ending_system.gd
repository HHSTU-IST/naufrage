extends Node
class_name EndingSystem

var _cdb: Variant
var _eb: Variant

func _ready() -> void:
	_cdb = get_node_or_null("/root/ConfigDB")
	_eb = get_node_or_null("/root/EventBus")

func check_end_conditions() -> void:
	if GameState.food <= 0:
		trigger_ending("ending_starve")
		return
	if GameState.current_day > GameState.max_day:
		trigger_ending("ending_timeout")
		return
	if _check_true_ending():
		trigger_ending("ending_truth")
		return

func trigger_ending(ending_id: String) -> void:
	if not GameState.ending_id.is_empty():
		return
	GameState.set_ending(ending_id)

## 真结局条件：三个 NPC 都至少救到 state >= 2，且走完了所有三条路线
func _check_true_ending() -> bool:
	if GameState.get_npc_state("fisher_west", 0) < 2:
		return false
	if GameState.get_npc_state("fisher_north", 0) < 2:
		return false
	if GameState.get_npc_state("fisher_east", 0) < 2:
		return false
	# 必须收集到至少 3 条线索
	if GameState.clues.size() < 3:
		return false
	return true