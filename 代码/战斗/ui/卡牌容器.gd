extends Panel
class_name 战斗_卡牌容器


@onready var 位置: Control = %位置

var card:Card
var nam:String
var 边距:Vector2

func get_posi() -> Vector2:
	return 位置.position

func set_nam(p_nam:String, l:int) -> void:
	custom_minimum_size = Vector2(l, (l * 5)/3)
	nam =p_nam

func remove_card() -> Card:
	var ret
	for i in 位置.get_children():
		位置.remove_child(i)
		ret = i
	return ret

func add_card(p_card:Card) -> void:
	assert(!p_card.get_parent(), "有父节点")
	位置.tooltip_text = nam
	
	var new_size = size - 边距
	var a
	if new_size.x > (new_size.y * 3)/5:
		a = new_size.y/p_card.图片.size.y
	else:
		a = new_size.x/p_card.图片.size.x
	p_card.scale = Vector2(a,a)
	
	
	位置.add_child(p_card)
	card = p_card
