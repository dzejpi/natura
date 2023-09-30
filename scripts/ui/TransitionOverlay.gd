extends Node2D


var time_out = 0
onready var transition_overlay_sprite = $TransitionSprite

var transition_time_out = 0
var transition_completed = true
var transition_in = false


func _ready():
	var initial_viewport_size = get_viewport_rect().size
	
	transition_overlay_sprite.modulate.a = 0
	transition_overlay_sprite.scale.x = initial_viewport_size.x
	transition_overlay_sprite.scale.y = initial_viewport_size.y


func _process(delta):
	var viewport_size = get_viewport_rect().size
	
	# Redraw if necessary
	if transition_overlay_sprite.scale.x != viewport_size.x:
		transition_overlay_sprite.scale.x = viewport_size.x
	if transition_overlay_sprite.scale.y != viewport_size.y:
		transition_overlay_sprite.scale.y = viewport_size.y
	
	# Handle screen transition
	if !transition_completed:
		if transition_time_out < 1:
			transition_time_out += (2 * delta)
			if transition_in:
				transition_overlay_sprite.modulate.a = transition_time_out
			else:
				transition_overlay_sprite.modulate.a = (1 - transition_time_out)
		else:
			transition_completed = true


func fade_in():
	transition_completed = false
	transition_time_out = 0
	transition_in = true
	
	
func fade_out():
	transition_completed = false
	transition_time_out = 0
	transition_in = false
