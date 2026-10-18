class_name SpellStyle
extends RefCounted

const SCHOOL_COLORS := {
	SpellDef.School.ABJURATION:    Color("4a90d9"),  # blue
	SpellDef.School.CONJURATION:   Color("e8a33c"),  # amber
	SpellDef.School.DIVINATION:    Color("d8d8e0"),  # silver
	SpellDef.School.ENCHANTMENT:   Color("e05fa8"),  # pink
	SpellDef.School.EVOCATION:     Color("d9453b"),  # red
	SpellDef.School.ILLUSION:      Color("9b6bd6"),  # violet
	SpellDef.School.NECROMANCY:    Color("6fae4a"),  # sickly green
	SpellDef.School.TRANSMUTATION: Color("b07a45"),  # bronze
}

static func color_for(school: int) -> Color:
	return SCHOOL_COLORS.get(school, Color.GRAY)

static func apply(button: Button, school: int) -> void:
	var c:= color_for(school)
	button.add_theme_stylebox_override("normal",        _box(c, Color(0.13, 0.13, 0.13), 2))
	button.add_theme_stylebox_override("hover",         _box(c, Color(0.18, 0.18, 0.18), 2))
	button.add_theme_stylebox_override("pressed",       _box(c, c.darkened(0.65), 4))
	button.add_theme_stylebox_override("hover_pressed", _box(c, c.darkened(0.55), 4))
	button.add_theme_stylebox_override("disabled",      _box(c.darkened(0.6), Color(0.1, 0.1, 0.1), 2))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
static func _box(border: Color, bg: Color, width: int) -> StyleBoxFlat:
	var box:= StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(6)
	return box
