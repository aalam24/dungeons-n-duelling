class_name PointBuy
extends RefCounted

const MIN_SCORE := 8
const MAX_SCORE := 15
const BUDGET := 27

const COST := {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9}

static func cost_of(score: int) -> int:
	return COST.get(score, 0)

static func total_spent(scores: Dictionary) -> int:
	var sum := 0
	for v in scores.values():
		sum += cost_of(v)
	return sum

static func can_raise(scores: Dictionary, key: String) -> bool:
	var current: int = scores[key]
	if current >= MAX_SCORE:
		return false
	var delta := cost_of(current + 1) - cost_of(current)
	return total_spent(scores) + delta <= BUDGET

static func can_lower(scores: Dictionary, key: String) -> bool:
	return scores[key] > MIN_SCORE
