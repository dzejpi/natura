extends KinematicBody


onready var player_head = $PlayerHead
onready var ray = $PlayerHead/RayCast

onready var pause_scene = $UI/Pause/PauseScene
onready var game_over_scene = $UI/GameEnd/GameOverScene
onready var game_won_scene = $UI/GameEnd/GameWonScene

onready var animation_player = $PlayerHead/PlayerCamera/AnimationPlayer
onready var player_camera = $PlayerHead/PlayerCamera

onready var axe = $PlayerHead/PlayerHands/Axe

# UI
onready var player_ui = $UI/PlayerUI
onready var tooltip = $UI/PlayerUI/Tooltip
onready var action_tooltip = $UI/PlayerUI/ActionTooltip/ActionLabel

onready var season_sprite = $UI/PlayerUI/SeasonUINode/SeasonSprite

onready var inventory = $UI/PlayerUI/Inventory

onready var info_ui = $UI/PlayerUI/InfoUI
onready var wood_plank_label = $UI/PlayerUI/InfoUI/WoodPlankLabel
onready var health_label = $UI/PlayerUI/InfoUI/HealthLabel
onready var health_amount_label = $UI/PlayerUI/InfoUI/HealthAmountLabel
onready var wood_plank_label_2 = $UI/PlayerUI/InfoUI/WoodPlankLabel2
onready var wood_plank_label_3 = $UI/PlayerUI/InfoUI/WoodPlankLabel3
onready var tree_seeds_label = $UI/PlayerUI/InfoUI/TreeSeedsLabel
onready var flower_seeds_label = $UI/PlayerUI/InfoUI/FlowerSeedsLabel
onready var honey_label = $UI/PlayerUI/InfoUI/HoneyLabel
onready var berry_label = $UI/PlayerUI/InfoUI/BerryLabel
onready var apple_label = $UI/PlayerUI/InfoUI/AppleLabel


# Placing node
onready var placing_node = $UI/PlacingNode

onready var preview_handmade_beehive = $UI/PlacingNode/BeehivePreview
onready var preview_flowers = $UI/PlacingNode/Flowers
onready var preview_fireplace = $UI/PlacingNode/Fireplace
onready var preview_shelter = $UI/PlacingNode/ShelterPreview
onready var preview_tree_one = $UI/PlacingNode/TreePreview

onready var world_beehives = $"../GameObjects/Beehives"
onready var world_flowers = $"../GameObjects/Flowers"
onready var world_trees = $"../GameObjects/Trees"
onready var world_fireplaces = $"../GameObjects/Fireplaces"
onready var world_shelters = $"../GameObjects/Shelters"

var is_game_over = false
var is_game_won = false

var speed = 6
var jump = 6
var gravity = 16

var basic_fov = 70
var increased_fov = 90
var current_fov = increased_fov

var ground_acceleration = 8
var air_acceleration = 2
var acceleration = ground_acceleration

var slide_prevention = 10
var mouse_sensitivity = 0.75

var direction = Vector3()
var velocity = Vector3()
var movement = Vector3()
var gravity_vector = Vector3()

var is_on_ground = true
var is_paused = false

var inventory_item_selected = 0
var current_inventory_item = 2

# Name of the observed object for debugging purposes
var observed_object = "" 

# Amounts of items and food
var flower_seeds = 10
var tree_seeds = 3
var wood_amount = 4

var honey_amount = 2
var berries_amount = 4
var apple_amount = 6

var honey_health = 20
var berries_health = 10
var apple_health = 10

var player_health = 100


func _ready():
	is_paused = false
	player_camera.fov = current_fov
	current_fov = increased_fov
	pause_scene.is_game_paused = false
	pause_scene.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	transition_overlay.fade_out()
	check_game_end()
	check_inventory_changes()
	tooltip.set_tooltip("Walk with [WASD]", "move_up")
	#info_ui.hide()


func _input(event):	
	if !pause_scene.is_game_paused && !is_game_over && !is_game_won:
		
		# Hack that mostly forces the game to capture cursor in HTML5 after player presses Escape
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
			player_head.rotation_degrees.x = clamp(player_head.rotation_degrees.x - event.relative.y * mouse_sensitivity / 10, -90, 90)

		direction = Vector3()
		direction.z = -Input.get_action_strength("move_up") + Input.get_action_strength("move_down")
		direction.x = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
		direction = direction.normalized().rotated(Vector3.UP, rotation.y)
		
	# Handling the options menu
	if Input.is_action_just_pressed("game_pause"):
		if !is_game_over && !is_game_won:
			handle_pause_change()
			
	# Selecting items from inventory manually
	if Input.is_action_just_pressed("inventory_zero"):
		inventory.selected_item = 9
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_one"):
		inventory.selected_item = 0
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_two"):
		inventory.selected_item = 1
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_three"):
		inventory.selected_item = 2
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_four"):
		inventory.selected_item = 3
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_five"):
		inventory.selected_item = 4
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_six"):
		inventory.selected_item = 5
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_seven"):
		inventory.selected_item = 6
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_eight"):
		inventory.selected_item = 7
		check_inventory_changes()
		inventory.change_selection()
		
	if Input.is_action_just_pressed("inventory_nine"):
		inventory.selected_item = 8
		check_inventory_changes()
		inventory.change_selection()


func _process(delta):
	check_game_end()
	check_pause_update()
	check_inventory_changes()
	manage_hunger(delta)
	update_info_ui()
	adjust_placing_node()
	
	if player_health < 15:
		action_tooltip.text = "You're starving, eat something!"
	else:
		action_tooltip.text = ""
	
	# If player is looking at something
	if ray.is_colliding():
		var collision_object = ray.get_collider().name
		
		if collision_object != observed_object:
			observed_object = collision_object
			#print("Player is looking at: " + observed_object + ".")
			
		var colliding_object = ray.get_collider()
		# Player is looking at berries
		if colliding_object.has_method("collect_berry"):
			if colliding_object.ripe_fruit > 0:
				action_tooltip.text = colliding_object.tooltip
				if Input.is_action_just_pressed("eat_action"):
					colliding_object.collect_berry()
					berries_amount += 1
					
					# Get flower seeds
					var random_value = randf()
					if random_value <= 0.5:
						flower_seeds += 1
		
		# Player is looking at apples
		if colliding_object.has_method("collect_apple"):
			if colliding_object.ripe_fruit > 0:
				action_tooltip.text = colliding_object.tooltip
				if Input.is_action_just_pressed("eat_action"):
					colliding_object.collect_apple()
					apple_amount += 1
					
					# Get tree seeds
					var random_value = randf()
					if random_value <= 0.25:
						tree_seeds += 1
		
		# Player is looking at beehive
		if colliding_object.has_method("get_honey"):
			if colliding_object.honey_grams > 0:
				action_tooltip.text = colliding_object.tooltip
				if Input.is_action_just_pressed("eat_action"):
					honey_amount += colliding_object.get_honey()
					
		# Player is looking at plank
		if colliding_object.has_method("collect_plank") && current_inventory_item == 1:
			action_tooltip.text = colliding_object.tooltip
			if Input.is_action_just_pressed("eat_action"):
				wood_amount += colliding_object.collect_plank()
	else:
		var collision_object = "nothing"
		if collision_object != observed_object:
			observed_object = collision_object
			print("Player is looking at: nothing.")
			
	if player_health <= 0:
		is_game_over = true


func _physics_process(delta):
	if Input.is_action_just_pressed("eat_action"):
		process_click_action()
		
		if current_inventory_item == 1:
			animation_player.play("Axe Swing")
	
	if is_on_floor():
		gravity_vector = -get_floor_normal() * slide_prevention
		acceleration = ground_acceleration
		if !is_on_ground:
			if !(animation_player.current_animation == "Axe Swing"):
				animation_player.play("Jump Land")
		
		is_on_ground = true
	else:
		if is_on_ground:
			gravity_vector = Vector3.ZERO
			is_on_ground = false
		else:
			gravity_vector += Vector3.DOWN * gravity * delta
			acceleration = air_acceleration
	
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		is_on_ground = false
		gravity_vector = Vector3.UP * jump

	if Input.is_action_pressed("move_sprint"):
		decrease_fov()
		velocity = velocity.linear_interpolate(direction * speed * 0.25, acceleration * delta)
	else:
		increase_fov()
		velocity = velocity.linear_interpolate(direction * speed * 2, acceleration * delta)
	
	movement.z = velocity.z + gravity_vector.z
	movement.x = velocity.x + gravity_vector.x
	movement.y = gravity_vector.y
	
	var _player_movement = move_and_slide(movement, Vector3.UP)
	
	if !is_game_over && !is_game_won && !is_paused:
		if direction != Vector3():
			if !(animation_player.current_animation == "Axe Swing"):
				animation_player.play("Head Bob")
	
	#if Input.is_action_just_pressed("ui_status"):
	#	info_ui.show()
		
	#if Input.is_action_just_released("ui_status"):
	#	info_ui.hide()


func check_pause_update():
	if is_paused != pause_scene.is_game_paused:
		handle_on_click_pause_change()


func handle_on_click_pause_change():
	if pause_scene.is_game_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		is_paused = pause_scene.is_game_paused
			
		pause_scene.show()
		player_ui.hide()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_paused = pause_scene.is_game_paused
	
		pause_scene.hide()
		player_ui.show()


func handle_pause_change():
	if pause_scene.is_game_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		pause_scene.is_game_paused = false
		is_paused = pause_scene.is_game_paused
			
		pause_scene.hide()
		player_ui.show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_scene.is_game_paused = true
		is_paused = pause_scene.is_game_paused
	
		pause_scene.show()
		player_ui.hide()


func check_game_end():
	# Game is over in both cases - when player loses or wins
	if is_game_over:
		game_over_scene.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_scene.is_game_paused = false
		pause_scene.hide()
		player_ui.hide()
	elif is_game_won:
		game_won_scene.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_scene.is_game_paused = false
		pause_scene.hide()
		player_ui.hide()
	else:
		game_over_scene.hide()


func increase_fov():
	current_fov = player_camera.fov
	
	if current_fov < increased_fov:
		current_fov += 0.5
		change_fov(current_fov)


func decrease_fov():
	current_fov = player_camera.fov
	
	if current_fov > basic_fov:
		current_fov -= 0.5
		change_fov(current_fov)


func change_fov(player_current_fov):
	player_camera.fov = player_current_fov


func check_inventory_changes():
	if current_inventory_item != inventory.selected_item:
		current_inventory_item = inventory.selected_item
		
		axe.hide()
		tooltip.disable_tooltip()
		
		match(current_inventory_item):
			0:
				# Nothing to do here
				pass
			1:
				axe.show()
			2:
				if flower_seeds > 0:
					inventory.button_two_label.text = "Plant new flower"
				else:
					inventory.button_two_label.text = "No flower seeds"
			3:
				if tree_seeds > 0:
					inventory.button_three_label.text = "Plant new tree"
				else:
					inventory.button_three_label.text = "No tree saplings"
			4:
				if wood_amount > 0:
					inventory.button_four_label.text = "Build fireplace"
				else:
					inventory.button_four_label.text = "Not enough wood (1) for fireplace"
			5:
				if wood_amount >= 2:
					inventory.button_five_label.text = "Build beehive"
				else:
					inventory.button_five_label.text = "Not enough wood (2) for beehive"
			6:
				if wood_amount >= 4:
					inventory.button_six_label.text = "Build shelter"
				else:
					inventory.button_six_label.text = "Not enough wood (4) for shelter"
			7:
				if honey_amount > 0:
					inventory.button_seven_label.text = "Eat honey"
					tooltip.disable_tooltip()
					tooltip.set_tooltip("Left click to eat honey", "eat_action")
				else:
					inventory.button_seven_label.text = "You don't have any honey"
			8:
				if berries_amount > 0:
					inventory.button_eight_label.text = "Eat berries"
					tooltip.disable_tooltip()
					tooltip.set_tooltip("Left click to eat berries", "eat_action")
				else:
					inventory.button_eight_label.text = "You don't have any berries"
			9:
				if apple_amount > 0:
					inventory.button_nine_label.text = "Eat apples"
					tooltip.disable_tooltip()
					tooltip.set_tooltip("Left click to eat apples", "eat_action")
				else:
					inventory.button_nine_label.text = "You don't have any apples"


func update_info_ui():
	
	flower_seeds_label.text = String(flower_seeds)
	tree_seeds_label.text = String(tree_seeds)
	
	wood_plank_label.text = String(wood_amount)
	wood_plank_label_2.text = String(wood_amount)
	wood_plank_label_3.text = String(wood_amount)
	
	honey_label.text = String(honey_amount)
	berry_label.text = String(berries_amount)
	apple_label.text = String(apple_amount)
	
	
	if player_health > 80:
		health_label.text = "Well fed"
		health_amount_label.text = String(round(player_health))
	elif player_health > 60:
		health_label.text = "Slightly hungry"
		health_amount_label.text = String(round(player_health))
	elif player_health > 40:
		health_label.text = "Hungry"
		health_amount_label.text = String(round(player_health))
	elif player_health > 20:
		health_label.text = "Very hungry"
		health_amount_label.text = String(round(player_health))
	elif player_health > 10:
		health_label.text = "Starving"
		health_amount_label.text = String(round(player_health))
	else:
		health_label.text = "Starving to death"
		health_amount_label.text = String(round(player_health))


func manage_hunger(delta):
	player_health -= 0.2 * delta


func adjust_placing_node():
	# Show depending on selected item
	if current_inventory_item >= 2 && current_inventory_item <= 6:
		placing_node.show()
		
		preview_handmade_beehive.hide()
		preview_flowers.hide()
		preview_fireplace.hide()
		preview_shelter.hide()
		preview_tree_one.hide()
		
		match current_inventory_item:
			2:
				if flower_seeds > 0:
					preview_flowers.show()
				else:
					placing_node.hide()
			3:
				if tree_seeds > 0:
					preview_tree_one.show()
				else:
					placing_node.hide()
			4:
				if wood_amount > 0:
					preview_fireplace.show()
				else:
					placing_node.hide()
			5:
				if wood_amount >= 2:
					preview_handmade_beehive.show()
				else:
					placing_node.hide()
			6:
				if wood_amount >= 4:
					preview_shelter.show()
				else:
					placing_node.hide()
	else:
		placing_node.hide()
	
	if ray.is_colliding():
		var collision_point = ray.get_collision_point()
		placing_node.set_translation(collision_point)


func process_click_action():
	match current_inventory_item:
		2:
			if flower_seeds > 0:
				flower_seeds -= 1
				
				var instance_flowers = preload("res://scenes/game_objects/FlowerScene.tscn").instance()
				world_flowers.add_child(instance_flowers)
				instance_flowers.global_transform.origin = ray.get_collision_point()
				
				#inventory.selected_item = 0
				#inventory.change_selection()
		3:
			if tree_seeds > 0:
				tree_seeds -= 1
				
				var instance_tree = preload("res://scenes/game_objects/TreeOneScene.tscn").instance()
				world_trees.add_child(instance_tree)
				instance_tree.global_transform.origin = ray.get_collision_point()
				
				#inventory.selected_item = 0
				#inventory.change_selection()
		4:
			if wood_amount > 0:
				wood_amount -= 1
				
				var instance_fireplace = preload("res://scenes/game_objects/FireplaceScene.tscn").instance()
				world_fireplaces.add_child(instance_fireplace)
				instance_fireplace.global_transform.origin = ray.get_collision_point()
				
				inventory.selected_item = 0
				inventory.change_selection()
		5:
			if wood_amount >= 2:
				wood_amount -= 2
				
				var instance_beehive = preload("res://scenes/game_objects/HandmadeBeehiveScene.tscn").instance()
				world_beehives.add_child(instance_beehive)
				instance_beehive.global_transform.origin = ray.get_collision_point()
				
				inventory.selected_item = 0
				inventory.change_selection()
		6:
			if wood_amount >= 4:
				wood_amount -= 4
				
				var instance_shelter = preload("res://scenes/game_objects/ShelterScene.tscn").instance()
				world_shelters.add_child(instance_shelter)
				instance_shelter.global_transform.origin = ray.get_collision_point()
				
				inventory.selected_item = 0
				inventory.change_selection()
		7:
			if honey_amount > 0:
				honey_amount -= 1
				player_health += honey_health
				
				if player_health >= 100:
					player_health = 100
				
				tooltip.disable_tooltip()
				#inventory.selected_item = 0
				#inventory.change_selection()
		8:
			if berries_amount > 0:
				berries_amount -= 1
				player_health += berries_health
				
				if player_health >= 100:
					player_health = 100
				
				tooltip.disable_tooltip()
				#inventory.selected_item = 0
				#inventory.change_selection()
		9:
			if apple_amount > 0:
				apple_amount -= 1
				player_health += apple_health
				
				if player_health >= 100:
					player_health = 100
				
				tooltip.disable_tooltip()
				#inventory.selected_item = 0
				#inventory.change_selection()
