extends PanelContainer
class_name 战斗_可选卡牌容器_子节点


@onready var gri: GridContainer = %gri
@onready var hbo: HBoxContainer = %hbo
@onready var s_gri: ScrollContainer = %s_gri
@onready var s_hbo: ScrollContainer = %s_hbo


var 边距:Vector2

func add_card(card:Card) -> 战斗_卡牌复制:
	var ret:战斗_卡牌复制
	for node in [hbo, gri]:
		var 卡牌复制:战斗_卡牌复制
		for i:战斗_卡牌复制 in node.get_children():
			if !i.visible:
				卡牌复制 = i
				i.visible = true
				break
		if !卡牌复制:
			卡牌复制 = get_卡牌复制()
			node.add_child(卡牌复制)
		
		卡牌复制.set_card(card)
		if ret:
			卡牌复制.伴生 = null
			ret.伴生 = 卡牌复制
		else :
			卡牌复制.size_flags_vertical = Control.SIZE_EXPAND_FILL
			ret = 卡牌复制
	
	return ret

func change_mode(b:bool) -> void:
	if b:
		s_hbo.visible = false
		s_gri.visible = true
	else:
		s_gri.visible = false
		s_hbo.visible = true
		



func get_卡牌复制() -> 战斗_卡牌复制:
	var ret:战斗_卡牌复制
	ret = load(文件路径.tscn_战斗_卡牌复制()).instantiate()
	add_child(ret)
	ret.set_边距(边距.x, 边距.y)
	remove_child(ret)
	return ret
