extends KinematicBody


onready var season_management_node = $"../../../SeasonManagementNode"

onready var butterfly_animation_player = $ButterflyAnimationPlayer
onready var trees_parent = $"../../Trees"
onready var shelters = $"../../Shelters"

var current_target = null
var is_closest_tree_found = false
var is_closest_shelter_found = false

var butterfly_speed = 10
var butterfly_countdown_value = 2.0
var butterfly_countdown = butterfly_countdown_value

var is_winter = false
var current_season = 0


func _ready():
	current_season = season_management_node.current_season
	check_for_winter()
	butterfly_animation_player.play("fly")


func _process(delta):
	check_for_winter()
	
	if is_winter:
		fly_towards_tree(delta)
	else:
		fly_towards_tree(delta)


func find_closest_tree():
	var children = trees_parent.get_children()
	var closest_distance = 20000

	for child in children:
		if child.pollen_left > 0:
			var distance = global_transform.origin.distance_to(child.global_transform.origin)
			if distance < closest_distance:
				closest_distance = distance
				current_target = child
				is_closest_tree_found = true


func find_closest_shelter():
	var children = shelters.get_children()
	var closest_distance = 20000

	for child in children:
		var distance = global_transform.origin.distance_to(child.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			current_target = child
			is_closest_shelter_found = true


func fly_towards_tree(delta):
	if !is_closest_tree_found:
		find_closest_tree()
	else:
		var direction = current_target.global_transform.origin - global_transform.origin
		
		# Move the bee
		if direction.length() < 0.2:
			if butterfly_countdown > 0:
				butterfly_countdown -= 1 * delta
			else:
				butterfly_countdown = butterfly_countdown_value
				
				if current_target:
					current_target.pollen_left -= 1
					is_closest_tree_found = false
		else:
			look_at(current_target.global_transform.origin, Vector3(0, 1, 0))
			translate(Vector3(0, 0, -butterfly_speed * delta))


func check_for_winter():
	if current_season != season_management_node.current_season:
		current_season = season_management_node.current_season
		if current_season == 3:
			is_winter = true
		else:
			is_winter = false
