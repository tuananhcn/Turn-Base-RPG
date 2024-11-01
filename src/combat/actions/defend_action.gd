# DefendAction.gd
class_name PlayerDefend extends BattlerAction

@export var defense_boost: float = 0.5  # 50% defense increase
@export var duration: int = 1  # Duration of 1 turn
func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null
# Override label and description for clarity

# Override the execute method to apply the defense buff
func execute(source: Battler, targets: Array[Battler] = []) -> void:
	print("Executing Defend for", source.name)
	var target: = targets[0]
	await source.get_tree().create_timer(0.1).timeout
	var anim_player = find_animation_player(source)
	if anim_player.has_animation("defend"):
		anim_player.play("defend")
		await anim_player.animation_finished  # Wait for the attack animation to finish
	#apply_buff(target)
	apply_buff(target, "defense", 0.5, 2)
	#await get_tree().process_frame  # Just in case you need to wait a frame for UI updates
	print("Defense buff applied to", source.name)
	await source.get_tree().create_timer(0.1).timeout
func apply_defend(battler: Battler) -> void:
	var buff_icon = load("res://icon.svg")
	battler.stats.apply_temp_modifier(battler, "defense", 0.5, 1, true, buff_icon)
	print("Defense buff applied to", battler.name, "for 1 turn.")
	# Skip to the next turn without casting any skill
func apply_buff(source: Battler, stat: String, percentage: float, turns: int) -> void:
	print("Applying", stat, "buff to", source.name, "by", percentage * 100, "% for", turns, "turns")
	var debuff_icon = load("res://icon.svg")
	source.stats.apply_temp_modifier(source.get_child(0),stat, percentage, turns, true,debuff_icon)
