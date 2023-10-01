extends StaticBody


var plank_collected = false
var tooltip = "Collect wooden plank"

func _process(delta):
	if plank_collected:
		queue_free()


func collect_plank():
	var collected_planks = 1
	plank_collected = true
	return collected_planks
