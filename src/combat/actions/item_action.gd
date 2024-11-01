# File: battler_action_use_item.gd
class_name ItemAction extends BattlerAction

# Custom properties to determine the item effect
var item_name: String = ""
var restore_hp: int = 0
var restore_energy: int = 0

# Initialization for the action with item details
#func _init(_item_name: String, _restore_hp: int, _restore_energy: int):
	#item_name = _item_name
	#restore_hp = _restore_hp
	#restore_energy = _restore_energy

# Execute the action on the target(s)
func execute(source: Battler, targets: Array[Battler] = []) -> void:
	var target = targets[0]
	if restore_hp > 0:
		print("Restoring HP:", restore_hp, "to", target.name)
		target.apply_item_effect(restore_hp, 0)
	elif restore_energy > 0:
		print("Restoring Energy:", restore_energy, "to", target.name)
		target.apply_item_effect(0, restore_energy)
# UI-friendly name for the action (could be shown in a skill panel)
func get_display_name() -> String:
	return item_name + " (+" + str(restore_hp) + " HP, +" + str(restore_energy) + " Energy)"
