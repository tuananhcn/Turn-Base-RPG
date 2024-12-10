extends CanvasLayer

@export var items = [
	{
		"name": "BlueWand",
		"price": 1,
		"texture": preload("res://assets/items/wand_blue.atlastex"),
		"item_type": Inventory.ItemTypes.BLUE_WAND
	},
	{
		"name": "WAND1",
		"price": 1,
		"texture": preload("res://assets/items/wand1.atlastex"),
		"item_type": Inventory.ItemTypes.WAND1
	},
	{
		"name": "WAND2",
		"price": 1,
		"texture": preload("res://assets/items/wand2.atlastex"),
		"item_type": Inventory.ItemTypes.WAND2
	},
	{
		"name": "WAND3",
		"price": 1,
		"texture": preload("res://assets/items/wand3.atlastex"),
		"item_type": Inventory.ItemTypes.WAND3
	},
	{
		"name": "SWORD1",
		"price": 1,
		"texture": preload("res://assets/items/sword1.atlastex"),
		"item_type": Inventory.ItemTypes.SWORD1
	},
	{
		"name": "SWORD2",
		"price": 1,
		"texture": preload("res://assets/items/sword2.atlastex"),
		"item_type": Inventory.ItemTypes.SWORD2
	},
	{
		"name": "SWORD3",
		"price": 1,
		"texture": preload("res://assets/items/sword3.atlastex"),
		"item_type": Inventory.ItemTypes.SWORD3
	},
	{
		"name": "SHIELD1",
		"price": 1,
		"texture": preload("res://assets/items/shield1.atlastex"),
		"item_type": Inventory.ItemTypes.SHIELD1
	},
	{
		"name": "SHIELD2",
		"price": 1,
		"texture": preload("res://assets/items/shield2.atlastex"),
		"item_type": Inventory.ItemTypes.SHIELD2
	},
	{
		"name": "Hp Potion",
		"price": 1,
		"texture": preload("res://assets/items/HpPotion.atlastex"),
		"item_type": Inventory.ItemTypes.HP
	},
	{
		"name": "Energy Potion",
		"price": 1,
		"texture": preload("res://assets/items/EnergyPotion.atlastex"),
		"item_type": Inventory.ItemTypes.EP
	}
]

@onready var anim_player = $AnimationPlayer
@onready var grid_container = $Panel/ScrollContainer/GridContainer
@onready var player_gold_label = $Panel/PlayerGold  # Will display coin count now
@onready var message_label = $Panel/MessageLabel # Label for displaying messages

func _ready() -> void:
	update_shop_ui()
	Dialogic.signal_event.connect(DialogicSignal)
var is_shop_open = false

func _input(_event):
	if not is_shop_open:
		return 
func play_trans_in():
	is_shop_open = true
	anim_player.play("TransIn")

func play_trans_out():
	is_shop_open = false
	anim_player.play("TransOut")

func _on_button_pressed() -> void:
	if is_shop_open:
		play_trans_out()

func update_shop_ui():
	# Clear the current item list
	for child in grid_container.get_children():
		child.queue_free()  # Remove existing item containers

	# Load the player's inventory
	var inventory = Inventory.restore()
	# Get the player's current coin count
	var current_coins = inventory.get_item_count(Inventory.ItemTypes.COIN)
	# Update the player's coin display
	player_gold_label.text = "Coins: " + str(current_coins)

	# Loop through each item in the shop and create UI elements
	for item in items:
		var item_name = item["name"]
		var item_price = item["price"]
		var item_atlas_texture = item["texture"]

		# Create a new VBoxContainer for each item
		var new_item_container = VBoxContainer.new()

		# Create and add the item image using AtlasTexture
		var item_image = TextureRect.new()
		item_image.texture = item_atlas_texture
		item_image.custom_minimum_size = Vector2(64, 64)
		item_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		new_item_container.add_child(item_image)

		# Create and add the item name label
		var name_label = Label.new()
		name_label.text = item_name
		new_item_container.add_child(name_label)

		# Create and add the item price label
		var price_label = Label.new()
		price_label.text = "Price: " + str(item_price) + " coins"
		new_item_container.add_child(price_label)

		# Create and add the buy button
		var buy_button = Button.new()
		buy_button.text = "Buy"
		buy_button.connect("pressed", Callable(self, "_on_buy_button_pressed").bind(item))
		new_item_container.add_child(buy_button)

		# Add the new item container to the GridContainer
		grid_container.add_child(new_item_container)

# Called when the player presses the buy button
func _on_buy_button_pressed(item):
	var item_name = item["name"]
	var item_price = item["price"]
	var item_type = item["item_type"]

	# Load the player's inventory
	var inventory = Inventory.restore()
	# Check if the player has enough coins
	var current_coins = inventory.get_item_count(Inventory.ItemTypes.COIN)

	if current_coins >= item_price:
		# Deduct the item price from the player's coins
		inventory.remove(Inventory.ItemTypes.COIN, item_price)
		# Add the purchased item to the player's inventory
		inventory.add(item_type, 1)
		# Save the updated inventory
		inventory.save()
		# Update the shop UI to reflect the purchase
		update_shop_ui()
		message_label.text = "Bought " + item_name + " for " + str(item_price) + " coins!"
	else:
		message_label.text = "Not enough coins to buy " + item_name + "."
func DialogicSignal(argument: String):
	if argument == "open_shop" and not is_shop_open:
		play_trans_in()
