## Starts and ends combat, and manages the transition between the field game state and the combat game.
##
## The battle is composed mainly from a [CombatArena], which contains all necessary subelements such
## as battlers, visual effects, music, etc.
##
## This container handles the logic of switching between the field game state, the combat game
## state, and the combat results screen (e.g. experience and levelling up, loot, etc.). It is
## responsible for changing the music, playing screen transition animations, and other state-switch
## elements.
extends CanvasLayer

var _active_arena: CombatArena = null

# Keep track of what music track was playing previously, and return to it once combat has finished.
var _previous_music_track: AudioStream = null

@onready var _combat_container: = $CenterContainer as CenterContainer
@onready var _transition_delay_timer: = $CenterContainer/TransitionDelay as Timer


func _ready() -> void:
	FieldEvents.combat_triggered.connect(start)


@onready var _main_music_player = $"../AudioStreamPlayer" as AudioStreamPlayer
## Begin a combat. Takes a PackedScene as its only parameter, expecting it to be a CombatState object once
## instantiated.
## This is normally a response to [signal FieldEvents.combat_triggered].
func start(arena: PackedScene) -> void:
	assert(_active_arena == null, "Attempting to start a combat while one is ongoing!")

	await Transition.cover(0.2)
	_previous_music_track = _main_music_player.stream
	_main_music_player.stop()
	var new_arena: = arena.instantiate()
	assert(
		new_arena != null,
		"Failed to initiate combat. Provided 'arena' arugment is not a CombatArena."
	)

	_active_arena = new_arena
	_combat_container.add_child(_active_arena)

	_active_arena.turn_queue.combat_finished.connect(
		func on_combat_finished(is_player_victory: bool):
			CombatEvents.did_player_win_last_combat = is_player_victory
			
			_transition_delay_timer.start()
			await _transition_delay_timer.timeout
			# Cover the screen again, transitioning away from the combat game state.
			await Transition.cover(0.2)

			assert(_active_arena != null, "Combat finished but no active arena to clean up!")
			_active_arena.queue_free()
			_active_arena = null

			#Music.play(_previous_music_track)
			#_previous_music_track = null

			# Whatever object started the combat will now be responsible for flow of the game. In
			# particular, the screen is still covered, so the combat-starting object will want to decide
			# what to do now that the outcome of the combat is known.
			# Resume the previous music
			# Resume the previous music
			if _previous_music_track:
				_main_music_player.stream = _previous_music_track
				_main_music_player.play()
				_previous_music_track = null
			GlobalData.is_in_combat = false  # Example global state for combat tracking
			var InventoryUI = get_node("//root/Main/Field/UI/Inventory")
			InventoryUI.show()
			CombatEvents.combat_finished.emit()
	)

	#_previous_music_track = Music.get_playing_track()
	Music.play(_active_arena.music)

	CombatEvents.combat_initiated.emit()

	# Before starting combat itself, reveal the screen again.
	# The Transition.clear() call is deferred since it follows on the heels of cover(), and needs a
	# frame to allow everything else to respond to Transition.finished.
	Transition.clear.call_deferred(0.2)
	await Transition.finished

	# Begin the combat. The turn queue takes over from here.
	_active_arena.turn_queue.is_active = true
