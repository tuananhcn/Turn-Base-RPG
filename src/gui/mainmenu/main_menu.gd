extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/main.tscn")
	pass # Replace with function body.


func _on_load_game_button_pressed() -> void:
	pass # Replace with function body.


func _on_setting_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/options_menu/master_options_menu_with_tabs.tscn")


func _on_close_game_button_pressed() -> void:
	get_tree().quit()
