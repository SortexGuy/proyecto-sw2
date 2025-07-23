class_name SubCatItem
extends HBoxContainer

signal subcat_button_pressed(subcat: Dictionary)

@onready var subcategory_label: Label = %SubcategoryLabel
@onready var subcategory_button: Button = %SubcategoryButton

var subcat: Dictionary

func _ready() -> void:
	subcategory_button.pressed.connect(subcat_button_pressed.emit.bind(subcat))
	pass
