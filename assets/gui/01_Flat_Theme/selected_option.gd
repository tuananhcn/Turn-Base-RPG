extends Control
@onready var grid_container = $NinePatchRect/GridContainer
@onready var audiostream = $AudioStreamPlayer
@onready var custom_theme = preload("res://src/gui/mainmenu/new_theme.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_container.columns = 3  # Đặt số cột thành 3
	pass # Replace with function body.
func show_skills_for_battler(battler: Battler):
	# Xóa các nút kỹ năng cũ
	for child in grid_container.get_children():
		child.queue_free()

	# Tạo các nút kỹ năng cho từng kỹ năng của nhân vật
	for skill_index in range(3, battler.actions.size()):
		var skill = battler.actions[skill_index]
		var skill_button = Button.new()
		skill_button.custom_minimum_size = Vector2(100, 100)  # Set fixed size to 128x128

		# Style the button for normal, hover, and pressed states
		#var normal_style = StyleBoxFlat.new()
		#normal_style.bg_color = Color(1, 1, 1, 0.3)  # Light gray with some transparency
		#skill_button.add_theme_stylebox_override("normal", normal_style)
#
		#var hover_style = StyleBoxFlat.new()
		#hover_style.bg_color = Color(1, 1, 1, 0.5)  # Slightly darker on hover
		#skill_button.add_theme_stylebox_override("hover", hover_style)
#
		#var pressed_style = StyleBoxFlat.new()
		#pressed_style.bg_color = Color(1, 1, 1, 0.7)  # Darker gray when pressed
		#skill_button.add_theme_stylebox_override("pressed", pressed_style)

		# Set the icon and ensure it is centered and sized properly within the button
		skill_button.icon = skill.icon
		#skill_button.icon_scale = Vector2(2, 2)  # Scale the icon to fit the button size
		skill_button.icon_alignment = 1  # Center the icon horizontally
		skill_button.vertical_icon_alignment = 1  # Center the icon vertically
		skill_button.mouse_default_cursor_shape = 2  # Normal state cursor
		skill_button.expand_icon = true
		# Create style for normal state
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color(0.2, 0.2, 0.2, 0.9)  # Darker background
		normal_style.border_color = Color(0.8, 0.8, 0.8, 0.5)  # More visible border
		normal_style.set_corner_radius_all(5)
		normal_style.set_border_width_all(2)
		normal_style.set_expand_margin_all(5)

		# Create style for hover state
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.3, 0.3, 0.3, 1.0)  # More visible hover color
		hover_style.border_color = Color(1, 1, 1, 0.8)  # Brighter border on hover
		hover_style.set_corner_radius_all(5)
		normal_style.set_border_width_all(2)
		normal_style.set_expand_margin_all(5)
		# More visible glow effect
		hover_style.shadow_color = Color(0.5, 0.5, 1.0, 0.5)
		hover_style.shadow_size = 8

		# Create style for pressed state
		var pressed_style = StyleBoxFlat.new()
		pressed_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
		pressed_style.border_color = Color(0.3, 0.3, 1.0, 1.0)  # Blue-ish border when pressed
		pressed_style.set_corner_radius_all(5)
		normal_style.set_border_width_all(2)
		normal_style.set_expand_margin_all(5)
		# Stronger pressed effect
		pressed_style.shadow_color = Color(0.0, 0.0, 0.5, 0.8)
		pressed_style.shadow_size = 4
		# Add inset effect when pressed
		pressed_style.shadow_offset = Vector2(2, 2)

		# Apply styles to button
		skill_button.add_theme_stylebox_override("normal", normal_style)
		skill_button.add_theme_stylebox_override("hover", hover_style)
		skill_button.add_theme_stylebox_override("pressed", pressed_style)
		# Disable the button if the battler doesn't have enough energy to use the skill
		if battler.stats.energy < skill.energy_cost:
			skill_button.disabled = true  # Disable button if not enough energy
		else:
			# Connect only if button is enabled, passing both skill and index
			skill_button.connect("pressed", Callable(self, "_on_skill_selected").bind(skill, skill_index))

		# Add the skill button to the grid container
		grid_container.add_child(skill_button)
func _on_skill_selected(skill: BattlerAction, attack_index):
	if audiostream:
		audiostream.play()
	print("Selected skill: ", skill.label)
	var active_turn_queue = get_node("../Battlers")
	var current_battler = active_turn_queue.current_battler
	var action: BattlerAction = current_battler.actions[attack_index]
	var potential_targets: Array[Battler] = []
	var potential_allies: Array[Battler] = []
	var opponents:Array[Battler] = active_turn_queue._enemies if current_battler.is_player else active_turn_queue._party_members
	var allies:Array[Battler] = active_turn_queue._party_members if current_battler.is_player else active_turn_queue._enemies
	for opponent: Battler in opponents:
		if opponent.is_selectable:
			potential_targets.append(opponent)
	for ally in allies:
		if ally.is_selectable:
			potential_allies.append(ally)
	var target_group = potential_allies if action.targets_self else potential_targets
	for battler in active_turn_queue.indicators.keys():
		# Show indicators for potential targets only (assuming attack targets enemies)
		active_turn_queue.indicators[battler].visible = battler in target_group
	active_turn_queue.emit_signal("skill_selected", attack_index)
	hide()
