extends Node

# Player data for Knight and Mage
var knight_data: Dictionary = {
	"name": "Knight",
	"level": 1,
	"exp": 0,
	"exp_to_next_level": 100,
	"max_health": 150,
	"current_health": 150,  # Track current health
	"max_energy": 10,
	"current_energy": 10,  # Track current energy
	"attack": 20,
	"defense": 15,
	"speed": 80,
	"hit_chance": 90,
	"evasion": 10
}

var mage_data: Dictionary = {
	"name": "Mage",
	"level": 1,
	"exp": 0,
	"exp_to_next_level": 100,
	"max_health": 100,
	"current_health": 100,  # Track current health
	"max_energy": 20,
	"current_energy": 20,  # Track current energy
	"attack": 15,
	"defense": 10,
	"speed": 70,
	"hit_chance": 85,
	"evasion": 12
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
