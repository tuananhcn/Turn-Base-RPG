extends Trigger

@export var timeline: DialogicTimeline
@export var ghost_animation_player: AnimationPlayer

var gamepiece: Gamepiece

@onready var _timer: = $Timer as Timer
@onready var _main_music_player
func _ready() -> void:
	super._ready()
	if not Engine.is_editor_hint():
		_main_music_player = get_node("//root/Main/AudioStreamPlayer") as AudioStreamPlayer
func _execute() -> void:
	gamepiece.travel_to_cell(Vector2i(53, 30))
	await gamepiece.arrived
	
	_timer.start()
	await _timer.timeout
	 # Change the music to another song
	if _main_music_player:
		_main_music_player.stop()  # Stop the current music
		_main_music_player.stream = preload("res://assets/music/Weight of the World - 8 bit.mp3")  # Load the new song
		_main_music_player.play()  # Play the new song
	Dialogic.start_timeline(timeline)
	await Dialogic.timeline_ended
	
	_timer.start()
	await _timer.timeout
	
	# Note that the lunge animation also includes a screen transition and some text.
	ghost_animation_player.play("lunge")
	await ghost_animation_player.animation_finished
	
	# Lock input by waiting for a signal that won't trigger.
	await ready


func _on_area_entered(area: Area2D) -> void:
	super._on_area_entered(area)
	gamepiece = area.owner as Gamepiece
