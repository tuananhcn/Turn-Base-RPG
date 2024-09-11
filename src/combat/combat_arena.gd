## An arena is the background for a battle. It is a Control node that contains the battlers and the turn queue.
## It also contains the music that plays during the battle.
class_name CombatArena extends Control

@export var music: AudioStream

@onready var turn_queue: ActiveTurnQueue = $Battlers
var template_bar: TextureProgressBar = null
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
		battler.health_updated.connect(func(_value: int) -> void:
			update_hp_bar(battler, true, i)
		)

	for i in range(turn_queue._enemies.size()):
		var battler = turn_queue._enemies[i]
		battler.health_updated.connect(func(_value: int) -> void:
			update_hp_bar(battler, false, i)
		)
func generate_hp_bars(players: int, enemies: int):
	# Clear existing bars for players
	#for bar in player_bars.get_children():
		#bar.queue_free()
#
	## Clear existing bars for enemies
	#for bar in enemy_bars.get_children():
		#bar.queue_free()

	# Generate player HP bars
	for i in range(players):
		var player_hp_bar = player_bars.get_child(0).duplicate()
		player_hp_bar.name = "PlayerBar_" + str(i)
		player_bars.add_child(player_hp_bar)
		player_hp_bar.show()

	# Generate enemy HP bars
	for i in range(enemies):
		var enemy_hp_bar = enemy_bars.get_child(0).duplicate()
		enemy_hp_bar.name = "EnemyBar_" + str(i)
		enemy_bars.add_child(enemy_hp_bar)
		enemy_hp_bar.show()
func update_hp_bar(battler: Battler, is_player: bool, index: int):
	var hp_percent: float = float(battler.stats.health) / float(battler.stats.max_health) * 100.0

	if is_player:
		if index +1 < player_bars.get_child_count():
			var player_hp_bar = player_bars.get_child(index+1)
			player_hp_bar.value = hp_percent  # Update the bar value with percentage
	else:
		if index +1 < enemy_bars.get_child_count():
			var enemy_hp_bar = enemy_bars.get_child(index+1)
			enemy_hp_bar.value = hp_percent  # Update the bar value with percentage
