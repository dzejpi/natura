extends TextureButton


var time_out = 0
var button_pressed = false


func _process(_delta):
	if button_pressed:
		if transition_overlay.transition_completed:
			if get_tree().change_scene("res://scenes/game_scenes/GameSceneOne.tscn"):
				print("An unexpected error happened when trying to switch to the Game scene.")


func _on_EndlessGameButton_pressed():
	button_pressed = true
	global_var.endless_game = true
	global_var.play_sound("sfx_select")
	transition_overlay.fade_in()
