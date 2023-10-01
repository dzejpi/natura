extends Spatial


onready var blossoms = $Blossoms
onready var apples = $Fruits

onready var season_management_node = $"../../../SeasonManagementNode"
onready var woodenplanks = $"../../Woodenplanks"


var pollen_left = 5
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
	pass
