## Numerically represents the characteristics of a specific [Battler].
class_name BattlerStats extends Resource

## A list of all properties that can receive bonuses.
const MODIFIABLE_STATS = [
	"max_health", "max_energy", "attack", "defense", "speed", "hit_chance", "evasion"
]

## Emitted when [member health] has reached 0.
signal health_depleted
## Emitted whenever [member health] changes.
signal health_changed(old_value, new_value)
## Emitted whenver [member energy] changes.
signal energy_changed(old_value, new_value)

@export_category("Elements")
## The battler's elemental affinity. Determines which attacks are more or less effective against
## this battler.
@export var affinity := Elements.Types.NONE

@export_category("Stats")
@export var base_max_health := 100
@export var base_max_energy := 6
@export var base_attack := 10:
	set(value):
		base_attack = value
		_recalculate_and_update("attack")
@export var base_defense := 10:
	set(value):
		base_defense = value
		_recalculate_and_update("defense")
@export var base_speed := 70:
	set(value):
		base_speed = value
		_recalculate_and_update("speed")
@export var base_hit_chance := 100:
	set(value):
		base_hit_chance = value
		_recalculate_and_update("hit_chance")
@export var base_evasion := 0:
	set(value):
		base_evasion = value
		_recalculate_and_update("evasion")

var max_health := base_max_health
var max_energy := base_max_energy
var attack := base_attack
var defense := base_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion

var health := max_health:
	set(value):
		if value != health:
			var previous_health := health
			health = clampi(value, 0, max_health)

			health_changed.emit(previous_health, health)
			if health == 0:
				health_depleted.emit()
var energy := 0:
	set(value):
		if value != energy:
			var previous_energy = energy
			energy = clampi(value, 0, max_energy)

			energy_changed.emit(previous_energy, energy)

# The properties below stores a list of modifiers for each property listed in MODIFIABLE_STATS.
# Dictionary keys are the name of the property (String).
# Dictionary values are another dictionary, with uid/modifier pairs.
var _modifiers := {}
var _multipliers := {}
var temp_modifiers := {}

func _init() -> void:
	for prop_name in MODIFIABLE_STATS:
		_modifiers[prop_name] = {}
		_multipliers[prop_name] = {}


func initialize() -> void:
	health = max_health


## Adds a modifier that affects the stat with the given `stat_name` and returns its unique id.
func add_modifier(stat_name: String, value: int) -> int:
	assert(stat_name in MODIFIABLE_STATS, "Trying to add a modifier to a nonexistent stat.")

	var id := _generate_unique_id(stat_name, true)
	#print("Generated ID for", stat_name, ":", id)
	#print("Adding modifier for", stat_name, "with value:", value)

	_modifiers[stat_name][id] = value
	#print("Modifier added for", stat_name, ": ", _modifiers[stat_name][id])

	# Check that the dictionary is correctly updated
	#print("Modifiers for", stat_name, ": ", _modifiers[stat_name])

	# Recalculate stats after adding the modifier
	_recalculate_and_update(stat_name)

	return id



## Adds a multiplier that affects the stat with the given `stat_name` and returns its unique id.
func add_multiplier(stat_name: String, value: float) -> int:
	assert(stat_name in MODIFIABLE_STATS, "Trying to add a modifier to a nonexistent stat.")

	var id := _generate_unique_id(stat_name, false)
	_multipliers[stat_name][id] = value
	_recalculate_and_update(stat_name)

	return id


# Removes a modifier associated with the given `stat_name`.
func remove_modifier(stat_name: String, id: int) -> void:
	assert(id in _modifiers[stat_name], "Stat %s does not have a modifier with ID '%s'." % [id,
		_modifiers[stat_name]])
	#print("Removing modifier for stat: ", stat_name, " with ID: ", id)  # Debug output
	_modifiers[stat_name].erase(id)
	_recalculate_and_update(stat_name)


func remove_multiplier(stat_name: String, id: int) -> void:
	assert(id in _multipliers[stat_name], "Stat %s does not have a multiplier with ID '%s'." % [id,
		_multipliers[stat_name]])

	_multipliers[stat_name].erase(id)
	_recalculate_and_update(stat_name)


# Calculates the final value of a single stat. That is, its based value with all modifiers applied.
# We reference a stat property name using a string here and update it with the `set()` method.
func _recalculate_and_update(prop_name: String) -> void:
	assert(prop_name in self, "Cannot update battler stat '%s'! Stat name is invalid!" % prop_name)

	# All our property names follow a pattern: the base stat has the same identifier as the final
	# stat with the "base_" prefix.
	var base_prop_id := "base_" + prop_name
	assert(base_prop_id in self, "Cannot update battler stat %s! Stat does not have base value!" % prop_name)
	var value := get(base_prop_id) as float

	# Multipliers apply to the stat multiplicatively.
	# They are first summed, with the sole restriction that they may not go below zero.
	var stat_multiplier := 1.0
	var multipliers: Array = _multipliers[prop_name].values()
	for multiplier in multipliers:
		stat_multiplier += multiplier
	if stat_multiplier < 0.0:
		stat_multiplier = 0.0

	# Apply the cumulative multiplier to the stat.
	if not is_equal_approx(stat_multiplier, 1.0):
		value *= stat_multiplier

	# Add all modifiers to the stat.
	var modifiers: Array = _modifiers[prop_name].values()
	for modifier in modifiers:
		value += modifier

	# Finally, don't allow values to drop below zero.
	value = roundf(max(value, 0.0))

	# Here's where we assign the value to the stat. For instance, if the `stat` argument is
	# "attack", this is like writing 'attack = value'.
	# Note that this sets an integer to a float value, so the decimal will no longer be relevent.
	set(prop_name, value)


# Find the first unused integer in a stat's modifiers keys.
# is_modifier determines whether the id is determined from the modifier or multiplier dictionary.
func _generate_unique_id(stat_name: String, is_modifier := true) -> int:
	# Generate an ID for either modifiers or multipliers.
	var dictionary := _modifiers
	if not is_modifier:
		dictionary = _multipliers

	# If there are no keys, we return 0, which is our first valid unique id. Without existing
	# keys, calling methods like Array.back() will trigger an error.
	var keys: Array = dictionary[stat_name].keys()
	if keys.is_empty():
		return 0
	else:
		# We always start from the last key, which will always be the highest number, even if we
		# remove modifiers.
		return keys.back() + 1
func remove_modifier_if_exists(stat_name: String) -> void:
	var id = _modifiers[stat_name]
	if id != null and id in _modifiers[stat_name]:
		_modifiers[stat_name].erase(id)
		_modifiers[stat_name] = null  # Clear the ID after removal
		_recalculate_and_update(stat_name)
		#print("Removed modifier for", stat_name, "with ID", id)
	else:
		print("No modifier to remove for stat:", stat_name)
func apply_temp_modifier(battler: Node2D, stat_name: String, percentage: float, turns: int, is_buff: bool = true, icon_texture: Texture2D = null) -> void:
	# Ensure the stat exists
	assert(stat_name in MODIFIABLE_STATS, "Trying to modify a nonexistent stat.")
	
	# Calculate the modifier value based on the base stat
	var modifier_value = get("base_" + stat_name) * percentage
	if not is_buff:
		modifier_value = -modifier_value  # Debuffs are negative
	# Apply the modifier
	var id = add_modifier(stat_name, int(modifier_value))
	# Store the temporary modifier along with its turns
	temp_modifiers[id] = {
		"stat_name": stat_name,
		"value": modifier_value,
		"turns": turns,
		"id": id
	}
	# Display buff/debuff icon if provided
	var status_container = battler.get_node("StatusIconContainer")
	if icon_texture != null:
		var icon = TextureRect.new()
		status_container.add_child(icon)
		icon.texture = icon_texture
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size  = Vector2(90, 90)  # Set size for the icon
		icon.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE 
		var turns_label = Label.new()
		turns_label.text = str(turns)
		turns_label.modulate = Color(1, 1, 1)  # White color
		turns_label.add_theme_font_size_override("font_size",60)
		icon.add_child(turns_label)
		#if battler.direction == 0:
			#turns_label.anchor_right = 0.0
			#turns_label.scale = Vector2(-1,1)
		#else:
		turns_label.anchor_right = 0.0  # Align to the bottom-right of the icon
		turns_label.anchor_bottom = 0.0
		turns_label.scale = Vector2(1, 1)
		# Attach the label to the icon
		
		
		
		# Store the icon in temp_modifiers so we can remove it later
		temp_modifiers[id]["icon_node"] = icon
		temp_modifiers[id]["turns_label"] = turns_label
	# Recalculate the stats with the new modifier
	_recalculate_and_update(stat_name)


# Updates the temporary modifiers' durations and removes them if expired
func update_temp_modifiers() -> void:
	var to_remove = []
	for key in temp_modifiers.keys():
		var modifier = temp_modifiers[key]
		modifier["turns"] -= 1  # Decrement turns
		if modifier.has("turns_label"):
			modifier["turns_label"].text = str(modifier.turns)
		# If expired, remove the modifier
		if modifier["turns"] <= 0:
			_recalculate_and_update(modifier["stat_name"])  # Recalculate before removal
			remove_modifier(modifier["stat_name"], modifier["id"])
			if modifier.has("icon_node") and modifier.icon_node != null:
				modifier.icon_node.queue_free()
			to_remove.append(key)
	# Remove expired modifiers from the dictionary
	for key in to_remove:
		temp_modifiers.erase(key)


func clear_temp_modifiers() -> void:
	for key in temp_modifiers.keys():
		var modifier = temp_modifiers[key]
		remove_modifier(modifier["stat_name"], modifier["id"])
	
	# Clear the temp_modifiers dictionary
	temp_modifiers.clear()
func apply_item_effect(hp_restore: int, energy_restore: int) -> void:
	# Restore HP, clamping to the maximum health
	if hp_restore > 0:
		var previous_health = health
		health = min(health + hp_restore, max_health)
		health_changed.emit(previous_health, health)  # Emit health changed signal
		print("Restored HP:", hp_restore, "New HP:", health)

	# Restore Energy, clamping to the maximum energy
	if energy_restore > 0:
		energy = min(energy + energy_restore, max_energy)
		print("Restored Energy:", energy_restore, "New Energy:", energy)
