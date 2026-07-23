class_name ItemsData extends Resource

enum ItemType { NONE, COIN, COUNTER_COIN, PARCHMENTS, EGYPTIAN_CROSS, EGYPTIAN_VASE, GOLDEN_SCARAB, LARGE_SCARAB, HONEY }

@export var coin: bool = false:
	set(val):
		coin = bool(val)
		counter_coin += 50

@export var counter_coin: int = 0:
	set(val): counter_coin = int(val)

@export var egyptian_cross: bool = false:
	set(val): egyptian_cross = bool(val)

@export var egyptian_vase: bool = false:
	set(val): egyptian_vase = bool(val)

@export var golden_scarab: int = 0:
	set(val): golden_scarab += val

@export var large_scarab: bool = false:
	set(val): large_scarab = bool(val)

@export var honey: Array = [
	null,
	null,
	null
]

@export var parchment: bool = false
''' Array[bool] = [
	false, false, false, false,
	false, false, false, false,
	false, false, false, false ]'''


static func item_to_str(item_type: ItemType) -> String:
	return (ItemType.keys()[item_type] as String).to_lower()


func _to_string() -> String:
	return "Item(Coin: %s, \ncruz: %s, \nVade: %s, \nBug: %d, \nBig_bug: %s)" % [coin,egyptian_cross,egyptian_vase,golden_scarab,large_scarab]
