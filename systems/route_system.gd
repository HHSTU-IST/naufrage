extends Node
class_name RouteSystem

const ROUTE_LIMITS := {
	"west": 5,
	"north": 8,
	"east": 14,
}

func move_forward() -> void:
	GameState.set_route_distance(GameState.route_distance + 1)

func move_back() -> void:
	GameState.set_route_distance(max(GameState.route_distance - 1, 0))

func reached_end() -> bool:
	return GameState.route_distance >= int(ROUTE_LIMITS.get(GameState.current_route, 999))