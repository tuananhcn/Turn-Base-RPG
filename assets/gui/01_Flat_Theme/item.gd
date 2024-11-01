extends Control
@onready var grid_container = $NinePatchRect/GridContainer
@onready var custom_theme = preload("res://src/gui/mainmenu/new_theme.tres")
@onready var inventory = Inventory.restore()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
func show_items():
	for child in grid_container.get_children():
		child.queue_free()

	# Show HP and EP items if quantity > 0
	for item_type in [Inventory.ItemTypes.HP, Inventory.ItemTypes.EP]:
		var item_count = inventory.get_item_count(item_type)
		if item_count > 0:
			var item_button = Button.new()
			item_button.custom_minimum_size = Vector2(170, 90)
			item_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
			item_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
			item_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
			
			# Create an HBoxContainer for icon and label alignment
			var hbox = HBoxContainer.new()
			hbox.custom_minimum_size = Vector2(160, 80)
			
			# Icon setup
			var icon_texture = Inventory.get_item_icon(item_type)
			var icon_rect = TextureRect.new()
			icon_rect.texture = icon_texture
			icon_rect.custom_minimum_size = Vector2(64, 64)  # Scale the icon up
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # Keep aspect ratio
			hbox.add_child(icon_rect)

			# Label setup for item count
			var item_label = Label.new()
			item_label.text = str(item_count)
			item_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			item_label.custom_minimum_size = Vector2(50, 64)  # Adjust as needed
			hbox.add_child(item_label)
			
			# Add the HBoxContainer to the button
			item_button.add_child(hbox)
			
			# Connect button press to a function to use the item on a target
			item_button.connect("pressed", Callable(self, "_on_item_selected").bind(item_type))
			grid_container.add_child(item_button)

func _on_item_selected(item_type: Inventory.ItemTypes):
	# Handle item use here (like selecting a target to restore HP or EP)
	
	var active_turn_queue = get_node("../Battlers")
	var current_battler = active_turn_queue.current_battler
	var item_action: ItemAction = current_battler.actions[2]
	if item_type == Inventory.ItemTypes.HP:
		item_action.item_name = "HP Potion"
		item_action.restore_hp = 30  # Set HP restoration for HP potion
		item_action.restore_energy = 0
	elif item_type == Inventory.ItemTypes.EP:
		item_action.item_name = "EP Potion"
		item_action.restore_hp = 0
		item_action.restore_energy = 2  # Set energy restoration for Energy potion
	var action: BattlerAction = current_battler.actions[2]
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
	active_turn_queue.emit_signal("skill_selected", 2)
	hide()
