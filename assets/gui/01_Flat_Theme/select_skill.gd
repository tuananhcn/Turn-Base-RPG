extends Control
@onready var select_skill_option = get_node("../SelectSkillOption")
@onready var select_tactics = get_node("../Tactics")
@onready var select_items = get_node("../Item")
@onready var audiostream = $AudioStreamPlayer
func _ready():
	# Connecting signals in Godot 4
	$NinePatchRect/VBoxContainer/AttackButton.pressed.connect(_on_attack_pressed)
	$NinePatchRect/VBoxContainer/SkillButton.pressed.connect(_on_skill_pressed)
	$NinePatchRect/VBoxContainer/SummonButton.pressed.connect(_on_summon_pressed)
	$NinePatchRect/VBoxContainer/ItemButton.pressed.connect(_on_item_pressed)

func _on_attack_pressed():
	if audiostream:
		audiostream.play()
	var active_turn_queue = get_node("../Battlers")
	select_skill_option.hide()
	select_tactics.hide()
	select_items.hide()
	active_turn_queue.emit_signal("target_selected", [] as Array[Battler])
	active_turn_queue.hide_all_indicators()
	var attack_index = 0  # Assuming the basic attack is at index 0
	
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
	if audiostream:
		audiostream.play()
	var active_turn_queue = get_node("../Battlers")
	active_turn_queue.emit_signal("target_selected", [] as Array[Battler])
	active_turn_queue.hide_all_indicators()
	select_tactics.hide()
	select_items.hide()
	select_skill_option.show()
	select_skill_option.show_skills_for_battler(active_turn_queue.current_battler)
func _on_summon_pressed():
	if audiostream:
		audiostream.play()
	var active_turn_queue = get_node("../Battlers")
	active_turn_queue.emit_signal("target_selected", [] as Array[Battler])
	active_turn_queue.hide_all_indicators()
	select_skill_option.hide()
	select_items.hide()
	select_tactics.show()
	# Handle summon logic here

func _on_item_pressed():
	if audiostream:
		audiostream.play()
	var active_turn_queue = get_node("../Battlers")
	active_turn_queue.emit_signal("target_selected", [] as Array[Battler])
	active_turn_queue.hide_all_indicators()
	select_skill_option.hide()
	select_tactics.hide()
	select_items.show()
	select_items.show_items()
	# Handle item logic here
