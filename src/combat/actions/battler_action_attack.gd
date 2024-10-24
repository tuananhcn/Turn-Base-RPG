# A sample [BattlerAction] implementation that simulates a direct melee hit.
class_name AttackBattlerAction extends BattlerAction

const ATTACK_DISTANCE: = 350.0
## A to-hit modifier for this attack that will be influenced by the target Battler's
## [member BattlerStats.evasion].
@export var hit_chance: = 100.0
@export var base_damage: = 50

func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null
func execute(source: Battler, targets: Array[Battler] = []) -> void:
	assert(not targets.is_empty(), "An attack action requires a target.")
	var target: = targets[0]
	await source.get_tree().create_timer(0.1).timeout
	var anim_player = find_animation_player(source)
	#if source.has_node("AnimationPlayer"):
		#anim_player = source.get_node("Pivot/AnimationPlayer")
		## Start the run animation when moving to the target
	# Calculate where the acting Battler will move from and to.
	var origin: = source.position
	var attack_normal: float = sign(source.position.x - target.position.x)
	var destination: = target.position + Vector2(ATTACK_DISTANCE*attack_normal, 0)
	# Animate movement to attack position.
	var tween: = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if anim_player.has_animation("run"):
		anim_player.play("run")
		tween.tween_property(source, "position", destination, 0.8889)
	else:
		tween.tween_property(source, "position", destination, 0.25)
	await tween.finished
	if anim_player.has_animation("attack"):
		anim_player.play("attack")
		await anim_player.animation_finished  # Wait for the attack animation to finish
	# No attack animations yet, so wait for a short delay and then apply damage to the target.
	# Normally we would wait for an attack animation's "triggered" signal.
	await source.get_tree().create_timer(0.1).timeout
	var hit: = BattlerHit.new(base_damage, hit_chance)
	target.take_hit(hit)
	print(target.stats.defense)
	await source.get_tree().create_timer(0.1).timeout

	# Animate movement back to the attacker's original position.
	tween = source.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if anim_player and anim_player.has_animation("run"):
		anim_player.play_backwards("run")  # Play the run animation backwards
		tween.tween_property(source, "position", origin, 0.8889)
	else:
		tween.tween_property(source, "position", origin, 0.25)
	await tween.finished
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")
	await source.get_tree().create_timer(0.1).timeout
