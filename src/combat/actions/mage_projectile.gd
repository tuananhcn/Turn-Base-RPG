class_name RangedBattlerAction extends BattlerAction

@export var attack_distance: = 350.0
@export var attack_time: = 0.25
@export var return_time: = 0.25
@export var hit_chance: = 100.0
@export var base_damage: = 100
@export var skill_effect_scene: PackedScene  # Export the scene so you can assign different effects

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
	if anim_player.has_animation("attack1"):
		anim_player.play("attack1")
		await anim_player.animation_finished  # Wait for the attack animation to finish

	await source.get_tree().create_timer(0.1).timeout
	var target_pivot = find_pivot(target)
	if target_pivot == null:
		print("Error: Pivot not found for target!")
		return

	# Instantiate the skill effect and position it at the target's pivot
	var skill_effect_instance = skill_effect_scene.instantiate()
	skill_effect_instance.z_index = 10  # Make sure it's on top
	skill_effect_instance.scale = Vector2(4, 4)  # Temporarily scale up to make it more visible
	#var particles = skill_effect_instance.get_node("AnimatedSprite2D")  # If the scene has Particles2D
	#if particles:
		#particles.emitting = true
	skill_effect_instance.position = target_pivot.global_position  # Use the pivot's global position
	source.get_parent().add_child(skill_effect_instance)  # Add to the same parent of source
	await source.get_tree().create_timer(1).timeout
	# Destroy the effect after the tween finishes
	skill_effect_instance.queue_free()
	# Apply the hit/damage
	var hit = BattlerHit.new(base_damage, hit_chance)
	target.take_hit(hit)

	await source.get_tree().create_timer(0.1).timeout
	
	# Move back to the original position
	tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(source, "position", origin, return_time)
	await tween.finished

	# Return to idle animation if applicable
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")

	await source.get_tree().create_timer(0.1).timeout
