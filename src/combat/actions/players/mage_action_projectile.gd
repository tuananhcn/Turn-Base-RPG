class_name RangedMageActionNoMoving extends BattlerAction

@export var attack_distance: = 350.0
@export var attack_time: = 0.25
@export var return_time: = 0.25
@export var hit_chance: = 100.0
@export var base_damage: = 30
@export var skill_effect_scene: PackedScene  # Export the scene so you can assign different effects
@export var debuff_defense_percentage: = 0  # Reduces defense by 20%
@export var debuff_duration: = 2  # Number of turns the debuff lasts
@export var buff_attack_percentage: = 0  # Increases attack by 30%
@export var buff_duration: = 2  # Buff duration in turns
func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null
func find_pivot(battler: Battler) -> Node2D:
	# Traverse through the children of the battler to find the node that has a 'Pivot'
	for child in battler.get_children():
		if child.has_node("Pivot"):
			return child.get_node("Pivot")
	return null  # Return null if no Pivot is found
func execute(source: Battler, targets: Array[Battler] = []) -> void:
	assert(not targets.is_empty(), "A ranged attack action requires a target.")
	var target = targets[0]
	await source.get_tree().create_timer(0.1).timeout
	var anim_player = find_animation_player(source)

	# Calculate the movement for the Battler
	var origin = source.position
	var attack_direction = sign(target.position.x - source.position.x)
	var destination = origin + Vector2(attack_distance * attack_direction, 0)

	# Move the attacker to the attack position
	var tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(source, "position", destination, attack_time)
	await tween.finished

	# Play attack animation if available
	randomize()
	var attack_anim = "attack%d" % randi_range(1, 2)
	if anim_player.has_animation(attack_anim ):
		anim_player.play(attack_anim)
		await anim_player.animation_finished  # Wait for the attack animation to finish

	await source.get_tree().create_timer(0.1).timeout
	var target_pivot = find_pivot(target)
	if target_pivot == null:
		print("Error: Pivot not found for target!")
		return

	# Instantiate the skill effect and position it at the target's pivot
	if skill_effect_scene:
		var skill_effect_instance = skill_effect_scene.instantiate()
		skill_effect_instance.z_index = 10  # Make sure it's on top
		skill_effect_instance.scale = Vector2(8, 8)  # Temporarily scale up to make it more visible
		skill_effect_instance.position = target_pivot.global_position  # Use the pivot's global position
		source.get_parent().add_child(skill_effect_instance)  # Add to the same parent of source
		await source.get_tree().create_timer(1).timeout
		# Destroy the effect after the tween finishes
		skill_effect_instance.queue_free()
	
	# Apply the hit/damage
	var attack_power = source.stats.attack  # Get the source's base attack
	var defense_power = target.stats.defense  # Get the target's defense
	var damage = calculate_damage(attack_power, defense_power, base_damage)
	var hit = BattlerHit.new(damage, hit_chance)
	target.take_hit(hit)
	if(debuff_defense_percentage != 0):
		apply_debuff(target, "defense", debuff_defense_percentage, debuff_duration)
	if(buff_attack_percentage != 0):
		apply_buff(source, "attack", buff_attack_percentage, buff_duration)
	await source.get_tree().create_timer(0.1).timeout
	# Move back to the original position
	tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", origin, return_time)
	await tween.finished
	# Return to idle animation if applicable
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")
	await source.get_tree().create_timer(0.1).timeout
func calculate_damage(attack: int, defense: int, base_damage: int) -> int:
	var random_factor = randi_range(0, 10)  # Random factor between 0.9 and 1.1 (10% variation)
	var damage = (abs(attack - defense) + base_damage) + random_factor
	return damage
func apply_debuff(target: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "debuff to", target.name, "by", percentage * 100, "% for", turns, "turns")
	var debuff_icon = load("res://icon.svg")
	target.stats.apply_temp_modifier(target.get_child(0),stat, percentage, turns, false, debuff_icon)

# Apply a buff to the source
func apply_buff(source: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "buff to", source.name, "by", percentage * 100, "% for", turns, "turns")
	var debuff_icon = load("res://icon.svg")
	source.stats.apply_temp_modifier(source.get_child(0),stat, percentage, turns, true,debuff_icon)
