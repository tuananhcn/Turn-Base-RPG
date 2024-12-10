extends Node
var SAVE_FILE_PATH = "test"

# Player data for Knight and Mage
var is_in_combat = false
var knight_data: Dictionary = {
	"name": "Knight",
	"level": 1,
	"exp": 0,
	"exp_to_next_level": 100,
	"max_health": 150,
	"current_health": 150,  # Track current health
	"max_energy": 6,
	"current_energy": 0,  # Track current energy
	"attack": 20,
	"defense": 15,
	"speed": 80,
	"hit_chance": 90,
	"evasion": 10,
	"equipped_items": {  # Track the current equipped items
		"Weapon": null,
		"Armor": null,
		"Head": null,
		"Accessory": null
	}
}

var mage_data: Dictionary = {
	"name": "Mage",
	"level": 1,
	"exp": 0,
	"exp_to_next_level": 100,
	"max_health": 150,
	"current_health": 100,  # Track current health
	"max_energy": 6,
	"current_energy": 0,  # Track current energy
	"attack": 15,
	"defense": 10,
	"speed": 81,
	"hit_chance": 85,
	"evasion": 12,
	"equipped_items": {  # Track the current equipped items
		"Weapon": null,
		"Armor": null,
		"Head": null,
		"Accessory": null
	}
}

# Called when the script is loaded
func _ready():
	print("GlobalData is initialized")

# Function to add experience to a specific character (Knight or Mage)
func add_exp_to_player(player_name: String, exp: int):
	var player_data = get_player_data(player_name)
	if player_data.size() > 0:
		player_data.exp += exp
		print(player_name, " gained ", exp, " EXP. Total EXP: ", player_data.exp)
		
		# Check for level up
		while player_data.exp >= player_data.exp_to_next_level:
			level_up(player_name)

# Function to handle leveling up for a specific character
func level_up(player_name: String):
	var player_data = get_player_data(player_name)
	if player_data.size() > 0:
		player_data.exp -= player_data.exp_to_next_level  # Carry over extra EXP
		player_data.level += 1  # Increase the player's level
		player_data.exp_to_next_level = int(player_data.exp_to_next_level * 1.5)  # Increase next level threshold
		
		# Increase stats on level up (adjust as needed for different characters)
		if player_name == "Knight":
			player_data.max_health += 20
			player_data.attack += 5
			player_data.defense += 5
		elif player_name == "Mage":
			player_data.max_health += 10
			player_data.max_energy += 5
			player_data.attack += 5
		
		# Adjust current health and energy after leveling up
		player_data.current_health = player_data.max_health
		player_data.current_energy = player_data.max_energy
		
		print(player_name, " leveled up to level ", player_data.level, "! New stats: Health: ", player_data.max_health)

# Function to get the player data by name
func get_player_data(player_name: String) -> Dictionary:
	if player_name == "Knight":
		return knight_data
	elif player_name == "Mage":
		return mage_data
	else:
		print("Invalid player name: ", player_name)
		return {}  # Return an empty dictionary instead of null

# Function to get player stats for combat setup
func get_player_stats(player_name: String) -> Dictionary:
	return get_player_data(player_name)

# Function to update the player's current health and energy in GlobalData
func update_player_health_and_energy(player_name: String, health: int, energy: int):
	var player_data = get_player_data(player_name)
	if player_data.size() > 0:
		player_data.current_health = clamp(health, 0, player_data.max_health)
		player_data.current_energy = clamp(energy, 0, player_data.max_energy)
		print(player_name, "'s health and energy updated to ", player_data.current_health, "/", player_data.max_health)
func get_equipped_item(player_name: String, slot_type: String) -> Equipable:
	var player_data = get_player_data(player_name)
	if player_data.has("equipped_items"):
		return player_data["equipped_items"].get(slot_type, null)
	return null
# Function to update the player's equipped items
func set_equipped_item(player_name: String, slot_type: String, item: Equipable) -> void:
	var player_data = get_player_data(player_name)
	if player_data.has("equipped_items"):
		player_data["equipped_items"][slot_type] = item
		print(player_name, "'s equipped item updated in slot ", slot_type, ": ", item)
		# Function to unequip an item
func unequip_item(player_name: String, slot_type: String) -> void:
	var player_data = get_player_data(player_name)
	if player_data.has("equipped_items"):
		player_data["equipped_items"][slot_type] = null
		print(player_name, " unequipped item from slot ", slot_type)
		# Function to get all equipped items for a specific player (Knight or Mage)
func get_equipped_items(player_name: String) -> Dictionary:
	var player_data = get_player_data(player_name)
	if player_data.has("equipped_items"):
		return player_data["equipped_items"]
	return {}  # Return an empty dictionary if the player has no equipped items

func save_game():
	var save_data = {
		"knight_data": knight_data,
		"mage_data": mage_data
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game saved successfully")

# Function to load the game
func load_game():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			# Load saved data into current variables
			knight_data = save_data.get("knight_data", knight_data)
			mage_data = save_data.get("mage_data", mage_data)
			print("Game loaded successfully")
		else:
			print("Error: Unable to load the game data")
	else:
		print("No save file found")
