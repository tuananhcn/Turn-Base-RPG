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
	
	# Update stat labels
	level_label.text = "Level: " + str(player_stats.get("level", 1))  # Default to 1 if level is missing
	hp_label.text = "HP: " + str(player_stats.get("current_health", 0)) + "/" + str(player_stats.get("max_health", 100))
	energy_label.text = "Energy: " + str(player_stats.get("current_energy", 0)) + "/" + str(player_stats.get("max_energy", 100))
	attack_label.text = "Attack: " + str(player_stats.get("attack", 0))
	defense_label.text = "Defense: " + str(player_stats.get("defense", 0))
	speed_label.text = "Speed: " + str(player_stats.get("speed", 0))
	hit_chance_label.text = "Hit Chance: " + str(player_stats.get("hit_chance", 0)) + "%"
	evasion_label.text = "Evasion: " + str(player_stats.get("evasion", 0)) + "%"


func switch_to_knight() -> void:
	current_battler = "Knight"
	update_stats_for_battler()  # Refresh stats for Knight


func switch_to_mage() -> void:
	current_battler = "Mage"
	update_stats_for_battler()  # Refresh stats for Mage
