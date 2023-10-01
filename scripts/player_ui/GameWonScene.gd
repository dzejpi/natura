extends Node2D


onready var game_won_label = $GameWonLabel
var game_won_text = ""


func _ready():
	pass # Replace with function body.


func update_game_won_screen():
	game_won_label.text = game_won_text
