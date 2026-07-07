extends Node
class_name FoodSystem

func spend(amount: int) -> bool:
	if GameState.food < amount:
		return false
	GameState.change_food(-amount)
	return true