extends Resource

class_name Equipable

@export var name: String
@export var icon: Texture
@export var attack_bonus: int # Bonus to attack
@export var defense_bonus: int # Bonus to defense
@export var equipped: bool = false # Track if it's equipped

func equip() -> void:
	equipped = true
	# Logic to apply bonuses
	print("Equipped: ", name)

func unequip() -> void:
	equipped = false
	# Logic to remove bonuses
	print("Unequipped: ", name)
	
