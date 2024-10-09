class_name TurnOrder extends Control

@export var max_visible_turns: int = 3  # Max number of battlers visible in the queue
var turn_queue: Array = []
@onready var turn_queue_ui = $TurnBar as VBoxContainer  # Assuming you have a node named UITurnBar for the UI
@onready var active_turn_queue = get_parent().get_node("Battlers") as ActiveTurnQueue
func _ready() -> void:
	# Connect to the signal emitted by ActiveTurnQueue
	if active_turn_queue:
		active_turn_queue.turn_queue_ready.connect(update_turn_queue)
func update_turn_queue():
	# Clear all previous turn indicators from the UI
	print("Updating turn queue...")
	print(active_turn_queue)
	sort_battlers_by_readiness(active_turn_queue._combined_turn_queue)
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
	turn_container.custom_minimum_size = Vector2(128, 128)  # Fixed size container

	# Battler portrait (using TextureRect)
	var portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(128, 128)  # Example size (32x32)
	portrait.stretch_mode  = TextureRect.STRETCH_KEEP_ASPECT     # Keeps aspect centered
	portrait.expand_mode  = TextureRect.EXPAND_IGNORE_SIZE     # Keeps aspect centered
	if battler.icon:
		portrait.texture = battler.icon  # Use the battler's texture
	else:
		portrait.texture = preload("res://icon.svg")  # A fallback texture

	#var portrait_container = Control.new()
	#portrait_container.rect_min_size  = Vector2(32, 32)  # Set fixed size (32x32 pixels)
	#portrait_container.add_child(portrait)
	
	turn_container.add_child(portrait)

	# Turn number label (optional)
	var turn_label = Label.new()
	turn_label.text = str(round(battler.readiness)) # Assuming battler has a 'turns' property
	turn_container.add_child(turn_label)

	return turn_container
func clear_queue_ui():
	# Clears previous turn display in the UI node
	for child in turn_queue_ui.get_children():
		turn_queue_ui.remove_child(child)
		child.queue_free()

# Call this function when the queue changes
func compare_readiness(a: Battler, b: Battler) -> int:
	return int(b.readiness - a.readiness)  # Sort in decreasing order
func sort_battlers_by_readiness(battlers: Array[Battler]):
	var n = battlers.size()
	for i in range(n):
		for j in range(0, n - i - 1):
			if battlers[j].readiness < battlers[j + 1].readiness:
				# Swap battlers using a temporary variable
				var temp = battlers[j]
				battlers[j] = battlers[j + 1]
				battlers[j + 1] = temp
