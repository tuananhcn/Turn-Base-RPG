class_name TurnOrder extends Control

@export var max_visible_turns: int = 5  # Max number of battlers visible in the queue
var turn_queue: Array = []
@onready var active_turn_queue = get_parent().get_node("Battlers") as ActiveTurnQueue
@onready var turn_queue_ui = $TurnBar as VBoxContainer  # Assuming you have a node named UITurnBar for the UI
func _ready():
	update_turn_queue()
func update_turn_queue():
	# Clear all previous turn indicators from the UI
	print("Updating turn queue...")
	clear_queue_ui()
	# Display battlers up to the limit set by max_visible_turns
	for i in range(min(max_visible_turns, active_turn_queue._combined_turn_queue.size())):
		var battler = active_turn_queue._combined_turn_queue[i]
		var turn_display = create_turn_display(battler)
		turn_queue_ui.add_child(turn_display)  # Assuming `turn_queue_ui` is the parent node for turn indicators
# Create a display node for each battler's turn in the queue
func create_turn_display(battler: Battler) -> Control:
	# Create a container for each battler's turn display
	print("create_turn_display")
	var turn_container = HBoxContainer.new()
	turn_container.name = "TurnDisplay_" + str(battler.name)  # Optional for debugging

	# Battler portrait (using TextureRect)
	var portrait = TextureRect.new()
	#if battler.portrait_texture:
		#print("Found portrait for", battler.name)
		#portrait.texture = battler.portrait_texture  # Assuming battler has a portrait_texture property
	#else:
	print("Warning: No portrait texture found for", battler.name)
	portrait.texture = preload("res://icon.svg")  # A fallback texture
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	turn_container.add_child(portrait)

	# Turn number label (if showing multiple turns)
	var turn_label = Label.new()
	turn_label.text = str(battler.turns)  # Assuming battler has a turns property
	turn_container.add_child(turn_label)

	return turn_container  # Return the completed display element
# Call this function with _queued_player_battlers
func clear_queue_ui():
	# Clears previous turn display in the UI node
	for child in turn_queue_ui.get_children():
		turn_queue_ui.remove_child(child)
		child.queue_free()

# Call this function when the queue changes
func set_turn_queue(new_turn_queue: Array[Battler]):
	active_turn_queue._combined_turn_queue = new_turn_queue
	update_turn_queue()
