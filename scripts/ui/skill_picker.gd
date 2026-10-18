class_name SkillPicker
extends PanelContainer

signal confirmed(skills: Array[String])

const DIM_COLOR := Color(0.55, 0.55, 0.55)
const PICKABLE_COLOR := Color(0.8, 0.72, 0.58)

var _sheet: CharacterSheet
var _staged: Array[String] = []
var _limit := 0
var _need := 0
var _rows: Dictionary = {}

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	%CancelButton.pressed.connect(close)
	%ConfirmSkillsButton.pressed.connect(_on_confirm)
	
func open(sheet: CharacterSheet) -> void:
	var cls: ClassDef = RulesDB.classes.get(sheet.char_class)
	if cls == null:
		return
	_sheet = sheet
	_staged.assign(sheet.chosen_class_skills)
	_limit = cls.skill_choice_count
	_build_rows(cls)
	_refresh()
	visible = true

func close() -> void:
	visible = false

func _build_rows(cls: ClassDef) -> void:
	for child in %Rows.get_children():
		%Rows.remove_child(child)
		child.queue_free()
	_rows.clear()
	
	var granted := _sheet.background_skills()
	var bg: BackgroundDef = RulesDB.backgrounds.get(_sheet.background)
	var pickable_count := 0
	
	for entry in Skills.ALL:
		var skill: String = entry[0]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(24, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if bg and skill in granted:
			icon.texture = bg.icon
			icon.tooltip_text = "Granted by " + bg.display_name
		row.add_child(icon)
		
		var name_label := Label.new()
		name_label.text = skill
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		
		var bonus_label := Label.new()
		bonus_label.custom_minimum_size.x = 40
		bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(bonus_label)
		
		var slot := CenterContainer.new()
		slot.custom_minimum_size = Vector2(28, 28)
		row.add_child(slot)
		
		var box: CheckBox = null
		if skill in cls.skill_choices and skill not in granted:
			box = CheckBox.new()
			box.toggled.connect(_on_toggled.bind(skill))
			slot.add_child(box)
			pickable_count += 1
		
		%Rows.add_child(row)
		_rows[skill] = {"name": name_label, "bonus": bonus_label, "box": box}
		
	_need = mini(_limit, pickable_count)
	
func _refresh() -> void:
	%CountLabel.text = "%d / %d" % [_staged.size(), _limit]
	var granted := _sheet.background_skills()
	var full := _staged.size() >= _limit

	for skill: String in _rows:
		var r: Dictionary = _rows[skill]
		var proficient: bool = skill in granted or skill in _staged
		var bonus: int = _sheet.modifier(Skills.ability_of(skill))
		if proficient:
			bonus += _sheet.prof_bonus()
		r.bonus.text = "%+d" % bonus

		if proficient:
			r.name.modulate = Color.WHITE
		elif r.box:
			r.name.modulate = PICKABLE_COLOR
		else:
			r.name.modulate = DIM_COLOR

		if r.box:
			r.box.set_pressed_no_signal(skill in _staged)
			r.box.disabled = full and skill not in _staged

	%ConfirmSkillsButton.disabled = _staged.size() < _need
	 
func _on_toggled(is_on: bool, skill: String) -> void:
	if is_on and skill not in _staged:
		_staged.append(skill)
	elif not is_on:
		_staged.erase(skill)
	_refresh()
	
func _on_confirm() -> void:
	confirmed.emit(_staged.duplicate())
	close()
	
func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui cancel"):
		close()
		get_viewport().set_input_as_handled()
