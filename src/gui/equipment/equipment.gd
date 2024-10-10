extends CanvasLayer

@onready var weapon_slot = $Panel/GridContainer/WeaponSlot
@onready var armor_slot = $Panel/GridContainer/ArmorSlot
@onready var head_slot = $Panel/GridContainer/HeadSlot
@onready var accessory_slot = $Panel/GridContainer/AccessorySlot
@onready var equipment_inventory_ui = $Panel/GridContainer2
@onready var level_label = get_node("Label&Button/Stats/Level")
@onready var hp_label = get_node("Label&Button/Stats/Hp")
@onready var energy_label = get_node("Label&Button/Stats/Energy")
@onready var attack_label = get_node("Label&Button/Stats/Atk")
@onready var defense_label = get_node("Label&Button/Stats/Defend")
@onready var speed_label = get_node("Label&Button/Stats/Speed")
@onready var hit_chance_label = get_node("Label&Button/Stats/Hitchance")
@onready var evasion_label = get_node("Label&Button/Stats/Evasion")
@onready var inventory = Inventory.restore()
var equipped_items = {
	"Weapon": null,
	"Armor": null,
	"Head": null,
	"Accessory": null
}
# Load the knight stats from the .tres file
#var knight_stats = load("res://src/common/battlers/bear/knight_stats.tres") as Resource

# Load the mage stats if available (example path)
#var mage_stats = load("res://src/common/battlers/mage/mage_stats.tres") as Resource

# Called when the node enters the scene tree for the first time.
# Set default battler to Knight
var current_battler = "Knight"  # Default
var current_stats   # Default stats are Knight's stats

func _ready():
	weapon_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Weapon"))
	armor_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Armor"))
	head_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Head"))
	accessory_slot.get_child(0).pressed.connect(_on_slot_pressed.bind("Accessory"))
	assert(level_label is Label, "level_label is not a valid Label node!")
	assert(hp_label is Label, "hp_label is not a valid Label node!")
	assert(energy_label is Label, "energy_label is not a valid Label node!")
	assert(attack_label is Label, "attack_label is not a valid Label node!")
	assert(defense_label is Label, "defense_label is not a valid Label node!")
	assert(speed_label is Label, "speed_label is not a valid Label node!")
	assert(hit_chance_label is Label, "hit_chance_label is not a valid Label node!")
	assert(evasion_label is Label, "evasion_label is not a valid Label node!")
	update_stats_for_battler()
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
				if texture_button.is_connected("pressed",_on_item_pressed):
					texture_button.disconnect("pressed", _on_item_pressed)
				texture_button.pressed.connect(_on_item_pressed.bind(items_to_display[i]))  # Connect the click event
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
func update_stats_for_battler():
	var player_stats = GlobalData.get_player_stats(current_battler)
	current_stats = player_stats
	# Update stat labels
	level_label.text = "Level: " + str(player_stats.get("level", 1))  # Default to 1 if level is missing
	hp_label.text = "HP: " + str(player_stats.get("current_health", 0)) + "/" + str(player_stats.get("max_health", 100))
	energy_label.text = "Energy: " + str(player_stats.get("current_energy", 0)) + "/" + str(player_stats.get("max_energy", 100))
	attack_label.text = "Attack: " + str(player_stats.get("attack", 0))
	defense_label.text = "Defense: " + str(player_stats.get("defense", 0))
	speed_label.text = "Speed: " + str(player_stats.get("speed", 0))
	hit_chance_label.text = "Hit Chance: " + str(player_stats.get("hit_chance", 0)) + "%"
	evasion_label.text = "Evasion: " + str(player_stats.get("evasion", 0)) + "%"
	update_equipped_item_icons()

func switch_to_knight() -> void:
	current_battler = "Knight"
	update_stats_for_battler()  # Refresh stats for Knight


func switch_to_mage() -> void:
	current_battler = "Mage"
	update_stats_for_battler()  # Refresh stats for Mage
func update_equipped_item_icons():
	for slot in equipped_items.keys():
		var item = equipped_items[slot]
		var slot_button = get_slot_button_for_type(slot)  # Helper function to get the button for the slot
		if item:
			slot_button.texture_normal = item.icon  # Show the equipped item icon
		else:
			match slot:
				"Weapon":
					slot_button.texture_normal = load("res://assets/equipment/placeholder_main_hand.png")
				"Armor":
					slot_button.texture_normal = load("res://assets/equipment/placeholder_chest.png")
				"Head":
					slot_button.texture_normal = load("res://assets/equipment/placeholder_head.png")
				"Accessory":
					slot_button.texture_normal = load("res://assets/equipment/placeholder_offhand.png")

# Helper function to get the button for a specific slot type (Weapon, Armor, etc.)
func get_slot_button_for_type(slot_type: String) -> TextureButton:
	match slot_type:
		"Weapon":
			return weapon_slot.get_child(0)
		"Armor":
			return armor_slot.get_child(0)
		"Head":
			return head_slot.get_child(0)
		"Accessory":
			return accessory_slot.get_child(0)
	return null
func _on_item_pressed(item_type: Inventory.ItemTypes) -> void:
	var item_name = inventory.ItemTypes.keys()[item_type]  # Get the enum name from the type value
	print("Item pressed: ", item_name)

	# Load the clicked item
	var file_path = "res://src/combat/equipable/" + item_name.to_lower() + ".tres"
	if FileAccess.file_exists(file_path):
		var clicked_item = load(file_path) as Equipable
		
		if clicked_item:
			# Check if the item is already equipped
			var player_data = GlobalData.get_player_data(current_battler)  # Get dictionary-based stats
			var player_stats = dictionary_to_battler_stats(player_data)  # Convert to BattlerStats
			clicked_item.init_equipable(player_stats)
			var slot_type = get_slot_type_for_item(clicked_item.equipable_type)
			if equipped_items[slot_type] == clicked_item:
				# Unequip if the item is already equipped
				unequip_item(slot_type)
			else:
				# Equip the item if not already equipped
				unequip_item(slot_type)  # Unequip the currently equipped item in the slot
				equip_item(clicked_item, slot_type)
			
			# Update the stats and the UI
			update_stats_for_battler()
func equip_item(item: Equipable, slot_type: String) -> void:
	equipped_items[slot_type] = item  # Track the equipped item
	item.equip()  # Apply the bonuses from this item
	print("Equipped: ", item.name)

# Unequip the currently equipped item in the specified slot
func unequip_item(slot_type: String) -> void:
	var item = equipped_items[slot_type]
	if item:
		item.unequip()  # Remove the bonuses from this item
		equipped_items[slot_type] = null  # Clear the slot
		print("Unequipped: ", item.name)
func get_slot_type_for_item(equipable_type: Equipable.EquipableType) -> String:
	match equipable_type:
		Equipable.EquipableType.WEAPON:
			return "Weapon"
		Equipable.EquipableType.ARMOR:
			return "Armor"
		Equipable.EquipableType.HEAD:
			return "Head"
		Equipable.EquipableType.ACCESSORY:
			return "Accessory"
	return ""
func dictionary_to_battler_stats(player_data: Dictionary) -> BattlerStats:
	var stats = BattlerStats.new()
	
	# Assign base stats
	stats.base_max_health = player_data.get("max_health", 100)
	stats.max_health = stats.base_max_health
	stats.health = player_data.get("current_health", stats.max_health)
	stats.base_max_energy = player_data.get("max_energy", 6)
	stats.max_energy = stats.base_max_energy
	stats.energy = player_data.get("current_energy", stats.max_energy)
	stats.base_attack = player_data.get("attack", 10)
	stats.base_defense = player_data.get("defense", 10)
	stats.base_speed = player_data.get("speed", 70)
	stats.base_hit_chance = player_data.get("hit_chance", 100)
	stats.base_evasion = player_data.get("evasion", 0)
	
	# Initialize the stats
	stats.initialize()
	
	return stats
