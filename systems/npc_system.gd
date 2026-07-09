extends Node
class_name NpcSystem

var _cdb: Variant
var _eb: Variant

func _ready() -> void:
	_cdb = get_node_or_null("/root/ConfigDB")
	_eb = get_node_or_null("/root/EventBus")

func talk_to(npc_id: String) -> void:
	GameState.set_selected_npc(npc_id)
	GameState.set_flag("talked_%s" % npc_id, true)
	# Find and display the first available dialogue for this NPC
	_show_dialogue_for_npc(npc_id)

func rescue(npc_id: String) -> void:
	var state_value := GameState.get_npc_state(npc_id, 0)
	GameState.set_npc_state(npc_id, state_value + 1)
	# Show rescue dialogue if available
	_show_dialogue_for_npc(npc_id)

func _show_dialogue_for_npc(npc_id: String) -> void:
	if _cdb == null or _eb == null:
		return
	var all_dialogues: Dictionary = _cdb.dialogues
	var npc_state: int = GameState.get_npc_state(npc_id, 0)
	var best_dialogue: DialogueData = null
	# Iterate through dialogues, find one matching this NPC and appropriate for current state
	for dialogue_key in all_dialogues:
		var dialogue: DialogueData = all_dialogues[dialogue_key] as DialogueData
		if dialogue == null:
			continue
		if dialogue.speaker_id != npc_id:
			continue
		# Skip dream-only dialogues when not in dream
		if dialogue.dream_only and not GameState.is_dream_today:
			continue
		# Skip already-seen dialogues (tracked by flags)
		var seen_flag := "dialogue_seen_%s" % dialogue.id
		if GameState.has_flag(seen_flag):
			continue
		best_dialogue = dialogue
		break
	if best_dialogue == null:
		return
	# Mark dialogue as seen
	GameState.set_flag("dialogue_seen_%s" % best_dialogue.id, true)
	# Get speaker display name
	var speaker_name: String = npc_id
	if _cdb.has_character(npc_id):
		var char_data: CharacterData = _cdb.get_character(npc_id) as CharacterData
		if char_data != null and not char_data.display_name.is_empty():
			speaker_name = char_data.display_name
	# Emit dialogue for HUD display
	_eb.dialogue_displayed.emit(speaker_name, best_dialogue.text, best_dialogue.dream_only)