extends Control

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 回合系统: Node = %回合系统
@onready var gui单位管理 = %gui单位管理
@onready var 动画系统: Node = %动画系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 左: Control = %左
@onready var 右: Control = %右
@onready var 可选卡牌容器: 战斗_可选卡牌容器 = %可选卡牌容器
@onready var gui控制: 战斗_gui控制 = %gui控制
@onready var gui连锁: PanelContainer = %gui连锁


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 左边显示:Array = []
var 右边显示:Array = []


func _ready() -> void:
	event_bus.subscribe("战斗_请求动画", _请求动画的信号)
	event_bus.subscribe("战斗_左边显示改变", _左边显示改变的信号)
	event_bus.subscribe("战斗_右边显示改变", _右边显示改变的信号)
	event_bus.subscribe("战斗_卡牌被左键点击", _卡牌被左键点击的信号)
	event_bus.subscribe("战斗_卡牌被右键点击", _卡牌被右键点击的信号)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.pressed:
			event_bus.push_event("战斗_右键点击")


func _请求动画的信号(nam:String, data:Dictionary) -> void:
	if nam == "创造":
		set_gui_card(data["card"])
	if nam == "加入战斗":
		加入战斗(data["life"], data["is_positive"])
	elif nam == "创造牌库":
		创造牌库(data["life"])
	elif nam == "整理手牌":
		整理手牌(data["life"])
	elif nam == "加入连锁的动画":
		加入连锁的动画(data)
	elif nam == "退出连锁的动画":
		退出连锁的动画()
	elif nam == "图形化数据改变":
		图形化数据改变(data)
	
	else:
		动画(nam, data)

func _左边显示改变的信号(node) -> void:
	if !左边显示.has(node):
		左边显示.append(node)
		node.global_position = 左.global_position
	
	for i in 左边显示:
		tween动画添加_位置(i, i.get_child(0), Vector2(-node.get_child(0).size.x, 0), 0.1)
	tween动画添加_位置(node, node.get_child(0), Vector2(0, 0), 0.1)

func _右边显示改变的信号(node) -> void:
	if !右边显示.has(node):
		右边显示.append(node)
		node.global_position = 右.global_position
	
	for i in 右边显示:
		if i != node:
			tween动画添加_位置(i, i.get_child(0), Vector2(0, 0), 0.1)
	tween动画添加_位置(node, node.get_child(0), Vector2(-node.get_child(0).size.x, 0), 0.1)

func _卡牌被左键点击的信号(card:Card) -> void:
	可选卡牌容器.select(card)

func _卡牌被右键点击的信号(card:Card) -> void:
	pass



func 动画(tapy:String, data:Dictionary) -> void:
	动画系统.start_动画(动画系统.create_动画(tapy, data))

var life序号:Dictionary[String, int]
func 加入战斗(life:战斗_单位管理系统.Life_sys, is_positive:bool) -> void:
	var index:int
	if is_positive:
		index = 单位管理系统.lifes.find(life)
	else :
		index = 单位管理系统.efils.find(life)
	
	var all_index:int = 回合系统.turn_lifes.find(life)
	
	var life_gui:战斗_life = load(文件路径.tscn_gui战斗_life()).instantiate()
	add_child(life_gui)
	
	var life_ind:int = 0
	if life序号.has(life.nam):
		life_ind = life序号[life.nam]
		life序号[life.nam] += 1
	else :
		life序号[life.nam] = 1
	life_gui.set_life(life, is_positive, life_ind)
	
	动画系统.对照表["life"][life] = life_gui
	gui单位管理.add_life(life_gui, index, all_index, is_positive)
	
	可选卡牌容器.add_life(life)
	
	
	
	emit_可以继续()
	emit_动画完成()


func 创造牌库(life:战斗_单位管理系统.Life_sys) -> void:
	var life_gui:战斗_life = 动画系统.对照表["life"][life]
	var cards:Array = life.cards_pos["白区"].cards.duplicate(true)
	cards.reverse()
	
	var cards_gui:Array
	for card:战斗_单位管理系统.Card_sys in cards:
		var card_gui:Card = set_gui_card(card)
		cards_gui.append(card_gui)
	life_gui.add_cards(cards_gui, "白区")
		
	if gui控制.life_sys == life:
		gui控制.set_life_gui(life_gui)
	
	emit_可以继续()
	emit_动画完成()


func set_gui_card(card:战斗_单位管理系统.Card_sys) -> Card:
	var card_gui:Card = load(文件路径.tscn_gui_card()).instantiate()
	add_child(card_gui)
	card_gui.set_card(card)
	remove_child(card_gui)
	
	动画系统.对照表["card"][card] = card_gui
	return card_gui


func 整理手牌(life:战斗_单位管理系统.Life_sys) -> void:
	var life_gui:战斗_life = 动画系统.对照表["life"][life]
	var cards_sys:Array = life.cards_pos["手牌"].cards
	var cards_gui:Array
	for card in cards_sys:
		cards_gui.append(动画系统.对照表["card"][card])
	life_gui.手牌.cards改变(cards_gui)
	
	emit_可以继续()
	emit_动画完成()

func 加入连锁的动画(data:Dictionary) -> void:
	data = 动画系统._data转换(data)
	var card = data["card"]
	var life:战斗_life = data["life"]
	
	gui连锁.add_card(card, life.is_positive, data["effect_ind"], data["speed"])
	await gui连锁.完成
	
	emit_可以继续()
	emit_动画完成()

func 退出连锁的动画() -> void:
	gui连锁.remove_card()
	await gui连锁.完成
	
	emit_可以继续()
	emit_动画完成()

func 图形化数据改变(data:Dictionary) -> void:
	data = 动画系统._data转换(data)
	var card:Card = data["card"]
	var key:String = data["key"]
	
	card.emit_signal("图片或文字改变", key)
	
	emit_可以继续()
	emit_动画完成()




func emit_可以继续() -> void:
	最终行动系统.call_deferred("emit_signal", "可以继续")

func emit_动画完成() -> void:
	最终行动系统.call_deferred("emit_signal", "动画完成")




var tweens:Dictionary[Node, Tween]
func _new_tween(nam:Node) -> Tween:
	if tweens.has(nam) and tweens[nam]:
		tweens[nam].kill()
	var tween: = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tweens[nam] = tween
	return tween

func tween动画添加_位置(nam:Node, node:Node, pos:Vector2, time:float) -> void:
	var tween: = _new_tween(nam)
	tween.tween_property(node, "position", pos, time)
