class_name CameraRig
extends Node3D

@export var move_speed := 12.0
@export var rotate_speed := 90.0     # degrees per second
@export var drag_sensitivity := 0.3
@export var edge_margin := 12        # pixels
@export var zoom_min := 6.0
@export var zoom_max := 30.0
@export var zoom_step := 2.0

@onready var _cam: Camera3D = $Camera3D
var _zoom := 16.0
var _orbiting := false
var _orbit_restore := Vector2.ZERO

func _ready() -> void:
	_apply_zoom()

func _process(delta: float) -> void:
	var input := Input.get_vector("cam_left", "cam_right", "cam_forward", "cam_back")
	input += _edge_pan_vector()
	if input != Vector2.ZERO:
		var dir := transform.basis * Vector3(input.x, 0.0, input.y)
		dir.y = 0.0
		global_position += dir.normalized() * move_speed * delta

	var turn := Input.get_axis("cam_rotate_left", "cam_rotate_right")
	if turn != 0.0:
		rotate_y(deg_to_rad(-turn * rotate_speed * delta))
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			_start_orbit()
		else:
			_end_orbit()
	elif event is InputEventMouseMotion and _orbiting:
		rotate_y(deg_to_rad(-event.relative.x * drag_sensitivity))
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_end_orbit()

func _start_orbit() -> void:
	_orbiting = true
	_orbit_restore = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _end_orbit() -> void:
	if not _orbiting:
		return
	_orbiting = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_viewport().warp_mouse(_orbit_restore)
	


func _edge_pan_vector() -> Vector2:
	if not get_window().has_focus():
		return Vector2.ZERO
	var vp := get_viewport()
	var m := vp.get_mouse_position()
	var size := vp.get_visible_rect().size
	if m.x < 0 or m.y < 0 or m.x > size.x or m.y > size.y:
		return Vector2.ZERO
	var v := Vector2.ZERO
	if m.x < edge_margin:
		v.x -= 1
	elif m.x > size.x - edge_margin:
		v.x += 1
	if m.y < edge_margin:
		v.y -= 1
	elif m.y > size.y - edge_margin:
		v.y += 1
	return v

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom = maxf(zoom_min, _zoom - zoom_step)
			_apply_zoom()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom = minf(zoom_max, _zoom + zoom_step)
			_apply_zoom()

func _apply_zoom() -> void:
	_cam.position = Vector3(0.0, _zoom * 0.8, _zoom * 0.6)
	_cam.look_at(global_position, Vector3.UP)
