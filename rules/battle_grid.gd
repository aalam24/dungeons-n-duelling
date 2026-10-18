class_name BattleGrid
extends RefCounted

const CELL_SIZE := 1.5        # meters per 5-ft square
const FEET_PER_CELL := 5

var astar := AStarGrid2D.new()

func _init(cells_across: int = 40) -> void:
	@warning_ignore("integer_division")
	var half := cells_across / 2
	astar.region = Rect2i(-half, -half, cells_across, cells_across)
	astar.cell_size = Vector2.ONE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	astar.update()

static func world_to_cell(p: Vector3) -> Vector2i:
	return Vector2i(floori(p.x / CELL_SIZE), floori(p.z / CELL_SIZE))

static func cell_to_world(c: Vector2i) -> Vector3:
	return Vector3((c.x + 0.5) * CELL_SIZE, 0.0, (c.y + 0.5) * CELL_SIZE)

func in_bounds(c: Vector2i) -> bool:
	return astar.is_in_boundsv(c)

func find_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	out.assign(astar.get_id_path(from, to))
	return out

static func path_cost_ft(path: Array[Vector2i]) -> int:
	return maxi(0, path.size() - 1) * FEET_PER_CELL
