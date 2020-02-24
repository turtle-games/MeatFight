extends Control

func _ready():
	$WinLabel.hide()
	$Button.hide()

func update_values(player, damage):
	if player == 1:
		$Player1Damage.text = str(damage)
	elif player == 2:
		$Player2Damage.text = str(damage)
	if damage <= 0:
		var winner = 0
		match player:
			2:
				winner = "You won! Hooray!"
			1:
				winner = "You lost a game.\nYou're such a loser!"
		get_tree().call_group("Players", "_on_game_ended")
		$WinLabel.text = winner
		$WinLabel.show()
		$Button.show()

func _on_Button_pressed():
	get_tree().call_group("Players", "_on_game_restart")
	$Button.hide()
	$WinLabel.hide()
