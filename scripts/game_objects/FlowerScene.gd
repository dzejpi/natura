extends Spatial


onready var blossoms = $Blossoms
onready var fruits = $Fruits

onready var season_management_node = $"../../../SeasonManagementNode"
onready var butterflies_parent = $"../../Butterflies"

var pollen_left = 5
var is_flower = true
var is_fruit_ripe = false
var ripe_fruit = 5
var current_season = 0
var tooltip = ""


func _ready():
	current_season = season_management_node.current_season
	change_season(season_management_node.current_season)
	
	var random_value = randf()
	print("Random value is: " + String(random_value))
	if random_value <= 0.33:
		spawn_butterfly()


func _process(_delta):
	if current_season != season_management_node.current_season:
		current_season = season_management_node.current_season
		change_season(season_management_node.current_season)


func change_season(season):
	match season:
		# Spring
		0:
			show()
			blossoms.show()
			fruits.hide()
			tooltip = ""
			pollen_left = 5
			ripe_fruit = 0
		# Summer
		1:
			blossoms.show()
			fruits.hide()
			tooltip = ""
			ripe_fruit = 0
		# Autumn
		2:
			blossoms.hide()
			fruits.show()
			is_fruit_ripe = true
			tooltip = "Collect berries"
			ripe_fruit = 5
		# Winter
		3:
			hide()
			blossoms.hide()
			fruits.hide()
			ripe_fruit = 0
			pollen_left = 0
			tooltip = ""


func collect_berry():
	var berries_collected = 1
	
	if ripe_fruit > 0:
		ripe_fruit -= 1
		
	if ripe_fruit == 0:
		fruits.hide()
	
	return berries_collected


func spawn_butterfly():
	var new_butterfly = preload("res://scenes/game_objects/ButterflyScene.tscn").instance()
	
	butterflies_parent.add_child(new_butterfly)
	new_butterfly.transform.origin = global_transform.origin
	new_butterfly.transform.origin.y += 2
