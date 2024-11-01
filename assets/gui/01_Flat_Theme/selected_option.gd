extends Control
@onready var grid_container = $NinePatchRect/GridContainer
@onready var custom_theme = preload("res://src/gui/mainmenu/new_theme.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_container.columns = 3  # Đặt số cột thành 3
	pass # Replace with function body.
func show_skills_for_battler(battler: Battler):
	# Xóa các nút kỹ năng cũ
	for child in grid_container.get_children():
		child.queue_free()

	# Tạo các nút kỹ năng cho từng kỹ năng của nhân vật
	for skill_index in range(2,battler.actions.size()):
		var skill = battler.actions[skill_index]
		var skill_button = Button.new()
		skill_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		skill_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		skill_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())

		skill_button.icon = skill.icon
		# Pass both the skill and its index to the _on_skill_selected function
		skill_button.connect("pressed", Callable(self, "_on_skill_selected").bind(skill, skill_index))
		grid_container.add_child(skill_button)
func _on_skill_selected(skill: BattlerAction, attack_index):
	print("Selected skill: ", skill.label)
	var active_turn_queue = get_node("../Battlers")
	var current_battler = active_turn_queue.current_battler
	var action: BattlerAction = current_battler.actions[attack_index]
	var potential_targets: Array[Battler] = []
	var potential_allies: Array[Battler] = []
	var opponents:Array[Battler] = active_turn_queue._enemies if current_battler.is_player else active_turn_queue._party_members
	var allies:Array[Battler] = active_turn_queue._party_members if current_battler.is_player else active_turn_queue._enemies
	for opponent: Battler in opponents:
		if opponent.is_selectable:
			potential_targets.append(opponent)
	for ally in allies:
		if ally.is_selectable:
			potential_allies.append(ally)
	var target_group = potential_allies if action.targets_self else potential_targets
	for battler in active_turn_queue.indicators.keys():
		# Show indicators for potential targets only (assuming attack targets enemies)
		active_turn_queue.indicators[battler].visible = battler in target_group
	active_turn_queue.emit_signal("skill_selected", attack_index)
	hide()
