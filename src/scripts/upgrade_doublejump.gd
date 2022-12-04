extends UpgradeCollectable

func _init():
	item_type = ItemType.DOUBLE_JUMP

func _ready():
	print(item_type)
