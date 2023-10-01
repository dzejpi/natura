extends Spatial


var honey_grams = 0
var tooltip = ""


func _ready():
	pass


func _process(_delta):
	pass


func get_honey():
	var honey_amount = honey_grams
	honey_grams = 0
	tooltip = "Collect honey"
	
	return honey_amount
