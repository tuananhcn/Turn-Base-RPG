extends Resource

class_name Consumable

@export var name: String
@export var icon: Texture
@export var heal_amount: int # Amount of HP restored
@export var energy_amount: int # Amount of energy restored

func use() -> void:
	# Logic to apply the effect of the consumable
	print("Used consumable: ", name)
