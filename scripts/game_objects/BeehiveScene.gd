extends Spatial


onready var bees_parent = $"../../Bees"

var honey_grams = 0
var tooltip = ""


func _ready():
	pass


func _process(_delta):
	if honey_grams >= 10:
		honey_grams -= 10
		spawn_new_bee()


func get_honey():
	var honey_amount = honey_grams
	honey_grams = 0
	tooltip = "Collect honey"
	
	return honey_amount

func spawn_new_bee():
	var new_bee = preload("res://scenes/game_objects/BeeScene.tscn").instance()
	bees_parent.add_child(new_bee)
	
	new_bee.transform.origin = global_transform.origin
	
