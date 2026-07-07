extends Node
class_name NpcSystem

func talk_to(npc_id: String) -> void:
	GameState.set_selected_npc(npc_id)
	GameState.set_flag("talked_%s" % npc_id, true)

func rescue(npc_id: String) -> void:
	var state_value := GameState.get_npc_state(npc_id, 0)
	GameState.set_npc_state(npc_id, state_value + 1)