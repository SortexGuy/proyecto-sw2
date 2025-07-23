class_name CatTemplate
extends VBoxContainer

signal subcat_button_pressed(cats_desc)

@export_file("*.tscn", "*.scn") var subcat_item_templ: String = "res://scenes/components/sub_cat_item.tscn"

@onready var category_label = %CategoryLabel
@onready var subcat_container = %SubCategories

var cat: Dictionary

func setup(category: Dictionary):
	cat = category
	category_label.text = cat.name.capitalize()
	for c in subcat_container.get_children():
		c.queue_free()
	await get_tree().process_frame
	var subcat_item_scene: PackedScene = load(subcat_item_templ)

	print(cat)
	for subcat in cat.subcategories.values():
		var item: SubCatItem = subcat_item_scene.instantiate()
		subcat_container.add_child(item)
		item.subcategory_label.text = (subcat.name as String).capitalize()
		item.setup(subcat)
		item.subcat_button_pressed.connect(_on_subcat_button_item_pressed)
		pass
	pass

func _on_subcat_button_item_pressed(subcat: Dictionary) -> void:
	print(subcat)
	subcat.cat_id = cat.id
	subcat_button_pressed.emit(subcat)
