extends CanvasLayer

func _input(event):
	if event.is_action_pressed("ui_settings"):  # Check if ESC key is pressed
		open_settings()
var is_setting_opened = false
func open_settings():
	if !is_setting_opened:
		show()
		is_setting_opened = true
	else:
		hide()
		is_setting_opened = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
