extends TextureButton


func _on_ContinueGameButton_pressed():
	get_parent().get_parent().is_game_paused = false
	global_var.play_sound("sfx_select")
	
