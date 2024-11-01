## A playable combatant that carries out [BattlerActions] as its [member readiness] charges.
##
## Battlers are the playable characters or enemies that show up in battle. They have [BattlerStats],
## a list of [BattlerAction]s to choose from, and respond to a variety of stimuli such as status
## effects and [BattlerHit]s, which typically deal damage or heal the Battler.
##
## [br][br]Battlers have [BattlerAnim]ation children which play out the Battler's actions.
class_name Battler extends Node2D

## Emitted when the battler finished their action and arrived back at their rest position.
signal action_finished
## Forwarded from the receiving of [signal BettlerStats.health_depleted].
signal health_depleted
## Emitted when taking damage or being healed from a [BattlerHit].
## [br][br]Note the difference between this and [signal BattlerStats.health_changed]:
## 'hit_received' is always the direct result of an action, requiring graphical feedback.
signal hit_received(value: int)
## Emitted whenever a hit targeting this battler misses.
signal hit_missed
## Emitted when the battler's `_readiness` changes.
signal readiness_changed(new_value)
## Emitted when the battler is ready to take a turn.
signal ready_to_act
## Emitted when modifying `is_selected`. The user interface will react to this for
## player-controlled battlers.
signal selection_toggled(value: bool)
signal health_updated(value: int)  # For updating the HP bar
signal energy_updated(value: int)  # For updating the Mana/Energy bar
@export var stats: BattlerStats = null
# Each action's data stored in this array represents an action the battler can perform.
# These can be anything: attacks, healing spells, etc.
@export var actions: Array[BattlerAction]
# If the battler has an `ai_scene`, we will instantiate it and let the AI make decisions.
# If not, the player controls this battler. The system should allow for ally AIs.
@export var ai_scene: PackedScene
@export var is_player: = false
@export var icon: Texture = null  # Property to assign the battler's icon/portrait
#@export var hp_bar: TextureProgressBar
## If `false`, the battler will not be able to act.
@onready var anim: BattlerAnim = get_child(0)
#@export var battler_anim_scene: PackedScene:
	#set(value):
		#battler_anim_scene = value
		#
		#if not is_inside_tree():
			#await ready
		#
		## Free an already existing BattlerAnim.
		#if anim:
			#anim.queue_free()
			#anim = null
		#
		## Add the new BattlerAnim class as a child and link it to this Battler instance.
		#if battler_anim_scene:
			## Normally we could wrap a check for battler_anim_scene's type (should be BattlerAnim)
			## in a call to assert, but we want the following code to run in the editor and clean up
			## dynamically if the user drops an incorrect PackedScene (i.e. not a BattlerAnim) into
			## the battler_anim_scene slot.
			#var new_scene: = battler_anim_scene.instantiate()
			#anim = new_scene as BattlerAnim
			#if not anim:
				#push_warning("Battler '%s' cannot accept '%s' as " % [name, new_scene.name],
					#"battler_anim_scene. '%s' is not a BattlerAnim!" % new_scene.name)
				#new_scene.free()
				#battler_anim_scene = null
				#return
			#
			#add_child(anim)
			#var facing: = BattlerAnim.Direction.LEFT if is_player else BattlerAnim.Direction.RIGHT
			#anim.setup(self, facing)
var is_active: bool = true:
	set(value):
		is_active = value
		set_process(is_active)

## The turn queue will change this property when another battler is acting.
var time_scale := 1.0:
	set(value):
		time_scale = value

## If `true`, the battler is selected, which makes it move forward.
var is_selected: bool = false:
	set(value):
		if value:
			assert(is_selectable)

		is_selected = value
		selection_toggled.emit(is_selected)

## If `false`, the battler cannot be targeted by any action.
var is_selectable: bool = true:
	set(value):
		is_selectable = value
		if not is_selectable:
			is_selected = false

## When this value reaches `100.0`, the battler is ready to take their turn.
var readiness := 0.0:
	set(value):
		readiness = value
		readiness_changed.emit(readiness)

		if readiness >= 100.0:
			ready_to_act.emit()
			set_process(false)


func _ready() -> void:
	assert(stats, "Battler %s does not have stats assigned!" % name)

	# Resources are NOT unique, so treat the currently assigned BattlerStats as a prototype.
	# That is, copy what it is now and use the copy, so that the original remains unaltered.
	stats = stats.duplicate()
	stats.initialize()
	set_process(true)
	stats.health_depleted.connect(func on_stats_health_depleted() -> void:
		is_active = false
		is_selectable = false
		health_depleted.emit()
	)
func _process(delta: float) -> void:
	readiness += stats.speed * delta * time_scale


func act(action: BattlerAction, targets: Array[Battler] = []) -> void:
	stats.energy -= action.energy_cost
	# Emit the energy_updated signal after energy has been changed
	energy_updated.emit(stats.energy)
	# action.execute() almost certainly is a coroutine.
	@warning_ignore("redundant_await")
	await action.execute(self, targets)
	readiness = action.readiness_saved

	if is_active:
		set_process(true)

	action_finished.emit()
	

func take_hit(hit: BattlerHit) -> void:
	if hit.is_successful():
		hit_received.emit(hit.damage)
		stats.health -= hit.damage 
		health_updated.emit(stats.health)
	else:
		hit_missed.emit()
func apply_item_effect(hp_restore: int, energy_restore: int) -> void:
	# Restore HP, clamping to max_health
	if hp_restore > 0:
		var previous_health = stats.health
		stats.health = min(stats.health + hp_restore, stats.max_health)
		health_updated.emit(stats.health)  # Emit signal to update the UI
		print("Restored HP:", hp_restore, "New HP:", stats.health)

	# Restore Energy, clamping to max_energy
	if energy_restore > 0:
		var previous_energy = stats.energy
		stats.energy = min(stats.energy + energy_restore, stats.max_energy)
		energy_updated.emit(stats.energy)  # Emit signal to update the UI
		print("Restored Energy:", energy_restore, "New Energy:", stats.energy)
