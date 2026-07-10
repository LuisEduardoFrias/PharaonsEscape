extends BaseEnemic

enum BeeType { BEE, ANGRY_BEE }

@export var bee_type: BeeType = BeeType.BEE

func checkBeeTypeAnim(anim_name: String) -> String:
	return anim_name if bee_type == BeeType.BEE else anim_name + "_2"
