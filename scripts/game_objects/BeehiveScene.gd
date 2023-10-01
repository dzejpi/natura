extends Spatial


onready var bees_parent = $"../../Bees"

var honey_grams = 0
var tooltip = "Collect honey"


func _ready():
	pass


func _process(_delta):
	tooltip = "Collect honey (" + String(honey_grams) + ")"
	
	if honey_grams >= 8:
		honey_grams -= 8
		spawn_new_bee()


func get_honey():
	var honey_amount = honey_grams
	honey_grams = 0
	return honey_amount

func spawn_new_bee():
	var new_bee = preload("res://scenes/game_objects/BeeScene.tscn").instance()
	bees_parent.add_child(new_bee)
	
	new_bee.transform.origin = global_transform.origin
	
