extends Node2D


onready var button_zero = $ButtonZero
onready var button_zero_label = $ButtonZero/ButtonZeroLabel
onready var button_one = $ButtonOne
onready var button_one_label = $ButtonOne/ButtonOneLabel
onready var button_two = $ButtonTwo
onready var button_two_label = $ButtonTwo/ButtonTwoLabel
onready var button_three = $ButtonThree
onready var button_three_label = $ButtonThree/ButtonThreeLabel
onready var button_four = $ButtonFour
onready var button_four_label = $ButtonFour/ButtonFourLabel
onready var button_five = $ButtonFive
onready var button_five_label = $ButtonFive/ButtonFiveLabel
onready var button_six = $ButtonSix
onready var button_six_label = $ButtonSix/ButtonSixLabel
onready var button_seven = $ButtonSeven
onready var button_seven_label = $ButtonSeven/ButtonSevenLabel
onready var button_eight = $ButtonEight
onready var button_eight_label = $ButtonEight/ButtonEightLabel
onready var button_nine = $ButtonNine
onready var button_nine_label = $ButtonNine/ButtonNineLabel


var is_inventory_active = false
var selected_item = 0

var hidden_x = 2180
var revealed_x = 1536

var reveal_speed = 32


func _ready():
	change_selection()


func _process(_delta):
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		if position.x > revealed_x:
			position.x -= reveal_speed
	else:
		if position.x < hidden_x:
			position.x += reveal_speed


func _input(event):
	if event.is_action_pressed("inventory_scroll_down"):
		if selected_item < 9:
			selected_item += 1
		else:
			selected_item = 0
		
		change_selection()

	if event.is_action_pressed("inventory_scroll_up"):
		if selected_item > 0:
			selected_item -= 1
		else:
			selected_item = 9
		
		change_selection()


func change_selection():
	# Hide everything at once
	button_zero_label.hide()
	button_one_label.hide()
	button_two_label.hide()
	button_three_label.hide()
	button_four_label.hide()
	button_five_label.hide()
	button_six_label.hide()
	button_seven_label.hide()
	button_eight_label.hide()
	button_nine_label.hide()
	
	# Unfocus everything at once
	button_zero.release_focus()
	button_one.release_focus()
	button_two.release_focus()
	button_three.release_focus()
	button_four.release_focus()
	button_five.release_focus()
	button_six.release_focus()
	button_seven.release_focus()
	button_eight.release_focus()
	button_nine.release_focus()
	
	# Show and grab what is selected
	match selected_item:
		0:
			button_zero_label.show()
			button_zero.grab_focus()
		1:
			button_one_label.show()
			button_one.grab_focus()
		2:
			button_two_label.show()
			button_two.grab_focus()
		3:
			button_three_label.show()
			button_three.grab_focus()
		4:
			button_four_label.show()
			button_four.grab_focus()
		5:
			button_five_label.show()
			button_five.grab_focus()
		6:
			button_six_label.show()
			button_six.grab_focus()
		7:
			button_seven_label.show()
			button_seven.grab_focus()
		8:
			button_eight_label.show()
			button_eight.grab_focus()
		9:
			button_nine_label.show()
			button_nine.grab_focus()
