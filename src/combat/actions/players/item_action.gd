# File: battler_action_use_item.gd
class_name ItemAction extends BattlerAction

# Custom properties to determine the item effect
var item_name: String = ""
var restore_hp: int = 0
var restore_energy: int = 0
var skill_effect_scene: PackedScene 
func find_pivot(battler: Battler) -> Node2D:
	# Traverse through the children of the battler to find the node that has a 'Pivot'
	for child in battler.get_children():
		if child.has_node("Pivot"):
			return child.get_node("Pivot")
	return null  # Return null if no Pivot is found
# Initialization for the action with item details
#func _init(_item_name: String, _restore_hp: int, _restore_energy: int):
	#item_name = _item_name
	#restore_hp = _restore_hp
	#restore_energy = _restore_energy

# Execute the action on the target(s)
func execute(source: Battler, targets: Array[Battler] = []) -> void:
	var target = targets[0]
	if restore_hp > 0:
		skill_effect_scene = preload("res://assets/battlers/ParticleSkill/Healing.tscn")
		print("Restoring HP:", restore_hp, "to", target.name)
		target.apply_item_effect(restore_hp, 0)
	elif restore_energy > 0:
		skill_effect_scene = preload("res://assets/battlers/ParticleSkill/Energy.tscn")
		print("Restoring Energy:", restore_energy, "to", target.name)
		target.apply_item_effect(0, restore_energy)
	var target_pivot = find_pivot(target)
	if target_pivot == null:
		print("Error: Pivot not found for target!")
		return
	var skill_effect_instance = skill_effect_scene.instantiate()
	skill_effect_instance.z_index = 10  # Make sure it's on top
	skill_effect_instance.scale = Vector2(12, 12)  # Temporarily scale up to make it more visible
	skill_effect_instance.position = target_pivot.global_position  # Use the pivot's global position
	source.get_parent().add_child(skill_effect_instance)  # Add to the same parent of source
	# Get the AnimatedSprite2D and play the animation
	var animated_sprite = skill_effect_instance.get_node("AnimatedSprite2D")
	#animated_sprite.play("animation_name")  # Replace with your animation's name

	# Wait until the animation finishes
	await animated_sprite.animation_finished
	# Destroy the effect after the tween finishes
	skill_effect_instance.queue_free()
# UI-friendly name for the action (could be shown in a skill panel)
func get_display_name() -> String:
	return item_name + " (+" + str(restore_hp) + " HP, +" + str(restore_energy) + " Energy)"
