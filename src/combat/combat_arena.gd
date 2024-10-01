## An arena is the background for a battle. It is a Control node that contains the battlers and the turn queue.
## It also contains the music that plays during the battle.
class_name CombatArena extends Control

@export var music: AudioStream

@onready var turn_queue: ActiveTurnQueue = $Battlers
@onready var player_bars: VBoxContainer = $PlayerBars/NinePatchRect/VBoxContainer
@onready var enemy_bars: VBoxContainer = $EnemyBars/NinePatchRect/VBoxContainer

func _ready():
	# If using a preloaded UI scene, ensure it's instanced and added to the tree
	# Access player_bars and enemy_bars after instancing UI
	if player_bars and enemy_bars:
		generate_hp_bars(turn_queue._party_members.size(), turn_queue._enemies.size())
	else:
		print("PlayerBars or EnemyBars not found.")
	for i in range(turn_queue._party_members.size()):
		var battler = turn_queue._party_members[i]
		update_hp_bar(battler, true, i)
		battler.health_updated.connect(func(_value: int) -> void:
			update_hp_bar(battler, true, i)
		)
		update_mana_bar(battler, true, i)
		battler.energy_updated.connect(func(_value: int) -> void:
			update_mana_bar(battler, true, i)
	)
	for i in range(turn_queue._enemies.size()):
		var battler = turn_queue._enemies[i]
		update_hp_bar(battler, false, i)
		battler.health_updated.connect(func(_value: int) -> void:
			update_hp_bar(battler, false, i)
		)
		update_mana_bar(battler, false, i)
		battler.energy_updated.connect(func(_value: int) -> void:
			update_mana_bar(battler, false, i)
	)
func generate_hp_bars(players: int, enemies: int):
	 #Clear existing bars for players
	for bar in player_bars.get_children():
		bar.queue_free()
#
	## Clear existing bars for enemies
	for bar in enemy_bars.get_children():
		bar.queue_free()

	# Generate player HP bars
	for i in range(players):
		var player_battler_container = player_bars.get_child(0).duplicate()  # Assuming first child is the template
		player_battler_container.name = "PlayerBarContainer_" + str(i)
		player_battler_container.get_node("BattlerName").text = turn_queue._party_members[i].name
		player_bars.add_child(player_battler_container)
		player_battler_container.show()

	# Generate enemy HP bars
	for i in range(enemies):
		var enemy_battler_container = enemy_bars.get_child(0).duplicate()  # Assuming first child is the template
		enemy_battler_container.name = "EnemyBarContainer_" + str(i)
		enemy_battler_container.get_node("BattlerName").text = turn_queue._enemies[i].name
		enemy_bars.add_child(enemy_battler_container)
		enemy_battler_container.show()
func update_hp_bar(battler: Battler, is_player: bool, index: int):
	var hp_percent: float = float(battler.stats.health) / float(battler.stats.max_health) * 100.0
	if is_player:
		if index  < player_bars.get_child_count():
			var player_battler_container = player_bars.get_child(index )
			print(player_bars.get_child(index))
			# Access HP bar and label
			var hp_bar = player_battler_container.get_node("Hp/HpProgressBar")
			var hp_label = player_battler_container.get_node("Hp/HpNum")
			
			# Update HP
			hp_bar.value = hp_percent
			hp_label.text = "%d/%d" % [battler.stats.health, battler.stats.max_health]
	else:
		var enemy_battler_container = enemy_bars.get_child(index)
		# Access HP bar and label
		print(enemy_battler_container)
		var hp_bar = enemy_battler_container.get_node("Hp/HpProgressBar")
		var hp_label = enemy_battler_container.get_node("Hp/HpNum")
		# Update HP
		hp_bar.value = hp_percent
		hp_label.text = "%d/%d" % [battler.stats.health, battler.stats.max_health]
func update_mana_bar(battler: Battler, is_player: bool, index: int):
	var mana_percent: float = float(battler.stats.energy) / float(battler.stats.base_max_energy) * 100.0
	if is_player:
		if index < player_bars.get_child_count():
			var player_battler_container = player_bars.get_child(index)
		# Access Mana bar and label
			var mana_bar = player_battler_container.get_node("Mana/ManaProgressBar")
			var mana_label = player_battler_container.get_node("Mana/ManaNum")
		# Update Mana
			mana_bar.value = mana_percent
			mana_label.text = "%d/%d" % [battler.stats.energy, battler.stats.base_max_energy]
	else:
		if index + 1 < enemy_bars.get_child_count():
			var enemy_battler_container = enemy_bars.get_child(index)
		# Access Mana bar and label
			var mana_bar = enemy_battler_container.get_node("Mana/ManaProgressBar")
			var mana_label = enemy_battler_container.get_node("Mana/ManaNum")
		# Update Mana
			mana_bar.value = mana_percent
			mana_label.text = "%d/%d" % [battler.stats.energy, battler.stats.base_max_energy]
