extends Node3D

const COMBANTANT_VIEW := preload("res://scenes/battle/combatant_view.tscn")

var grid := BattleGrid.new(40)
var combatants : Array[CombatantState] = []
var _views: Dictionary = {}
var _pending: CreatureStats = null

@onready var _cam: Camera3D = $CameraRig/Camera3D
@onready var _cursor: MeshInstance3D = $CellCursor

func _ready() -> void:
	for team_name in ["Player", "Ally", "Enemy"]:
		%TeamSelect.add_item(team_name)
	for sheet in CharacterStore.load_all():
		_add_spawn_option(sheet)
	for monster in RulesDB.monsters.values():
		_add_spawn_option(monster)
	_set_pending(null)

func _process(_delta: float) -> void:
	_update_cursor()
	
# --- summoning --------------------------------------------------------------------

func _add_spawn_option(stats: CreatureStats) -> void:
	var b := Button.new()
	b.text = stats.get_display_name()
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.pressed.connect(_set_pending.bind(stats))
	%SpawnList.add_child(b)

func _set_pending(stats: CreatureStats) -> void:
	_pending = stats
	if stats == null:
		%StatusLabel.text = "Pick something to summon."
		return
	%TeamSelect.selected = CombatantState.Team.ENEMY if stats is MonsterDef \
		else CombatantState.Team.PLAYER
	%StatusLabel.text = "Placing: %s\nLeft-click to place, right-click to stop." \
		% stats.get_display_name()

func _spawn(stats: CreatureStats, team: int, cell: Vector2i) -> void:
	if _occupant(cell):
		return
	var st := CombatantState.new(stats, team as CombatantState.Team, cell)
	combatants.append(st)
	grid.astar.set_point_solid(cell, true)
	var view: CombatantView = COMBANTANT_VIEW.instantiate()
	%Combatants.add_child(view)
	view.bind(st)
	_views[st] = view

func _occupant(cell: Vector2i) -> CombatantState:
	for c in combatants:
		if c.cell == cell:
			return c
	return null

# --- input --------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	if event.button_index == MOUSE_BUTTON_RIGHT:
		_set_pending(null)
		return
	if event.button_index != MOUSE_BUTTON_LEFT or _pending == null:
		return
	var point = _ground_point(event.position)
	if point == null:
		return
	var cell := BattleGrid.world_to_cell(point)
	if grid.in_bounds(cell):
		_spawn(_pending, %TeamSelect.selected, cell)
		
# --- helpers ------------------------------------------------------------------

func _update_cursor() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_cursor.visible = false
		return
	var point = _ground_point(get_viewport().get_mouse_position())
	if point == null:
		_cursor.visible = false
		return
	var cell := BattleGrid.world_to_cell(point)
	_cursor.visible = grid.in_bounds(cell)
	_cursor.position = BattleGrid.cell_to_world(cell) + Vector3(0.00, 0.01, 0.00)

func _ground_point(screen_pos: Vector2):
	var plane := Plane(Vector3.UP, 0.0)
	return plane.intersects_ray(
		_cam.project_ray_origin(screen_pos),
		_cam.project_ray_normal(screen_pos))
	
