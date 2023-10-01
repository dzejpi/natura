extends Node


onready var sfx_node = $SfxPlayer
onready var music_node = $MusicPlayer


var sfx_walk = preload("res://assets/sfx/sfx_walk.mp3")
var sfx_select = preload("res://assets/sfx/sfx_select.mp3")
var sfx_pickup = preload("res://assets/sfx/sfx_pickup.mp3")
var sfx_axe_swing = preload("res://assets/sfx/sfx_axe_swing.mp3")

var is_game_over = false

# Necessary to replace null with a proper preload("res://...")
var music_game_music = null

# Necessary to replace null with a proper preload("res://...")
var sfx_sound_placeholder = null

var endless_game = false


func play_music():
	music_node.stream = music_game_music
	music_node.play()
	

func stop_music():
	music_node.stop()


func play_sound(sfx_name):
	match(sfx_name):
		"sfx_walk":
			sfx_node.stream = sfx_walk
			sfx_node.play()
		"sfx_select":
			sfx_node.stream = sfx_select
			sfx_node.play()
		"sfx_pickup":
			sfx_node.stream = sfx_pickup
			sfx_node.play()
		"sfx_axe_swing":
			sfx_node.stream = sfx_axe_swing
			sfx_node.play()


func stop_sound(sfx_name):
	match(sfx_name):
		"sfx_walk":
			sfx_node.stream = sfx_walk
			sfx_node.stop()
		"sfx_select":
			sfx_node.stream = sfx_select
			sfx_node.stop()
		"sfx_pickup":
			sfx_node.stream = sfx_pickup
			sfx_node.stop()
		"sfx_axe_swing":
			sfx_node.stream = sfx_axe_swing
			sfx_node.stop()
