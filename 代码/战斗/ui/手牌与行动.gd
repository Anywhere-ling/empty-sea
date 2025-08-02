extends Node2D
class_name 战斗_行动与手牌

@onready var 卡牌容器容器: Control = %卡牌容器容器
@onready var p_0: Node2D = %p0
@onready var p_2: Node2D = %p2
@onready var rot: Node2D = %rot



var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var cards:Array = []


func _ready() -> void:
	event_bus.subscribe("战斗_鼠标进入卡牌", func(a):_updata(0.2))
	call_deferred("set_p2")

func set_p2() -> void:
	p_2.position = Vector2(-p_0.position.x, p_0.position.y)


func add_card(card:Card) -> void:
	var cards1:Array = cards.duplicate(true)
	cards1.append(card)
	cards改变(cards1)

func remove_card(card:Card) -> void:
	var cards1:Array = cards.duplicate(true)
	cards1.erase(card)
	cards改变(cards1)

func cards改变(new_cards:Array) -> void:
	if new_cards == cards:
		return
	
	cards = new_cards
	for card:Card in 卡牌容器容器.get_children():
		card.set_glo()
		卡牌容器容器.remove_child(card)
	for card:Card in cards:
		卡牌容器容器.add_child(card)
		card.global_position = card.glo
	_updata()


func _updata(time:float = 0.4) -> void:
	var arr:Dictionary = {}
	var 鼠标序号:int = -1
	for i in cards:
		if i is Card:
			if i.鼠标停留中:
				鼠标序号 = len(arr)
			arr[len(arr)] = [i, 0.5]
	
	var 中位数:float = (len(arr)-1)/2.0
	var 基本距离:float = -log(len(arr)/50.0)/30
	
	if len(arr) > 1:
		for i:int in len(arr):
			arr[i][1] = arr[i][1] + ((i - 中位数) * 基本距离)
	
	if len(arr) == 10:
		pass
	
	#鼠标
	if 鼠标序号 != -1:
		for i:int in len(arr):
			if i < 鼠标序号:
				arr[i][1] -= -log(abs(i - 鼠标序号)/10.0)/70.0
			elif i > 鼠标序号:
				arr[i][1] += -log(abs(i - 鼠标序号)/10.0)/70.0 + 0.02
	
	
	for i:int in len(arr):
		var card:Card = arr[i][0]
		card.tween_trans = Tween.TRANS_QUAD
		card.tween_ease = Tween.EASE_OUT
		var glo:Vector2 = _quadratic_bezier_point(arr[i][1])
		if 鼠标序号 != -1:
			glo.y -= 30
		if i == 鼠标序号:
			卡牌容器容器.move_child(card, -1)
			card.tween动画添加("缩放", "scale", Vector2(1.5, 1.5), time)
			glo.y -= 60
		else :
			卡牌容器容器.move_child(card, cards.find(card))
			card.tween动画添加("缩放", "scale", Vector2(1, 1), time)
		card.tween动画添加("位置", "position", glo, time)
		
		if rot.visible:
			rot.position.x = position.x
			var dir:Vector2 = glo - rot.position
			var ang:float = dir.angle() + PI/2
			card.tween动画添加("旋转", "rotation", ang, time)
		
		



func _quadratic_bezier_point(t: float) -> Vector2:
	var p0: Vector2 = p_0.position
	var p1: Vector2 = position
	var p2: Vector2 = p_2.position
	
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var ret = q0.lerp(q1, t)
	return ret
