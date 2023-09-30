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
onready var season_sprite = $UI/PlayerUI/SeasonUINode/SeasonSprite

onready var inventory = $UI/PlayerUI/Inventory

onready var info_ui = $UI/PlayerUI/InfoUI
onready var food_label = $UI/PlayerUI/InfoUI/FoodLabel
onready var seeds_label = $UI/PlayerUI/InfoUI/SeedsLabel
onready var wood_plank_label = $UI/PlayerUI/InfoUI/WoodPlankLabel
onready var health_label = $UI/PlayerUI/InfoUI/HealthLabel


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
var flower_seeds = 0
var tree_seeds = 0
var wood_amount = 0

var honey_amount = 2
var berries_amount = 4
var apple_amount = 6

var honey_health = 20
var berries_health = 20
var apple_health = 20

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
	info_ui.hide()


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


func _process(_delta):
	check_game_end()
	check_pause_update()
	check_inventory_changes()
	update_info_ui()
	
	# If player is looking at something
	if ray.is_colliding():
		var collision_object = ray.get_collider().name
		
		if collision_object != observed_object:
			observed_object = collision_object
			print("Player is looking at: " + observed_object + ".")
	else:
		var collision_object = "nothing"
		if collision_object != observed_object:
			observed_object = collision_object
			print("Player is looking at: nothing.")


func _physics_process(delta):
	if Input.is_action_pressed("inventory_display"):
		pass
	
	if is_on_floor():
		gravity_vector = -get_floor_normal() * slide_prevention
		acceleration = ground_acceleration
		if !is_on_ground:
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
			animation_player.play("Head Bob")
	
	if Input.is_action_just_pressed("ui_status"):
		info_ui.show()
		
	if Input.is_action_just_released("ui_status"):
		info_ui.hide()


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
					inventory.button_four_label.text = "Not enough wood for fireplace"
			5:
				if wood_amount > 2:
					inventory.button_five_label.text = "Build beehive"
				else:
					inventory.button_five_label.text = "Not enough wood for beehive"
			6:
				if wood_amount > 4:
					inventory.button_six_label.text = "Build shelter"
				else:
					inventory.button_six_label.text = "Not enough wood for shelter"
			7:
				if honey_amount > 0:
					inventory.button_seven_label.text = "Eat honey"
				else:
					inventory.button_seven_label.text = "You don't have any honey"
			8:
				if berries_amount > 0:
					inventory.button_eight_label.text = "Eat berries"
				else:
					inventory.button_eight_label.text = "You don't have any berries"
			9:
				if apple_amount > 0:
					inventory.button_nine_label.text = "Eat apples"
				else:
					inventory.button_nine_label.text = "You don't have any apples"


func update_info_ui():
	food_label.text = String(honey_amount) + " jars of honey, " + String(apple_amount) + " apples, " + String(berries_amount) + " berries"
	seeds_label.text = String(flower_seeds) + " flower seeds, " + String(tree_seeds) + " tree saplings"
	wood_plank_label.text = String(wood_amount) + " wood planks"
	
	if player_health > 80:
		health_label.text = "Well fed"
	elif player_health > 60:
		health_label.text = "Slightly hungry"
	elif player_health > 40:
		health_label.text = "Hungry"
	elif player_health > 20:
		health_label.text = "Very hungry"
	elif player_health > 10:
		health_label.text = "Starving"
	else:
		health_label.text = "Starving to death"
