extends CharacterBody2D
class_name Enemy

const KNOCKBACK = 800

var was_hit_in_direction = 0

func hit(direction: int):
	was_hit_in_direction = direction
