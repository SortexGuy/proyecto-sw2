extends CanvasLayer

@onready var v_box_container: VBoxContainer = %VBoxContainer

func _ready() -> void:
	v_box_container.add_child(Button.new())
