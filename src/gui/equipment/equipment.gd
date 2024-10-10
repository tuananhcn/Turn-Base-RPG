extends CanvasLayer

@onready var weapon_slot = $Panel/GridContainer/WeaponSlot
@onready var armor_slot = $Panel/GridContainer/ArmorSlot
@onready var head_slot = $Panel/GridContainer/HeadSlot
@onready var accessory_slot = $Panel/GridContainer/AccessorySlot
@onready var equipment_inventory_ui = $Panel/GridContainer2
@onready var inventory = Inventory.restore()
# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Weapon"))
	armor_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Armor"))
	head_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Head"))
	accessory_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Accessory"))
func _on_slot_pressed(slot_type: String) -> void:
	show_equipment_inventory(slot_type)

func show_equipment_inventory(slot_type: String) -> void:
	print("Showing inventory for slot type: ", slot_type)

	# Iterate over each NinePatchRect in the grid and clear the texture of the TextureButton
	for child in equipment_inventory_ui.get_children():
		if child is NinePatchRect:
			var texture_button = child.get_child(0) if child.get_child_count() > 0 else null
			if texture_button and texture_button is TextureButton:
				texture_button.texture_normal = null  # Clear the texture

	# Filter items based on the slot type (Weapon, Armor, Head, Accessory)
	var items_to_display = []
	for item_type in inventory._items.keys():
		var item_count = inventory._items[item_type]
		if !item_count:
			continue
		var item_name = inventory.ItemTypes.keys()[item_type]  # Get the enum name based on the value
		print("Item: ", item_name, " - Count: ", item_count)
		var file_path = "res://src/combat/equipable/" + item_name.to_lower() + ".tres"
		if FileAccess.file_exists(file_path):
			# Load the Equipable instance from the .tres file
			var item_instance = load(file_path) as Equipable
			
			# If item_instance is valid and matches the slot type, add it to display list
			if item_instance and equipable_type_matches_slot(item_instance.equipable_type, slot_type) and inventory.get_item_count(item_type) > 0:
				items_to_display.append(item_type)

	# Populate the UI with the filtered items
	for i in range(min(items_to_display.size(), equipment_inventory_ui.get_child_count())):
		var child = equipment_inventory_ui.get_child(i)
		if child is NinePatchRect:
			var texture_button = child.get_child(0) if child.get_child_count() > 0 else null
			if texture_button and texture_button is TextureButton:
				texture_button.texture_normal = Inventory.get_item_icon(items_to_display[i])  # Set the item icon
func equipable_type_matches_slot(equipable_type: Equipable.EquipableType, slot_type: String) -> bool:
	match slot_type:
		"Weapon":
			return equipable_type == Equipable.EquipableType.WEAPON
		"Armor":
			return equipable_type == Equipable.EquipableType.ARMOR
		"Head":
			return equipable_type == Equipable.EquipableType.HEAD
		"Accessory":
			return equipable_type == Equipable.EquipableType.ACCESSORY
	return false
