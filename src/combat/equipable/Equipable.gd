extends Resource

class_name Equipable
enum EquipableType { WEAPON, ARMOR, HEAD, ACCESSORY }
@export var name: String
@export var icon: Texture
@export var attack_bonus: int = 0  # Bonus to attack
@export var defense_bonus: int = 0  # Bonus to defense
@export var max_health_bonus: int = 0  # Bonus to max health
@export var max_energy_bonus: int = 0  # Bonus to max energy
@export var speed_bonus: int = 0  # Bonus to speed
@export var hit_chance_bonus: int = 0  # Bonus to hit chance
@export var evasion_bonus: int = 0  # Bonus to evasion
@export var equipped: bool = false  # Track if it's equipped
@export var description: String
@export var equipable_type: EquipableType  # Type of equipment (Weapon, Armor, etc.)
# Store a reference to the BattlerStats
var battler_stats: BattlerStats

func init_equipable(battler: BattlerStats) -> void:
	battler_stats = battler

func equip() -> void:
	if not equipped:
		equipped = true
		# Apply bonuses to stats
		battler_stats.add_modifier("attack", attack_bonus)
		battler_stats.add_modifier("defense", defense_bonus)
		battler_stats.add_modifier("max_health", max_health_bonus)
		battler_stats.add_modifier("max_energy", max_energy_bonus)
		battler_stats.add_modifier("speed", speed_bonus)
		battler_stats.add_modifier("hit_chance", hit_chance_bonus)
		battler_stats.add_modifier("evasion", evasion_bonus)
		print("Equipped: ", name)

func unequip() -> void:
	if equipped:
		equipped = false
		# Remove bonuses from stats
		battler_stats.remove_modifier("attack", attack_bonus)
		battler_stats.remove_modifier("defense", defense_bonus)
		battler_stats.remove_modifier("max_health", max_health_bonus)
		battler_stats.remove_modifier("max_energy", max_energy_bonus)
		battler_stats.remove_modifier("speed", speed_bonus)
		battler_stats.remove_modifier("hit_chance", hit_chance_bonus)
		battler_stats.remove_modifier("evasion", evasion_bonus)
		print("Unequipped: ", name)
