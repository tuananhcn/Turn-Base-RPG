extends Control
@onready var select_skill_option = get_node("../SelectSkillOption")
func _ready():
	# Connecting signals in Godot 4
	$NinePatchRect/VBoxContainer/AttackButton.pressed.connect(_on_attack_pressed)
	$NinePatchRect/VBoxContainer/SkillButton.pressed.connect(_on_skill_pressed)
	$NinePatchRect/VBoxContainer/SummonButton.pressed.connect(_on_summon_pressed)
	$NinePatchRect/VBoxContainer/ItemButton.pressed.connect(_on_item_pressed)

func _on_attack_pressed():
	select_skill_option.hide()
	var attack_index = 0  # Assuming the basic attack is at index 0
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
func _on_skill_pressed():
	print("Skill Pressed")
	var active_turn_queue = get_node("../Battlers")
	active_turn_queue.hide_all_indicators()
	select_skill_option.show()
	select_skill_option.show_skills_for_battler(active_turn_queue.current_battler)
func _on_summon_pressed():
	print("Summon Pressed")
	# Handle summon logic here

func _on_item_pressed():
	print("Item Pressed")
	# Handle item logic here
