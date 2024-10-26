extends Button

@onready var pegou = $pegou

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Replace with function body.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://main.tscn")
