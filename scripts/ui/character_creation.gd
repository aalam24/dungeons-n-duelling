extends Control 

var sheet := CharacterSheet.new()
var _nav_buttons: Array[Button] = []
var _nav_group: ButtonGroup

# setup ------------------------------------------------------------------------

func _ready() -> void:
	_nav_buttons = [
	%NameNav, %RaceNav, %ClassNav, %BackgroundNav, %AbilitiesNav, %SpellsNav
]
	_nav_group = _nav_buttons[0].button_group
	for i in _nav_buttons.size():
		_nav_buttons[i].toggled.connect(_on_nav_toggled.bind(i))
	%DetailPanel.visible = false
	
	_populate_grid(%ClassGrid, RulesDB.classes, _on_class_selected)
	_populate_grid(%RaceGrid, RulesDB.races, _on_race_selected)
	_populate_grid(%BackgroundGrid, RulesDB.backgrounds, _on_background_selected)
	
	sheet.changed.connect(_refresh_summary)
	_refresh_summary()

func _populate_grid(grid: GridContainer, defs: Dictionary, handler: Callable) -> void:
	for def in defs.values():
		var button := Button.new()
		button.text = def.display_name
		button.custom_minimum_size = Vector2(90, 90)
		if def.icon:
			button.icon = def.icon
			button.expand_icon = true
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		button.pressed.connect(handler.bind(def))
		grid.add_child(button)

# navigation -------------------------------------------------------------------
	
func _on_nav_toggled(is_on: bool, index: int) -> void:
	if is_on:
		%DetailTabs.current_tab = index
		%DetailPanel.visible = true
	elif _nav_group.get_pressed_button() == null:
		%DetailPanel.visible = false
	
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
	%SelectedRaceIcon.texture = race_def.icon
	%SelectedRaceName.text = race_def.display_name
	%SelectedRaceSubtitle.text = "%s · %d ft speed" % [race_def.size, race_def.speed]
	var text := race_def.description + "\n\n"
	for t in race_def.traits:
		text += "[b]%s[/b]\n%s\n\n" % [t.display_name, t.description]
	%RaceDescription.text = text
	_show_model(race_def.model_scene)
	sheet.emit_changed()
	
func _on_background_selected(bg_def: BackgroundDef) -> void:
	sheet.background = bg_def.id
	%SelectedBackgroundIcon.texture = bg_def.icon
	%SelectedBackgroundName.text = bg_def.display_name
	%BackgroundDescription.text = bg_def.description \
		+ "\n\n[b]Skills:[/b] " + ", ".join(bg_def.skills)
	%BackgroundEquipment.text = ("• " + "\n• ".join(bg_def.starting_equipment)) \
	if not bg_def.starting_equipment.is_empty() else "[i]None[/i]"
	sheet.emit_changed()
	
# derived UI -------------------------------------------------------------------

func _update_spells_availability() -> void:
	var cls: ClassDef = RulesDB.classes.get(sheet.char_class)
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
