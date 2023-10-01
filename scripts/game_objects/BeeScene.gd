extends KinematicBody


onready var beehives_parent = $"../../Beehives"
onready var flowers_parent = $"../../Flowers"
onready var bee_animation_player = $BeeAnimationPlayer

var is_carrying_honey = true
var is_closest_beehive_found = false
var is_closest_flower_found = false
var current_target = null
var bee_speed = 10
var rotation_speed = 100.0
var current_rotation = null

var bee_countdown_value = 2.0
var bee_countdown = bee_countdown_value


func _ready():
	bee_animation_player.play("fly")


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


func find_closest_beehive():
	var children = beehives_parent.get_children()
	var closest_distance = 20000

	for child in children:
		var distance = global_transform.origin.distance_to(child.global_transform.origin)
		if distance < closest_distance:
			closest_distance = distance
			current_target = child
			is_closest_beehive_found = true


func fly_towards_flower(delta):
	if !is_closest_flower_found:
		#print("Looking for the closest flower.")
		find_closest_flower()
	else:
		#print("Flying towards the flower.")
		#print("My rotation is: " + String(rotation_degrees))
		var direction = current_target.global_transform.origin - global_transform.origin
		
		# Move the bee
		if direction.length() < 0.2:
			if bee_countdown > 0:
				bee_countdown -= 1 * delta
			else:
				bee_countdown = bee_countdown_value
				
				if current_target:
					current_target.pollen_left -= 1
					is_carrying_honey = true
					is_closest_flower_found = false
		else:
			look_at(current_target.global_transform.origin, Vector3(0, 1, 0))
			translate(Vector3(0, 0, -bee_speed * delta))


func fly_towards_beehive(delta):
	if !is_closest_beehive_found:
		#print("Looking for the closest beehive.")
		find_closest_beehive()
	else:
		#print("Flying towards the beehive.")
		#print("My rotation is: " + String(rotation_degrees))
		var direction = current_target.global_transform.origin - global_transform.origin
		
		# Move the bee
		if direction.length() < 0.1:
			if bee_countdown > 0:
				bee_countdown -= 1 * delta
			else:
				bee_countdown = bee_countdown_value
				if current_target:
					current_target.honey_grams += 1
					is_carrying_honey = false
					is_closest_beehive_found = false
		else:
			look_at(current_target.global_transform.origin, Vector3(0, 1, 0))
			translate(Vector3(0, 0, -bee_speed * delta))
