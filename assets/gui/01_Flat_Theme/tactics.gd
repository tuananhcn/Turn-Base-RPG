extends Control
@onready var grid_container = $NinePatchRect/GridContainer
@onready var custom_theme = preload("res://src/gui/mainmenu/new_theme.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func _on_defend_pressed() -> void:
	hide()
	var active_turn_queue = get_node("../Battlers")
	var current_battler = active_turn_queue.current_battler
	print(current_battler)
	active_turn_queue.emit_signal("skill_selected", 1)
	await current_battler.get_tree().create_timer(1).timeout
	active_turn_queue.emit_signal("target_selected", [current_battler] as Array[Battler])
func _on_escape_pressed() -> void:
	var active_turn_queue = get_node("../Battlers")
	active_turn_queue.combat_finished.emit(false)  # Player lost the combat
	hide()
func apply_buff(source: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "buff to", source.name, "by", percentage * 100, "% for", turns, "turns")
	var buff_icon = load("res://icon.svg")
	source.stats.apply_temp_modifier(source.get_child(0),stat, percentage, turns, true,buff_icon)
