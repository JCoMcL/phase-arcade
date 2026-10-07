@tool
extends Resource
class_name GridPattern

@export var members: Dictionary = {'a' : null, 'b': null}:
	set(d):
		members = d
		for val in d.values():
			if not val:
				return
		parse_pattern(pattern_string)
@export var pattern_string: String = "a aaab b":
	set(s):
		parse_pattern(s)
		pattern_string = s

var rows: Array[Array]
func parse_pattern(s: String):
	rows = [[]]
	for c in s:
		if c == ' ' and rows[-1]:
			rows.append([])
		else:
			if not members.has(c):
				print("Err: %s: key, %s, not present in members" % [self, c])
			rows[-1].append(members[c])

func read(x:int, y:int):
	if not rows:
		print("Err: %s: not initialized" % self)
		return
	while y >= rows.size():
		y -= rows.size()

	if not rows[y]:
		print("Err: %s: invalid data: %s" % [self, members])
		return
	while x >= rows[y].size():
		x -= rows[y].size()
	return rows[y][x]
