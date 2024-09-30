extends Control
@onready var grid_container = $NinePatchRect/GridContainer
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
	for skill in battler.actions:
		var skill_button = Button.new()
		skill_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		skill_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		skill_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())

		#skill_button.text = skill.label
		skill_button.icon = skill.icon
		skill_button.connect("pressed", Callable(self, "_on_skill_selected").bind(skill))
		grid_container.add_child(skill_button)
func _on_skill_selected(skill: BattlerAction):
	print("Selected skill: ", skill.label)
	hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
