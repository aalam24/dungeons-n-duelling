extends Control 

var sheet := CharacterSheet.new()
var _nav_buttons: Array[Button] = []
var _nav_group: ButtonGroup

const ABILITY_ROW := preload("res://scenes/ui/ability_row.tscn")
const ABILITY_KEYS := ["STR", "DEX", "CON", "INT", "WIS", "CHA"]
const PLACEHOLDER_BODY := preload("res://scenes/characters/placeholder_body.tscn")

var _rows: Dictionary = {}
var _spell_buttons: Dictionary = {}


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

	%ConfirmButton.pressed.connect(_on_confirm_pressed)
	_show_model(null)
	
	%SkillPicker.confirmed.connect(_on_skills_confirmed)
	%ChooseSkillsButton.pressed.connect(func(): %SkillPicker.open(sheet))
	
	sheet.changed.connect(_refresh_summary)
	_refresh_summary()

func _populate_grid(grid: GridContainer, defs: Dictionary, handler: Callable) -> void:
	for def in defs.values():
		var button:= _make_tile(def.display_name, def.icon)
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

func _make_tile(text: String, icon: Texture2D) -> Button:
	var button:= Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(90, 90)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if icon:
		button.icon = icon
		button.expand_icon = false
		button.add_theme_constant_override("icon_max_width", 48)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	return button
	
# navigation -------------------------------------------------------------------
	
func _on_nav_toggled(is_on: bool, index: int) -> void:
	%SkillPicker.close()
	if is_on:
		%DetailTabs.current_tab = index
		%DetailPanel.visible = true
	elif _nav_group.get_pressed_button() == null:
		%DetailPanel.visible = false
		
func _on_confirm_pressed() -> void:
	if not sheet.is_complete():
		return
	if sheet.char_class == "" or sheet.race == "" or sheet.background == "":
		push_warning("Character incomplete")
		return
	var err := CharacterStore.save(sheet)
	if err != OK:
		push_error("Save failed (error %d)" % err)
		return
	SceneManager.goto("load_character")
	
func _on_skills_confirmed(skills: Array[String]) -> void:
	sheet.chosen_class_skills.assign(skills)
	sheet.emit_changed()
	
# selection handlers -----------------------------------------------------------
	
func _on_class_selected(class_def: ClassDef) -> void:
	sheet.char_class = class_def.id
	%ClassDescription.text = class_def.description
	%SelectedClassIcon.texture = class_def.icon
	%SelectedClassName.text = class_def.display_name
	%ClassFeatures.text = _build_class_features(class_def)
	_update_spells_availability()
	if sheet.char_class != class_def.id:
		sheet.known_cantrips.clear()
		sheet.known_spells.clear()
		sheet.chosen_class_skills.clear()
	sheet.char_class = class_def.id
	_populate_spells()
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
	for s in bg_def.skills:
		sheet.chosen_class_skills.erase(s)
		
	sheet.emit_changed()
	
# derived UI -------------------------------------------------------------------

func _update_spells_availability() -> void:
	var cls: ClassDef = RulesDB.classes.get(sheet.char_class)
	%SpellsNav.disabled = cls == null or cls.spellcasting_ability == ""
	
func _refresh_summary() -> void:
	_refresh_abilities()
	_refresh_spells()
	var lines: Array[String] = []
	lines.append("[b]%s[/b]" % (sheet.char_name if sheet.char_name else "Unnamed"))
	lines.append("Level %d %s" % [sheet.level, sheet.char_class.capitalize()])
	lines.append("")
	var table := "[table=3]"
	for key in ["STR", "DEX", "CON", "INT", "WIS", "CHA"]:
		table += "[cell]%s[/cell][cell]%d[/cell][cell](%+d)[/cell]" % [
			key, sheet.ability_score(key), sheet.modifier(key)]
	table += "[/table]"
	lines.append(table)
	lines.append("")
	lines.append("Proficiency: %+d" % sheet.prof_bonus())
	lines.append("Skills: " + ", ".join(sheet.proficient_skills()))
	
	var armor:= Prof.armor_names(sheet.armor_profs())
	var weapons:= Prof.weapon_names(sheet.weapon_categories())
	weapons.append_array(sheet.specific_weapons())
	lines.append("Armor: " + (", ".join(armor) if not armor.is_empty() else "None"))
	lines.append("Weapons: " + (", ".join(weapons) if not weapons.is_empty() else "None"))
	
	var hp: int = sheet.max_hp()
	lines.append("Max HP: %s" % (str(hp) if hp > 0 else "-"))
	lines.append("Initiative: %+d" % sheet.initiative_bonus())
	
	%SummaryText.text = "\n".join(lines)
	
	var errors: Array[String] = sheet.validation_errors()
	%ConfirmButton.disabled = not errors.is_empty()
	%ValidationLabel.text = "\n".join(errors)
	%ValidationLabel.visible = not errors.is_empty()
	
	%ChooseSkillsButton.disabled = sheet.char_class == ""
	var skills := sheet.proficient_skills()
	%SkillSummaryLabel.text = "Proficient: " + (", ".join(skills) if not skills.is_empty() else "none yet")
	
func _show_model(scene: PackedScene) -> void:
	for child in %CharacterPreview.get_children():
		%CharacterPreview.remove_child(child)
		child.queue_free()
	var body:= (scene if scene else PLACEHOLDER_BODY).instantiate() 
	%CharacterPreview.add_child(body)
	
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

# Spells section ---------------------------------------------------------------

func _populate_spells() -> void:
	for grid in [%CantripGrid, %SpellGrid]:
		for child in grid.get_children():
			grid.remove_child(child)
			child.queue_free()
	_spell_buttons.clear()
	
	var cls: ClassDef = RulesDB.classes.get(sheet.char_class)
	if cls == null:
		return
	for spell in cls.spell_list:
		if spell == null or spell.level > 1:
			continue
		var button := _make_tile(spell.display_name, spell.icon)
		button.toggle_mode = true
		SpellStyle.apply(button, spell.school)
		button.toggled.connect(_on_spell_toggled.bind(spell))
		button.mouse_entered.connect(_show_spell_details.bind(spell))
		(%CantripGrid if spell.level == 0 else %SpellGrid).add_child(button)
		_spell_buttons[spell.id] = {"button": button, "spell": spell}
	_refresh_spells()
		
func _on_spell_toggled(is_on: bool, spell: SpellDef) -> void:
	var list: Array[String] = sheet.known_cantrips if spell.level == 0 else sheet.known_spells
	if is_on and spell.id not in list:
		list.append(spell.id)
	elif not is_on:
		list.erase(spell.id)
	_show_spell_details(spell)
	sheet.emit_changed()
	
func _refresh_spells() -> void:
	var cls: ClassDef = RulesDB.classes.get(sheet.char_class)
	if cls == null or _spell_buttons.is_empty():
		return
	%CantripCountLabel.text = "Cantrips %d / %d" % [sheet.known_cantrips.size(), cls.cantrips_known_at_1]
	%SpellCountLabel.text = "1st Level Spells %d / %d" % [sheet.known_spells.size(), cls.spells_known_at_1]
	
	var cantrips_full := sheet.known_cantrips.size() >= cls.cantrips_known_at_1
	var spells_full := sheet.known_spells.size() >= cls.spells_known_at_1
	for id in _spell_buttons:
		var entry: Dictionary = _spell_buttons[id]
		var button: Button = entry.button
		var spell: SpellDef = entry.spell
		var chosen: bool = id in sheet.known_cantrips or id in sheet.known_spells
		button.set_pressed_no_signal(chosen)
		var full := cantrips_full if spell.level == 0 else spells_full
		button.disabled = full and not chosen 
	
func _show_spell_details(spell: SpellDef) -> void:
	%SelectedSpellIcon.texture = spell.icon
	%SelectedSpellName.text = spell.display_name
	var school: String = SpellDef.School.keys()[spell.school].capitalize()
	%SelectedSpellSubtitle.text = ("%s cantrips" % school) if spell.level == 0 \
	else ("Level %d %s" % [spell.level, school])
	%SelectedSpellSubtitle.add_theme_color_override("font_color", SpellStyle.color_for(spell.school))
	
	var range_text := "Self" if spell.range_ft == 0 else "%d ft" % spell.range_ft
	if spell.area_size_ft > 0: 
		var shape: String = SpellDef.TargetMode.keys()[spell.target_mode].to_lower()
		range_text += " (%d-ft %s)" % [spell.area_size_ft, shape]
	
	var stats := "[b]Casting Time:[/b] %s\n[b]Range:[/b] %s\n[b]Duration:[/b] %s" % [
		spell.casting_time, range_text, spell.duration]
	if spell.concentration: 
		stats += " (concentration)"
	if spell.attack_roll:
		stats += "\n[b]Attack:[/b] ranged spell attack"
	elif spell.save_ability != "":
		stats += "\n[b]Save:[/b] %s" % spell.save_ability
	if spell.damage_dice != "":
		stats += "\n[b]Damage: [/b] %s %s" % [spell.damage_dice, spell.damage_type]
	%SpellStatBlock.text = stats
	%SpellDescription.text = spell.description
	
