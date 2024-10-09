extends CanvasLayer

@onready var weapon_slot = $NinePatchRect2/GridContainer/WeaponSlot
@onready var armor_slot = $NinePatchRect2/GridContainer/ArmorSlot
@onready var head_slot = $NinePatchRect2/GridContainer/HeadSlot
@onready var accessory_slot = $NinePatchRect2/GridContainer/AccessorySlot
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_equipment_slots()

func setup_equipment_slots():
	# Assuming each NinePatchRect has a TextureRect inside for the icon
	weapon_slot.get_node("TextureRect").texture = load("res://textures/weapon_icon.png")
	armor_slot.get_node("TextureRect").texture = load("res://textures/armor_icon.png")
	head_slot.get_node("TextureRect").texture = load("res://textures/head_icon.png")
	accessory_slot.get_node("TextureRect").texture = load("res://textures/accessory_icon.png")
