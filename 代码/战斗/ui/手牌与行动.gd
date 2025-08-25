extends Node2D
class_name 战斗_行动与手牌

@onready var 卡牌容器容器: Control = %卡牌容器容器
@onready var p_0: Node2D = %p0
@onready var p_1: Node2D = %p1
@onready var p_2: Node2D = %p2
@onready var rot: Node2D = %rot

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var cards:Array = []
var is_锁定:bool = false
var 鼠标停留的卡牌:Card


func _ready() -> void:
	event_bus.subscribe("战斗_gui_手牌锁定", func(a):
		is_锁定 = a
		if !a:
			_updata(0.1))
	call_deferred("set_p2")

func _process(delta: float) -> void:
	var cards1:Array = cards.duplicate(true)
	cards1.reverse()
	var 鼠标停留的卡牌仍有鼠标:bool = false
	for card:Card in cards1:
		if card.检测鼠标():
			if 鼠标停留的卡牌 == card:
				鼠标停留的卡牌仍有鼠标 = true
			if 鼠标停留的卡牌 == null:
				_鼠标进入卡牌(card)
				return
			if is_锁定:
				#锁定时显示与通常判断范围不一致
				if 鼠标停留的卡牌 != 卡牌容器容器.get_child(-1):
					_鼠标进入卡牌(card)
					return
	if 鼠标停留的卡牌 and !鼠标停留的卡牌仍有鼠标:
		_鼠标进入卡牌(null)
	

func _鼠标进入卡牌(card:Card) -> void:
	if card:
		if 鼠标停留的卡牌 == card:
			return
		鼠标停留的卡牌 = card
		event_bus.push_event("战斗_鼠标进入卡牌", card)
		_updata(0.2)
		return
	
	var arr:Array
	for i:Card in cards:
		if i.检测鼠标() and i != 鼠标停留的卡牌:
			arr.append(i)
	card = 鼠标停留的卡牌
	#离原卡牌最近
	arr.sort_custom(func(a, b):
		return abs(cards.find(card)-cards.find(a))< abs(cards.find(card)-cards.find(b)))
	
	if arr.size() == 0:
		#鼠标没有卡牌
		鼠标停留的卡牌 = null
		event_bus.push_event("战斗_鼠标进入卡牌", null)
	else :
		鼠标停留的卡牌 = arr[0]
		event_bus.push_event("战斗_鼠标进入卡牌", arr[0])
	_updata(0.2)
	


func set_p2() -> void:
	p_2.position = Vector2(-p_0.position.x, p_0.position.y)


func add_card(card:Card, _a=null) -> void:
	var cards1:Array = cards.duplicate(true)
	cards1.append(card)
	card.set_pos(self)
	cards改变(cards1)

func remove_card(card:Card, _a=null) -> void:
	var cards1:Array = cards.duplicate(true)
	cards1.erase(card)
	
	
	cards改变(cards1)

func cards改变(new_cards:Array) -> void:
	if new_cards == cards:
		return
	
	cards = new_cards
	for card:Card in 卡牌容器容器.get_children():
		卡牌容器容器.remove_child(card)
	for card:Card in cards:
		卡牌容器容器.add_child(card)
	_updata()


func _updata(time:float = 0.4) -> void:
	if is_锁定:
		return
	
	var arr:Dictionary = {}
	var 鼠标序号:int = -1
	for i in cards:
		if i is Card:
			if i.鼠标停留的卡牌 == i:
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
		else :
			time = 0.4
		
		time = time/C0nfig.动画速度
		
		if i == 鼠标序号:
			卡牌容器容器.move_child(card, len(cards)-1)
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
		else :
			card.tween动画添加("旋转", "rotation", 0, time)
		
		



func _quadratic_bezier_point(t: float) -> Vector2:
	var p0: Vector2 = p_0.position
	var p1: Vector2 = p_1.position
	var p2: Vector2 = p_2.position
	
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var ret = q0.lerp(q1, t)
	return ret
