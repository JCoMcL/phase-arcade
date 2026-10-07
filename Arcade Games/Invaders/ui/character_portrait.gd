@tool
extends SelectableControl
class_name CharacterPortrait

func deselect_character(lc: LifeContainer):
	lc.life = null
	$LifeContainer.self_modulate = Color.WHITE
	selectable = true
	grab_focus()
	Game.play_sfx(self, back_sfx)

func _select() -> bool:
	if not super():
		return false
	var screen = DialogueScreen.get_dialogue_screen(self)
	if screen and $LifeContainer.life:
		var life_container = screen.submit($LifeContainer.life)
		if life_container:
			screen.push_back_handler(deselect_character.bind(life_container))
			$LifeContainer.self_modulate = Color("17121d")
			selectable = false
	return true
