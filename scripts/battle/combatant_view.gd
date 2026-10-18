class_name CombatantView
extends Node3D

const TEAM_COLORS := {
	CombatantState.Team.PLAYER: Color("3a8ee6"),
	CombatantState.Team.ALLY:   Color("4cbf6a"),
	CombatantState.Team.ENEMY:  Color("d9453b"),
}

var state: CombatantState

func bind(p_state: CombatantState) -> void:
	state = p_state
	position = BattleGrid.cell_to_world(state.cell)
	$NameLabel.text = state.stats.get_display_name()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = TEAM_COLORS[state.team]
	$Body.material_override = mat
	
func set_selected(on: bool) -> void:
	$SelectionRing.visible = on
