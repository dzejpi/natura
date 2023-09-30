extends KinematicBody


onready var beehives_parent = $"../../Beehives"
onready var flowers_parent = $"../../Flowers"

var is_carrying_honey = true
var is_closest_beehive_found = false
var is_closest_flower_found = false
var current_target = null
var bee_speed = 20
var rotation_speed = 2.0


func _ready():
	pass


func _process(delta):
	if is_carrying_honey:
		fly_towards_beehive(delta)
	else:
		fly_towards_flower(delta)


func find_closest_flower():
	var children = flowers_parent.get_children()
	var closest_distance = 20000

	for child in children:
		# Only look for flowers with some pollen left
		if child.pollen_left > 0:
			var distance = global_transform.origin.distance_to(child.global_transform.origin)
			if distance < closest_distance:
				closest_distance = distance
				current_target = child
				is_closest_flower_found = true


func fly_towards_flower(delta):
	if !is_closest_flower_found:
		print("Looking for the closest flower.")
		find_closest_flower()
	else:
		print("Flying towards the flower.")
		var direction = current_target.global_transform.origin - global_transform.origin

		# Smoothly interpolate the rotation
		var target_rotation = direction.angle_to(Vector3(0, 1, 0))
		var current_rotation = rotation_degrees.y
		rotation_degrees.y = lerp(current_rotation, target_rotation, rotation_speed * delta)

		# Move the bee
		if direction.length() > 1:
			translate(direction.normalized() * bee_speed * delta)
		else:
			if current_target:
				current_target.pollen_left -= 1
				is_carrying_honey = true
				is_closest_flower_found = false


func find_closest_beehive():
	var children = beehives_parent.get_children()
	var closest_distance = 20000

	for child in children:
		var distance = global_transform.origin.distance_to(child.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			current_target = child
			is_closest_beehive_found = true


func fly_towards_beehive(delta):
	if !is_closest_beehive_found:
		print("Looking for the closest beehive.")
		find_closest_beehive()
	else:
		print("Flying towards the beehive.")
		var direction = current_target.global_transform.origin - global_transform.origin

		# Smoothly interpolate the rotation
		var target_rotation = direction.angle_to(Vector3(0, 1, 0))
		var current_rotation = rotation_degrees.y
		rotation_degrees.y = lerp(current_rotation, target_rotation, rotation_speed * delta)

		# Move the bee
		if direction.length() > 1:
			translate(direction.normalized() * bee_speed * delta)
		else:
			if current_target:
				current_target.honey_grams += 1
				is_carrying_honey = false
				is_closest_beehive_found = false
		
