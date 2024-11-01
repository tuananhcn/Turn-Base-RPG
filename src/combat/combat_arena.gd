## An arena is the background for a battle. It is a Control node that contains the battlers and the turn queue.
## It also contains the music that plays during the battle.
class_name CombatArena extends Control

@export var music: AudioStream

@onready var turn_queue: ActiveTurnQueue = $Battlers as ActiveTurnQueue
@onready var player_bars: VBoxContainer = $PlayerBars/NinePatchRect/VBoxContainer
@onready var enemy_bars: VBoxContainer = $EnemyBars/NinePatchRect/VBoxContainer
@onready var effect_label_builder: = $UI/EffectLabelBuilder as UIEffectLabelBuilder

func _ready():
	# If using a preloaded UI scene, ensure it's instanced and added to the tree
	# Access player_bars and enemy_bars after instancing UI
	effect_label_builder.setup(turn_queue.get_battlers())
	print(turn_queue._battlers)
	if player_bars and enemy_bars:
		generate_hp_bars(turn_queue._battlers)
	else:
		print("PlayerBars or EnemyBars not found.")
	for i in range(turn_queue._party_members.size()):
		var battler = turn_queue._party_members[i]
		update_hp_bar(battler, true, i+1)
		battler.health_updated.connect(func(_value: int) -> void:
			update_hp_bar(battler, true, i)
		)
		update_mana_bar(battler, true, i+1)
		battler.energy_updated.connect(func(_value: int) -> void:
			update_mana_bar(battler, true, i)
	)
	for i in range(turn_queue._enemies.size()):
		var battler = turn_queue._enemies[i]
		update_hp_bar(battler, false, i + 1)
		battler.health_updated.connect(func(_value: int) -> void:
			update_hp_bar(battler, false, i)
		)
		update_mana_bar(battler, false, i + 1)
		battler.energy_updated.connect(func(_value: int) -> void:
			update_mana_bar(battler, false, i)
	)
func generate_hp_bars(battlers):
	 #Clear existing bars for players
	for bar in player_bars.get_children():
		bar.queue_free()
#
	## Clear existing bars for enemies
	for bar in enemy_bars.get_children():
		bar.queue_free()
	
	# Generate player HP bars
	for i in battlers:
		#print(i.stats.health)
		var battler_container = player_bars.get_child(0).duplicate()  # Assuming first child is the template
		battler_container.name = "BarContainer_" + str(i)
		battler_container.get_node("BattlerName").text = i.name
		if i.is_player:
			player_bars.add_child(battler_container)
		else:
			enemy_bars.add_child(battler_container)
		battler_container.show()

func update_hp_bar(battler: Battler, is_player: bool, index: int):
	var battler_container
	if is_player:
		battler_container = player_bars.get_child(index)
	else:
		battler_container = enemy_bars.get_child(index)
	#if index  < player_bars.get_child_count():
		# Access HP bar and label
	var hp_bar = battler_container.get_node("Hp/HpProgressBar")
	var hp_label = battler_container.get_node("Hp/HpNum")
	# Update HP
	hp_bar.max_value = battler.stats.max_health
	hp_bar.value = battler.stats.health
	hp_label.text = "%d/%d" % [battler.stats.health, battler.stats.max_health]
func update_mana_bar(battler: Battler, is_player: bool, index: int):
	var battler_container
	if is_player:
		battler_container = player_bars.get_child(index)
	else:
		battler_container = enemy_bars.get_child(index)
	#if index < player_bars.get_child_count():
		# Access Mana bar and label
	var mana_bar = battler_container.get_node("Mana/ManaProgressBar")
	mana_bar.max_value = battler.stats.base_max_energy
	var mana_label = battler_container.get_node("Mana/ManaNum")
	# Update Mana
	mana_bar.value = battler.stats.energy
	mana_label.text = "%d/%d" % [battler.stats.energy, battler.stats.base_max_energy]
