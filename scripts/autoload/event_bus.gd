extends Node

@warning_ignore("unused_signal")
signal dialogue_requested(npc_id: String)
@warning_ignore("unused_signal")
signal route_requested(route_id: String)
@warning_ignore("unused_signal")
signal rescue_requested(npc_id: String)
@warning_ignore("unused_signal")
signal sleep_requested
@warning_ignore("unused_signal")
signal save_requested(slot_id: int)
@warning_ignore("unused_signal")
signal load_requested(slot_id: int)
@warning_ignore("unused_signal")
signal clear_requested(slot_id: int)
@warning_ignore("unused_signal")
signal ending_requested(ending_id: String)
@warning_ignore("unused_signal")
signal game_reset_requested