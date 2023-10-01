extends Spatial


onready var blossoms = $Blossoms
onready var fruits = $Fruits

onready var season_management_node = $"../../../SeasonManagementNode"

var pollen_left = 5
var is_flower = true
var is_fruit_ripe = false
var ripe_fruit = 5
var current_season = 0
var tooltip = ""


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
			fruits.hide()
			tooltip = ""
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
			tooltip = ""


func collect_berry():
	var berries_collected = 1
	
	if ripe_fruit > 0:
		ripe_fruit -= 1
		
	if ripe_fruit == 0:
		fruits.hide()
	
	return berries_collected
