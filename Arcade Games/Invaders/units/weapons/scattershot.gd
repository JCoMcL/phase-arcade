extends Shoota
class_name Scattershot

func shoot(towards:Variant=default_direction, parent_to:Node=null, mask:int=-1) -> Unit:
	var out: Unit
	for i in range(ammo_count):
		var bullet = await super(towards, parent_to, mask)
		if bullet:
			out = bullet
		else:
			break
	return out
