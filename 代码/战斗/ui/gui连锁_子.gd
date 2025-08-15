extends VBoxContainer
class_name 战斗_gui连锁_子


@onready var 正: Control = %正
@onready var 反: Control = %反
@onready var 卡牌复制: 战斗_卡牌复制 = %卡牌复制


func set_card(card:Card, is_positive:bool, speed:int, eff_ind:int) -> void:
	if is_positive:
		正.visible = false
		反.visible = true
	else:
		反.visible = false
		正.visible = true
	
	卡牌复制.图片.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	卡牌复制.set_card(card)
	卡牌复制.set_文本(str(speed), str(eff_ind))
	
	visible = true
	

func free_card() -> void:
	卡牌复制.free_card()
	visible = false
