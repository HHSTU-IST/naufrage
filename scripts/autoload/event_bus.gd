extends Node
class_name EventBus

signal dialogue_requested(npc_id: String)
signal route_requested(route_id: String)
signal rescue_requested(npc_id: String)
signal sleep_requested
signal save_requested(slot_id: int)
signal load_requested(slot_id: int)
signal ending_requested(ending_id: String)
signal game_reset_requested

