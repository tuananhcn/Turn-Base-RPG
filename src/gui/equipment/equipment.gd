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
var current_stats = load("res://src/common/battlers/bear/knight_stats.tres") as Resource  # Default stats are Knight's stats

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
				if texture_button.is_connected("mouse_entered",_on_item_hover):
					texture_button.disconnect("mouse_entered", _on_item_hover)
				if texture_button.is_connected("mouse_exit",_on_item_hover):
					texture_button.disconnect("mouse_exit", _on_item_hover)
				texture_button.pressed.connect(_on_item_pressed.bind(items_to_display[i]))  # Connect the click event
				texture_button.mouse_entered.connect(_on_item_hover.bind(items_to_display[i]))
				texture_button.mouse_exited.connect(_on_exited_hover)
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
	var battler_stats = current_stats  # Assuming current_battler_stats points to BattlerStats instance
	level_label.text = "Level: " + str(player_stats.get("level", 1))  # Dynamic level from GlobalData
	hp_label.text = "HP: " + str(player_stats.get("current_health", 0)) + "/" + str(battler_stats.max_health)  # Current health from GlobalData, max health from BattlerStats
	energy_label.text = "Energy: " + str(player_stats.get("current_energy", 0)) + "/" + str(battler_stats.max_energy)  # Similar for energy
	
	# Core stats from BattlerStats
	attack_label.text = "Attack: " + str(player_stats.attack)
	defense_label.text = "Defense: " + str(player_stats.defense)
	speed_label.text = "Speed: " + str(player_stats.speed)
	hit_chance_label.text = "Hit Chance: " + str(player_stats.hit_chance) + "%"
	evasion_label.text = "Evasion: " + str(player_stats.evasion) + "%"

func switch_to_knight() -> void:
	current_battler = "Knight"
	current_stats = load("res://src/common/battlers/bear/knight_stats.tres") as Resource  # Default stats are Knight's stats
	update_stats_for_battler()  # Refresh stats for Knight


func switch_to_mage() -> void:
	current_battler = "Mage"
	current_stats = load("res://src/common/battlers/bear/mage_stats.tres") as Resource  # Default stats are Knight's stats
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
			update_equipped_item_icons()
	
func equip_item(item: Equipable, slot_type: String) -> void:
	equipped_items[slot_type] = item  # Track the equipped item
	item.equip(current_battler)  # Apply the bonuses from this item
	update_stats_for_battler()
# Unequip the currently equipped item in the specified slot
func unequip_item(slot_type: String) -> void:
	var item = equipped_items[slot_type]
	if item:
		item.unequip(current_battler)  # Remove the bonuses from this item
		equipped_items[slot_type] = null  # Clear the slot
	update_stats_for_battler()
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
func _compare_stats_and_update_ui(equipped_item: Equipable, hovered_item: Equipable, bonus_property: String, label_path: String, unequip: bool = false) -> void:
	var equipped_bonus = equipped_item.get(bonus_property) if equipped_item != null else 0
	
	# Get hovered item's bonus for the stat or treat it as unequip if necessary
	var hovered_bonus = 0
	if not unequip:
		hovered_bonus = hovered_item.get(bonus_property) if hovered_item != null else 0
	
	# Calculate the difference
	var difference = hovered_bonus - equipped_bonus
	
	# Get the Label node for the stat comparison
	var label = get_node(label_path) as Label
	if label:
		if difference > 0:
			label.text = "+" + str(difference)
			label.modulate = Color(0, 1, 0)  # Set text color to green
		elif difference < 0:
			label.text = str(difference)
			label.modulate = Color(1, 0, 0)  # Set text color to red
		else:
			label.text= ""
func _on_item_hover(item_type: Inventory.ItemTypes) -> void:
	# Load the clicked item
	var item_name = Inventory.ItemTypes.keys()[item_type]
	var file_path = "res://src/combat/equipable/" + item_name.to_lower() + ".tres"
	if FileAccess.file_exists(file_path):
		var hovered_item = load(file_path) as Equipable
		
		if hovered_item:
			# Compare the hovered item with the currently equipped item
			var slot_type = get_slot_type_for_item(hovered_item.equipable_type)
			var equipped_item = equipped_items.get(slot_type)

			if equipped_item == hovered_item:
				# Display negative stat changes (as if unequipping the item)
				_compare_stats_and_update_ui(equipped_item, null, "attack_bonus", "Label&Button/StatsCompare/Atk", true)
				_compare_stats_and_update_ui(equipped_item, null, "defense_bonus", "Label&Button/StatsCompare/Defend", true)
				_compare_stats_and_update_ui(equipped_item, null, "max_health_bonus", "Label&Button/StatsCompare/Hp", true)
				_compare_stats_and_update_ui(equipped_item, null, "max_energy_bonus", "Label&Button/StatsCompare/Energy", true)
				_compare_stats_and_update_ui(equipped_item, null, "speed_bonus", "Label&Button/StatsCompare/Speed", true)
				_compare_stats_and_update_ui(equipped_item, null, "hit_chance_bonus", "Label&Button/StatsCompare/Hitchance", true)
				_compare_stats_and_update_ui(equipped_item, null, "evasion_bonus", "Label&Button/StatsCompare/Evasion", true)
			else:
				# Compare the hovered item with the currently equipped item and show potential stat changes
				_compare_stats_and_update_ui(equipped_item, hovered_item, "attack_bonus", "Label&Button/StatsCompare/Atk")
				_compare_stats_and_update_ui(equipped_item, hovered_item, "defense_bonus", "Label&Button/StatsCompare/Defend")
				_compare_stats_and_update_ui(equipped_item, hovered_item, "max_health_bonus", "Label&Button/StatsCompare/Hp")
				_compare_stats_and_update_ui(equipped_item, hovered_item, "max_energy_bonus", "Label&Button/StatsCompare/Energy")
				_compare_stats_and_update_ui(equipped_item, hovered_item, "speed_bonus", "Label&Button/StatsCompare/Speed")
				_compare_stats_and_update_ui(equipped_item, hovered_item, "hit_chance_bonus", "Label&Button/StatsCompare/Hitchance")
				_compare_stats_and_update_ui(equipped_item, hovered_item, "evasion_bonus", "Label&Button/StatsCompare/Evasion")
func _on_exited_hover():
	get_node("Label&Button/StatsCompare/Hp").text = ""
	get_node("Label&Button/StatsCompare/Energy").text = ""
	get_node("Label&Button/StatsCompare/Atk").text = ""
	get_node("Label&Button/StatsCompare/Defend").text = ""
	get_node("Label&Button/StatsCompare/Speed").text = ""
	get_node("Label&Button/StatsCompare/Hitchance").text = ""
	get_node("Label&Button/StatsCompare/Evasion").text = ""
