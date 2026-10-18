class_name CombatantState
extends RefCounted

enum Team {PLAYER, ALLY, ENEMY}

var stats: CreatureStats
var team: Team
var current_hp: int
var cell: Vector2i
var movement_left_ft: int
var initiative: int = 0

func _init(p_stats: CreatureStats, p_team: Team, p_cell: Vector2i) -> void:
	stats = p_stats
	team = p_team
	cell = p_cell
	current_hp = stats.max_hp()
	movement_left_ft = stats.speed_ft()
	
func is_alive() -> bool:
	return current_hp > 0
