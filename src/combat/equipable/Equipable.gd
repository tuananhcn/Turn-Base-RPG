extends Resource

class_name Equipable
enum EquipableType { WEAPON, ARMOR, HEAD, ACCESSORY }

@export var name: String
@export var icon: Texture
@export var attack_bonus: int = 1
@export var defense_bonus: int
@export var max_health_bonus: int
@export var max_energy_bonus: int
@export var speed_bonus: int = 0
@export var hit_chance_bonus: int
@export var evasion_bonus: int
@export var equipped: bool
@export var description: String
@export var equipable_type: EquipableType

# Store a reference to the BattlerStats (initialized externally)
var battler_stats: BattlerStats = null

# Initialize the equipable with a reference to the battler's stats
func init_equipable(battler: BattlerStats) -> void:
	battler_stats = battler
var modifier_ids: Dictionary = {}
func equip(current_battler: String) -> void:
	if battler_stats == null:
		print("Error: battler_stats not initialized!")
		return

	if not equipped:
		equipped = true
		print("Equipping: ", name)

		# Apply bonuses to stats, but only if the bonus is not zero
		if attack_bonus != 0:
			battler_stats.add_modifier("attack", attack_bonus)
			GlobalData.get_player_stats(current_battler)["attack"] += attack_bonus  # Update GlobalData
		if defense_bonus != 0:
			battler_stats.add_modifier("defense", defense_bonus)
			GlobalData.get_player_stats(current_battler)["defense"] += defense_bonus
		if max_health_bonus != 0:
			battler_stats.add_modifier("max_health", max_health_bonus)
			GlobalData.get_player_stats(current_battler)["max_health"] += max_health_bonus
		if max_energy_bonus != 0:
			battler_stats.add_modifier("max_energy", max_energy_bonus)
			GlobalData.get_player_stats(current_battler)["max_energy"] += max_energy_bonus
		if speed_bonus != 0:
			battler_stats.add_modifier("speed", speed_bonus)
			GlobalData.get_player_stats(current_battler)["speed"] += speed_bonus
		if hit_chance_bonus != 0:
			battler_stats.add_modifier("hit_chance", hit_chance_bonus)
			GlobalData.get_player_stats(current_battler)["hit_chance"] += hit_chance_bonus
		if evasion_bonus != 0:
			battler_stats.add_modifier("evasion", evasion_bonus)
			GlobalData.get_player_stats(current_battler)["evasion"] += evasion_bonus

		print("Equipped: ", name)

func unequip(current_battler: String) -> void:
	if battler_stats == null:
		print("Error: battler_stats not initialized!")
		return

	if equipped:
		equipped = false
		print("Unequipping: ", name)

		# Remove bonuses from stats only if the modifier was added earlier
		if attack_bonus != 0:
			battler_stats.remove_modifier_if_exists("attack")
			GlobalData.get_player_stats(current_battler)["attack"] -= attack_bonus  # Update GlobalData
		if defense_bonus != 0:
			battler_stats.remove_modifier_if_exists("defense")
			GlobalData.get_player_stats(current_battler)["defense"] -= defense_bonus
		if max_health_bonus != 0:
			battler_stats.remove_modifier_if_exists("max_health")
			GlobalData.get_player_stats(current_battler)["max_health"] -= max_health_bonus
		if max_energy_bonus != 0:
			battler_stats.remove_modifier_if_exists("max_energy")
			GlobalData.get_player_stats(current_battler)["max_energy"] -= max_energy_bonus
		if speed_bonus != 0:
			battler_stats.remove_modifier_if_exists("speed")
			GlobalData.get_player_stats(current_battler)["speed"] -= speed_bonus
		if hit_chance_bonus != 0:
			battler_stats.remove_modifier_if_exists("hit_chance")
			GlobalData.get_player_stats(current_battler)["hit_chance"] -= hit_chance_bonus
		if evasion_bonus != 0:
			battler_stats.remove_modifier_if_exists("evasion")
			GlobalData.get_player_stats(current_battler)["evasion"] -= evasion_bonus

		print("Unequipped: ", name)
