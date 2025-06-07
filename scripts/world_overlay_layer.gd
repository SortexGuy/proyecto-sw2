extends CanvasLayer

@onready var side_panel_button: Button = %SidePanelButton
@onready var add_model_button: Button = %AddModelButton

signal side_panel_button_pressed
signal add_model_button_pressed

func _ready() -> void:
	side_panel_button.pressed.connect(side_panel_button_pressed.emit)
	add_model_button.pressed.connect(add_model_button_pressed.emit)
