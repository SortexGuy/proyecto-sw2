extends CanvasLayer

@onready var botones = get_parent().get_node("../Interfaces/WorldOverlayLayer")

#Inicializar botones
func _ready():
	botones.visible = true
	
