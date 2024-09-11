extends Control

# Signal that will be emitted when the indicator is clicked
#signal indicator_clicked(battler)
@export var normal_color: Color = Color(1, 1, 1, 1) # White
@export var hover_color: Color = Color(1, 0.8, 0.5, 1) # Light Orange
@export var clicked_color: Color = Color(1, 0.5, 0.5, 1) # Light Red
var battler:Battler = null  # The battler associated with this indicator
func _on_mouse_entered():
	# Change the color when the mouse hovers over the indicator
	get_node("Node2D/Sprite2D").modulate = hover_color
func _on_mouse_exited():
	# Revert to the normal color when the mouse leaves the indicator
	get_node("Node2D/Sprite2D").modulate = normal_color
func _ready():
	# Connect the gui_input signal to this node
	connect("gui_input", Callable(self, "_on_indicator_clicked"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
func _on_indicator_clicked(event: InputEvent):
	var active_turn_queue = find_parent("Battlers")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		active_turn_queue.emit_signal("target_selected", [battler] as Array[Battler])
		get_node("Node2D/Sprite2D").modulate = clicked_color
