extends Spatial


onready var blossoms = $Blossoms
onready var apples = $Fruits

onready var season_management_node = $"../../../SeasonManagementNode"
onready var wooden_planks = $"../../Woodenplanks"


var pollen_left = 5
var is_fruit_ripe = false
var ripe_fruit = 5
var current_season = 0
var tooltip = ""

var objects_to_generate = 3
var x_offset_range = 3.5
var z_offset_range = 3.5


func _ready():
	current_season = season_management_node.current_season
	change_season(season_management_node.current_season)


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
			apples.hide()
			tooltip = ""
			ripe_fruit = 0
		# Summer
		1:
			blossoms.show()
			apples.hide()
			tooltip = ""
			ripe_fruit = 0
		# Autumn
		2:
			blossoms.hide()
			apples.show()
			is_fruit_ripe = true
			tooltip = "Collect apples"
			ripe_fruit = 5
		# Winter
		3:
			hide()
			generate_planks()
			blossoms.hide()
			apples.hide()
			ripe_fruit = 0
			tooltip = ""


func collect_apple():
	var apples_collected = 1
	
	if ripe_fruit > 0:
		ripe_fruit -= 1
		
	if ripe_fruit == 0:
		apples.hide()
	
	return apples_collected


func generate_planks():
	for i in range(objects_to_generate):
		var original_position = self.global_transform.origin
		
		var x_offset = rand_range(-x_offset_range, x_offset_range)
		var z_offset = rand_range(-z_offset_range, z_offset_range)
		
		var new_plank = preload("res://scenes/game_objects/WoodenPlankScene.tscn").instance()
		
		wooden_planks.add_child(new_plank)
		new_plank.transform.origin = original_position + Vector3(x_offset, 0.5, z_offset)
