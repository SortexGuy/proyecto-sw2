class_name SampleProjectItem
extends HBoxContainer

@onready var project_label: Label = %ProjectLabel
@onready var preview_button: Button = %PreviewButton
@onready var delete_button: Button = %DeleteButton

@export var project_url: String
@export var project_preview_url: String
