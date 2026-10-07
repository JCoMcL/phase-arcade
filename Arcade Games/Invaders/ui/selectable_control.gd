extends Control
class_name SelectableControl

@export var selectable = true
@export var select_sfx: StringName = "blup"
@export var activate_sfx: StringName = "bwoo"
@export var back_sfx: StringName = "blom"

var direction_table = {
	"ui_up" : (func(c): return c.focus_neighbor_top).bind(self),
	"ui_down" : (func(c): return c.focus_neighbor_bottom).bind(self),
	"ui_left" : (func(c): return c.focus_neighbor_left).bind(self),
	"ui_right" : (func(c): return c.focus_neighbor_right).bind(self)
}

func transfer_focus(s: String) -> bool:
	if not s in direction_table:
		return false
	var n_path = direction_table[s].call()
	if not n_path:
		return false
	var n = get_node(n_path)
	if not n or n is not Control:
		return false
	if n is SelectableControl and not n.selectable:
		if n.transfer_focus(s):
			return true
		return false
	n.grab_focus()
	return true

func _select() -> bool:
	if not selectable:
		return false
	accept_event()
	Game.play_sfx(self, activate_sfx)
	Game.play_sfx(self, select_sfx)
	if button_interface:
		button_interface.button_pressed = true
		button_interface.pressed.emit()
	return true

func _gui_input(ev: InputEvent) -> void:
	for d in direction_table.keys():
		if ev.is_action_pressed(d):
			if transfer_focus(d):
				Game.play_sfx(self, select_sfx)
			accept_event()
			break
	if ev.is_action_pressed("fire"):
		_select()
	if ev.is_action_released("fire"):
		if button_interface:
			button_interface.button_pressed = false

var button_interface: BaseButton
func _ready():
	var c = self as Control
	if c is BaseButton:
		button_interface = c as BaseButton
	if selectable:
		focus_mode = Control.FOCUS_ALL
