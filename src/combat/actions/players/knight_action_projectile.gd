# DefendAction.gd
class_name KnightProjectileAction extends BattlerAction

@export var hit_chance: = 100.0
@export var base_damage: = 30
@export var skill_effect_scene: PackedScene  # Export the scene so you can assign different effects
@export var debuff_defense_percentage: = 0  # Reduces defense by 20%
@export var debuff_duration: = 0  # Number of turns the debuff lasts
@export var buff_attack_percentage: = 0  # Increases attack by 30%
@export var buff_duration: = 0  # Buff duration in turns
func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null
# Override label and description for clarity
func find_pivot(battler: Battler) -> Node2D:
	# Traverse through the children of the battler to find the node that has a 'Pivot'
	for child in battler.get_children():
		if child.has_node("Pivot"):
			return child.get_node("Pivot")
	return null  # Return null if no Pivot is found
# Override the execute method to apply the defense buff
func execute(source: Battler, targets: Array[Battler] = []) -> void:
	print("Executing Defend for", source.name)
	var target: = targets[0]
	await source.get_tree().create_timer(0.1).timeout
	var anim_player = find_animation_player(source)
	if anim_player.has_animation("buff_skill"):
		anim_player.play("buff_skill")
		await anim_player.animation_finished  # Wait for the attack animation to finish
	await source.get_tree().create_timer(0.1).timeout
	# Instantiate the skill effect and position it at the target's pivot
	var target_pivot = find_pivot(target)
	if target_pivot == null:
		print("Error: Pivot not found for target!")
		return
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
	if !targets_self:
		var hit = BattlerHit.new(damage, hit_chance)
		target.take_hit(hit)
	if(debuff_defense_percentage != 0):
		apply_debuff(target, "defense", debuff_defense_percentage, debuff_duration)
	if(buff_attack_percentage != 0):
		apply_buff(source, "attack", buff_attack_percentage, buff_duration)
	await source.get_tree().create_timer(0.1).timeout
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")
	await source.get_tree().create_timer(0.1).timeout
func apply_debuff(target: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "debuff to", target.name, "by", percentage * 100, "% for", turns, "turns")
	var debuff_icon = load("res://icon.svg")
	target.stats.apply_temp_modifier(target.get_child(0),stat, percentage, turns, false, debuff_icon)

func apply_buff(source: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "buff to", source.name, "by", percentage * 100, "% for", turns, "turns")
	var debuff_icon = load("res://icon.svg")
	source.stats.apply_temp_modifier(source.get_child(0),stat, percentage, turns, true,debuff_icon)
func calculate_damage(attack: int, defense: int, base_damage: int) -> int:
	var random_factor = randi_range(0, 10)  # Random factor between 0.9 and 1.1 (10% variation)
	var damage = (abs(attack - defense) + base_damage) + random_factor
	return damage
