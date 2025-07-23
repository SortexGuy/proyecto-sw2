class_name SubCatItem
extends HBoxContainer

signal subcat_button_pressed(subcat: Dictionary)

@onready var subcategory_label: Label = %SubCategoryLabel
@onready var subcategory_button: Button = %SubCategoryButton

var subcat: Dictionary

func setup(_subcat: Dictionary) -> void:
	subcat = _subcat
	subcategory_button.pressed.connect(subcat_button_pressed.emit.bind(subcat))
	pass
