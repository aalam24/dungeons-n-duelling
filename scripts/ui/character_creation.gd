extends Control 

var sheet := CharacterSheet.new()
var _nav_buttons: Array[Button] = []
var _nav_group: ButtonGroup

const ABILITY_ROW := preload("res://scenes/ui/ability_row.tscn")
const ABILITY_KEYS := ["STR", "DEX", "CON", "INT", "WIS", "CHA"]
var _rows: Dictionary = {}

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
	
	_setup_name_tab()
	_setup_abilities_tab()
	
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

func _setup_name_tab() -> void:
	%NameEdit.text_changed.connect(func(t):
		sheet.char_name = t
		sheet.emit_changed())
		
func _setup_abilities_tab() -> void:
	for key in ABILITY_KEYS:
		var row: AbilityRow = ABILITY_ROW.instantiate()
		row.key = key
		%AbilityRows.add_child(row)
		_rows[key] = row
		row.raise_pressed.connect(_on_ability_raise)
		row.lower_pressed.connect(_on_ability_lower)
		row.major_picked.connect(_on_major_picked)
		row.minor_picked.connect(_on_minor_picked)
	_refresh_abilities()
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
	%ClassFeatures.text = _build_class_features(class_def)
	_update_spells_availability()
	sheet.emit_changed()

func _build_class_features(class_def: ClassDef) -> String:
	var out := "[b]Hit Die:[/b] d%d\n" % class_def.hit_die
	out += "[b]Saving Throws:[/b] %s\n" % ", ".join(class_def.saving_throws)
	out += "[b]Skills:[/b] choose %d from %s\n\n" % [
		class_def.skill_choice_count, ", ".join(class_def.skill_choices)]
	for f in class_def.level_1_features:
		out += "[b]%s[/b]\n%s\n\n" % [f.display_name, f.description]
	return out

func _on_race_selected(race_def: RaceDef) -> void:
	sheet.race = race_def.id
	%SelectedRaceIcon.texture = race_def.icon
	%SelectedRaceName.text = race_def.display_name
	%SelectedRaceSubtitle.text = "%s · %d ft speed" % [race_def.size, race_def.speed]
	%RaceDescription.text = race_def.description
	var traits_text := ""
	for t in race_def.traits:
		traits_text += "[b]%s[/b]\n%s\n\n" % [t.display_name, t.description]	
	%RaceFeatures.text = traits_text
	_show_model(race_def.model_scene)
	sheet.emit_changed()
	
func _on_background_selected(bg_def: BackgroundDef) -> void:
	sheet.background = bg_def.id
	%SelectedBackgroundIcon.texture = bg_def.icon
	%SelectedBackgroundName.text = bg_def.display_name
	%BackgroundDescription.text = bg_def.description
	var prof := "[b]Skills:[/b] %s" % ", ".join(bg_def.skills)
	if not bg_def.tool_prof.is_empty():
		prof += "\n[b]Tools:[/b] %s" % ", ".join(bg_def.tool_prof)
	%BackgroundSkills.text = prof
	%BackgroundEquipment.text = ("• " + "\n• ".join(bg_def.starting_equipment)) \
		if not bg_def.starting_equipment.is_empty() else "[i]None[/i]"
	sheet.emit_changed()
# derived UI -------------------------------------------------------------------

func _update_spells_availability() -> void:
	var cls: ClassDef = RulesDB.classes.get(sheet.char_class)
	%SpellsNav.disabled = cls == null or cls.spellcasting_ability == ""
	
func _refresh_summary() -> void:
	_refresh_abilities()
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

# Ability scores section -------------------------------------------------------

func _on_ability_raise(key: String) -> void:
	if PointBuy.can_raise(sheet.base_abilities, key):
		sheet.base_abilities[key] += 1
		sheet.emit_changed()

func _on_ability_lower(key: String) -> void:
	if PointBuy.can_lower(sheet.base_abilities, key):
		sheet.base_abilities[key] -= 1
		sheet.emit_changed()

func _on_major_picked(key: String, is_on: bool) -> void:
	sheet.asi_major = key if is_on else ""
	sheet.emit_changed()

func _on_minor_picked(key: String, is_on: bool) -> void:
	sheet.asi_minor = key if is_on else ""
	sheet.emit_changed()

func _refresh_abilities() -> void:
	print("base_abilities = ", sheet.base_abilities)
	var spent := PointBuy.total_spent(sheet.base_abilities)
	%PointsLabel.text = "Points: %d / %d" % [spent, PointBuy.BUDGET]
	for key in ABILITY_KEYS:
		var row: AbilityRow = _rows[key]
		row.refresh(
			sheet.ability_score(key),
			sheet.modifier(key),
			PointBuy.can_raise(sheet.base_abilities, key),
			PointBuy.can_lower(sheet.base_abilities, key))
		row.set_asi(sheet.asi_major == key, sheet.asi_minor == key)
