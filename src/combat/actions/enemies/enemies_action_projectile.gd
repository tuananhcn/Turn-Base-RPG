# A sample [BattlerAction] implementation that simulates a ranged attack, such as a fireball.
class_name RangedEnemyAction extends BattlerAction

@export var attack_distance: = 350.0
@export var attack_time: = 0.25
@export var return_time: = 0.25
## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var hit_chance: = 100.0
@export var base_damage: = 30
@export var skill_effect_scene: PackedScene  # Export the scene so you can assign different effects
@export var debuff_defense_percentage: float = 0  # Reduces defense by 20%
@export var buff_attack_percentage: float = 0  # Increases attack by 30%
@export var debuff_duration: = 0  # Number of turns the debuff lasts
@export var buff_duration: = 0  # Buff duration in turns
@export var skill_effect_scale: Vector2 = Vector2(4, 4)  # Default scale value
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
	var target: = targets[0]

	await source.get_tree().create_timer(0.1).timeout
	var anim_player = find_animation_player(source)
	# Calculate where the acting Battler will move from and to.
	var origin: = source.position
	var attack_direction: float = sign(target.position.x - source.position.x)
	var destination: = origin + Vector2(attack_distance*attack_direction, 0)
	# No attack animations yet, so wait for a short delay and then apply damage to the target.
	# Normally we would wait for an attack animation's "triggered" signal and then spawn a
	# projectile, waiting for impact.
	if anim_player.has_animation("attack2"):
		anim_player.play("attack2")
		await anim_player.animation_finished  # Wait for the attack animation to finish
	await source.get_tree().create_timer(0.1).timeout
	var target_pivot = find_pivot(target)
	if target_pivot == null:
		print("Error: Pivot not found for target!")
		return
	if skill_effect_scene:
		var skill_effect_instance = skill_effect_scene.instantiate()
		skill_effect_instance.z_index = 10  # Make sure it's on top
		skill_effect_instance.scale = skill_effect_scale  # Temporarily scale up to make it more visible
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
	await source.get_tree().create_timer(0.4).timeout
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")
	await source.get_tree().create_timer(0.1).timeout
func calculate_damage(attack: int, defense: int, base_damage: int) -> int:
	var random_factor = randi_range(0, 10)  # Random factor between 0.9 and 1.1 (10% variation)
	var damage
	if base_damage >= 0:
		damage = (abs(attack - defense) + base_damage) + random_factor
	else:
		damage = (-attack + base_damage) + random_factor
	return damage
func apply_debuff(target: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "debuff to", target.name, "by", percentage * 100, "% for", turns, "turns")
	var debuff_icon
	if stat == "attack":
		debuff_icon = load("res://assets/battlers/ParticleSkill/SkillIcon/debuff.png")
	else:
		debuff_icon = load("res://assets/battlers/ParticleSkill/SkillIcon/shield_debuff.png")
	if target.stats.health >=0:
		target.stats.apply_temp_modifier(target.get_child(0),stat, percentage, turns, false, debuff_icon)

# Apply a buff to the source
func apply_buff(source: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "buff to", source.name, "by", percentage * 100, "% for", turns, "turns")
	var buff_icon
	if stat == "attack":
		buff_icon = load("res://assets/battlers/ParticleSkill/SkillIcon/buff.png")
	else:
		buff_icon = load("res://assets/battlers/ParticleSkill/SkillIcon/shield.png")
	if source.stats.health >=0:
		source.stats.apply_temp_modifier(source.get_child(0),stat, percentage, turns, true,buff_icon)
