class_name AbilityRow
extends HBoxContainer

signal raise_pressed(key: String)
signal lower_pressed(key: String)
signal major_picked(key: String, is_on: bool)
signal minor_picked(key: String, is_on: bool)

var key := ""

@onready var _minus: Button = $MinusButton
@onready var _plus: Button = $PlusButton
@onready var _major: Button = $MajorButton
@onready var _minor: Button = $MinorButton
@onready var _label: Label = $AbilityLabel
@onready var _total: Label = $TotalLabel
@onready var _mod: Label = $ModLabel

func _ready() -> void:
	_minus.pressed.connect(func(): lower_pressed.emit(key))
	_plus.pressed.connect(func(): raise_pressed.emit(key))
	_major.toggled.connect(func(on): major_picked.emit(key, on))
	_minor.toggled.connect(func(on): minor_picked.emit(key, on))
	_label.text = key
	var path := "res://ui/icons/abilities/%s_icon.png" % key.to_lower()
	if ResourceLoader.exists(path):
		$AbilityIcon.texture = load(path)
	
func refresh(total: int, mod: int, can_raise: bool, can_lower: bool) -> void:
	_total.text = str(total)
	_mod.text = "(%+d)" % mod
	_plus.disabled = not can_raise
	_minus.disabled = not can_lower
	
func set_asi(is_major: bool, is_minor: bool) -> void:
	_major.set_pressed_no_signal(is_major)
	_minor.set_pressed_no_signal(is_minor)
	_minor.disabled = is_major
	_major.disabled = is_minor
