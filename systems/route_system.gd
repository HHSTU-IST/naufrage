extends Node
class_name RouteSystem

var _cdb: Variant
var _eb: Variant

func _ready() -> void:
	_cdb = get_node_or_null("/root/ConfigDB")
	_eb = get_node_or_null("/root/EventBus")

func move_forward() -> void:
	GameState.set_route_distance(GameState.route_distance + 1)

func move_back() -> void:
	GameState.set_route_distance(max(GameState.route_distance - 1, 0))

func reached_end() -> bool:
	var limit: int = _get_route_limit()
	return GameState.route_distance >= limit

func _get_route_limit() -> int:
	if _cdb != null and _cdb.has_route(GameState.current_route):
		var route_data: RouteData = _cdb.get_route(GameState.current_route) as RouteData
		if route_data != null:
			return route_data.days_total
	return 999

## 当前路线走完后，尝试切换到下一条路线
func try_advance_route() -> void:
	if not reached_end():
		return
	var routes := ["west", "north", "east"]
	var idx := routes.find(GameState.current_route)
	if idx < 0 or idx >= routes.size() - 1:
		return  # 已经是最后一条路线
	var next_route := routes[idx + 1]
	# 只有当对应 NPC 已被救援（state >= 1）时才能切换
	var route_npc_map := {"west": "fisher_west", "north": "fisher_north", "east": "fisher_east"}
	var required_npc := route_npc_map.get(next_route, "")
	if required_npc.is_empty():
		return
	if GameState.get_npc_state(required_npc, 0) >= 1:
		GameState.set_route(next_route)
		GameState.set_route_distance(0)
		if _eb != null:
			_eb.dialogue_displayed.emit("（系统）", "你发现了一条新路线: %s" % next_route, false)