extends Node2D


onready var dev_logo_sprite = $DevLogoSprite
onready var jam_logo_sprite = $JamLogoSprite

# Logos displayed
var logos_displayed = 0
var logo_display_speed = 1
var logo_show_off_speed = 1
var logo_show_off_timer = 0
var logo_show_off = false
var logo_displaying = true
var going_to_main_menu = false

# Startup delay
var startup_delay = true
var startup_delay_timer = 0

# Transition at the end
var transition_time_out = 0

# Skip this scene
var skip_splash = false


func _ready():
	var initial_viewport_size = get_viewport_rect().size
	transition_overlay.fade_out()
	
	# Set the sprite into the center according to the window size
	dev_logo_sprite.position.x = (initial_viewport_size.x / 2)
	dev_logo_sprite.position.y = (initial_viewport_size.y / 2)
	# Opacity
	dev_logo_sprite.modulate.a = 0
	
	jam_logo_sprite.position.x = (initial_viewport_size.x / 2)
	jam_logo_sprite.position.y = (initial_viewport_size.y / 2)
	# Opacity
	jam_logo_sprite.modulate.a = 0
	
	if skip_splash:
		logos_displayed = 2


func _process(delta):
	var viewport_size = get_viewport_rect().size
		
	dev_logo_sprite.position.x = (viewport_size.x / 2)
	dev_logo_sprite.position.y = (viewport_size.y / 2)
	
	jam_logo_sprite.position.x = (viewport_size.x / 2)
	jam_logo_sprite.position.y = (viewport_size.y / 2)
	
	
	if startup_delay:
		if startup_delay_timer <= (logo_show_off_speed / 1.75):
				startup_delay_timer += (logo_show_off_speed * delta)
		else:
			startup_delay = false
	else:
		match logos_displayed:
			0:
				process_dev_logo(delta)
			1:
				process_jam_logo(delta)
			2:
				go_to_main_menu(delta)


func process_dev_logo(delta):
	if logo_displaying:
		if dev_logo_sprite.modulate.a < 1:
			dev_logo_sprite.modulate.a += (logo_display_speed * delta)
		else:
			if logo_show_off_timer <= logo_show_off_speed:
				logo_show_off_timer += (logo_show_off_speed * delta)
			else:
				logo_show_off_timer = 0
				logo_displaying = false
	else:
		if dev_logo_sprite.modulate.a > 0:
			dev_logo_sprite.modulate.a -= (logo_display_speed * delta)
		else:
			logos_displayed += 1
			logo_displaying = true


func process_jam_logo(delta):
	if logo_displaying:
		if jam_logo_sprite.modulate.a < 1:
			jam_logo_sprite.modulate.a += (logo_display_speed * delta)
		else:
			if logo_show_off_timer <= logo_show_off_speed:
				logo_show_off_timer += (logo_show_off_speed * delta)
			else:
				logo_show_off_timer = 0
				logo_displaying = false
	else:
		if jam_logo_sprite.modulate.a > 0:
			jam_logo_sprite.modulate.a -= (logo_display_speed * delta)
		else:
			logos_displayed += 1
			logo_displaying = true


func go_to_main_menu(_delta):
	if !going_to_main_menu:
		transition_overlay.fade_in()
		going_to_main_menu = true
	
	if transition_overlay.transition_completed:
		if get_tree().change_scene("res://scenes/game_scenes/MainMenuScene.tscn") != OK:
			print("An unexpected error happened when trying to switch to the Main menu scene.")
