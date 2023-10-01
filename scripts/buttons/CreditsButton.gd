extends TextureButton


var time_out = 0
var button_pressed = false


func _process(_delta):
	if button_pressed:
		if transition_overlay.transition_completed:
			if (get_tree().change_scene("res://scenes/game_scenes/CreditsScene.tscn")) != OK:
				print("An unexpected error happened when trying to switch to the Credits scene.")


func _on_CreditsButton_pressed():
	global_var.play_sound("sfx_select")
	button_pressed = true
	transition_overlay.fade_in()
