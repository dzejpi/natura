extends KinematicBody


onready var butterfly_animation_player = $ButterflyAnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	butterfly_animation_player.play("fly")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
