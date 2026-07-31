extends Control 

var sheet := CharacterSheet.new()
var _nav_buttons: Array[Button] = []

# setup ------------------------------------------------------------------------

func _ready() -> void:
	_nav_buttons = [
	%NameNav, %RaceNav, %ClassNav, %BackgroundNav, %AbilitiesNav, %SpellsNav
]
	for i in _nav_buttons.size():
		_nav_buttons[i].pressed.connect(_on_nav_pressed.bind(i))
	_populate_classes()
	_populate_races()
	sheet.changed.connect(_refresh_summary)
	_nav_buttons[0].button_pressed = true
	_on_nav_pressed(0)
	_refresh_summary()

func _populate_classes() -> void:
	for class_def in RulesDB.classes.values():
		%ClassGrid.add_child(_make_button(
			class_def.display_name, class_def.icon, 
			_on_class_selected.bind(class_def)))
		
func _populate_races() -> void:
	for race_def in RulesDB.races.values():
		%RaceGrid.add_child(_make_button(
			race_def.display_name, null,
			_on_race_selected.bind(race_def)))
		
func _make_button(text: String, icon: Texture2D, handler: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.icon = icon
	button.custom_minimum_size = Vector2(90, 90)
	button.pressed.connect(handler)
	return button
	
# navigation -------------------------------------------------------------------
	
func _on_nav_pressed(index: int) -> void:
	%DetailTabs.current_tab = index
	
# selection handlers -----------------------------------------------------------
	
func _on_class_selected(class_def: ClassDef) -> void:
	sheet.char_class = class_def.id
	%ClassDescription.text = class_def.description
	%SelectedClassIcon.texture = class_def.icon
	%SelectedClassName.text = class_def.display_name
	_update_spells_availability()
	sheet.emit_changed()

func _on_race_selected(race_def: RaceDef) -> void:
	sheet.race = race_def.id
	%RaceDescription.text = race_def.description
	_show_model(race_def.model_scene)
	sheet.emit_changed()
	
# derived UI -------------------------------------------------------------------

func _update_spells_availability() -> void:
	var cls: ClassDef = RulesDB.clases.get(sheet.char_class)
	%SpellsNav.disabled = cls == null or cls.spellcasting_ability == ""
	
func _refresh_summary() -> void:
	var lines: Array[String] = []
	lines.append("[b]%s[/b]" % (sheet.char_name if sheet.char_name else "Unnamed"))
	lines.append("Level %d %s" % [sheet.level, sheet.char_class.capitalize()])
	lines.append("")
	for key in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]:
		lines.append("%s  %d  (%+d)" % [key, sheet.ability_score(key), sheet.modifier(key)])
	lines.append("")
	lines.append("Proficiency: %+d" % sheet.prof_bonus())
	lines.append("Skills: " + ", ".join(sheet.proficient_skills()))
	%SummaryText.text = "\n".join(lines)
	
func _show_model(scene: PackedScene) -> void:
	for child in %CharacterPreview.get_children():
		child.queue_free()
	if scene:
		%CharacterPreview.add_child(scene.instantiate())
