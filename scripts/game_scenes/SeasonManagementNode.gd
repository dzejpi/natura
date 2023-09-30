extends Node


onready var player = $"../Player"

var ground_material = preload("res://3d/world/export_triangulated/ground_material.material")

# Colors had to be divided by 255 and then rounded to two decimals for this to work for some reason
var spring_ground_color = Color(0.39, 0.78, 0.30)
var summer_ground_color = Color(0.24, 0.54, 0.28)
var autumn_ground_color = Color(1.00, 0.68, 0.20)
var winter_ground_color = Color(1.00, 1.00, 1.00)

var current_season = 1
var season_length = 60
var season_progress = season_length


func _ready():
	set_season_textures()


func _process(delta):
	count_season_progress(delta)
	
	
func count_season_progress(delta):
	if season_progress > 0:
		season_progress -= 1 * delta
		player.season_sprite.rotation_degrees -= (1.5 * delta)
		print("There is " + String(season_progress) + " seconds left.")
	else:
		season_progress = season_length
		if current_season < 4:
			current_season += 1
			set_season_textures()
		else:
			# Go back to spring
			current_season = 0
			set_season_textures()
		
		print("Current season is: " + String(current_season))


func set_season_textures():
	match current_season:
		# Spring
		0:
			ground_material.albedo_color = spring_ground_color
		
		# Summer
		1:
			ground_material.albedo_color = summer_ground_color
		
		# Autumn
		2:
			ground_material.albedo_color = autumn_ground_color
		
		# Winter
		3:
			ground_material.albedo_color = winter_ground_color
