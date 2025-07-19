extends Node

@onready var 效果系统: Node = %效果系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统

signal 连锁处理结束

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var now_speed:int = -1
var all_chain:Array[Array]
var chain_state:int = 0
#0:未连锁，1:处理前，2:处理中

var current_life:战斗_单位管理系统.Life_sys
var frist_lifes:Array[战斗_单位管理系统.Life_sys]

var next_可发动的效果:Dictionary[战斗_单位管理系统.Effect_sys, Array]
var now_可发动的效果:Dictionary[战斗_单位管理系统.Effect_sys, Array]


func _ready() -> void:
	event_bus.subscribe("战斗_请求选择返回", func(a):
		_储存取对象的目标(a)
		, 2, false, 
		func(_p):
		return _p[0] != [] and _p[0][0] is 战斗_单位管理系统.Card_sys)



func add_chain(effect:战斗_单位管理系统.Effect_sys) -> bool:
	var card:战斗_单位管理系统.Card_sys = effect.get_parent()
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	
	var targets:Array = [card, life, null]
	if now_可发动的效果.has(effect):
		targets = now_可发动的效果[effect]
	if effect.cost_effect:
		targets = 效果系统.效果处理(effect.cost_effect, effect.get_value("features"), targets)
	if targets:
		if chain_state == 0:
			now_可发动的效果 = next_可发动的效果.duplicate(true)
			next_可发动的效果 = {}
		chain_state = 1
		current_life = life
		all_chain.append([effect, targets])
		
		event_bus.push_event("战斗_日志记录", [name, "add_chain", [effect], true])
		return true
	
	event_bus.push_event("战斗_日志记录", [name, "add_chain", [effect], false])
	return false

func set_now_speed(effect:战斗_单位管理系统.Effect_sys, speed:int) -> void:
	event_bus.push_event("战斗_日志记录", [name, "set_now_speed", [effect, speed], null])
	
	all_chain[-1].append(speed)
	now_speed = speed
	
	now_可发动的效果.erase(effect)
	effect.count -= 1
	
	await 最终行动系统.加入连锁的动画(effect.get_parent().get_parent().get_parent(), effect.get_parent(), effect.get_parent().effects.find(effect), speed)
	
	





func start() -> void:
	event_bus.push_event("战斗_日志记录", [name, "start", [], null])
	
	chain_state = 2
	event_bus.push_event("战斗_连锁处理开始")
	all_chain.reverse()
	for arr:Array in all_chain:
		var effect:战斗_单位管理系统.Effect_sys = arr[0]
		var card:战斗_单位管理系统.Card_sys = effect.get_parent()
		var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
		await 效果系统.效果处理(effect.main_effect, effect.get_value("features"), arr[1])
	all_chain = []
	卡牌打出与发动系统.自动下降()
	now_speed = -1
	chain_state = 0
	event_bus.push_event("战斗_连锁处理结束")
	emit_signal("连锁处理结束")
	

func _储存取对象的目标(cards:Array) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_储存取对象的目标", [cards], null])
	
	for card:战斗_单位管理系统.Card_sys in cards:
		var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
		frist_lifes.erase(life)
		frist_lifes.append(life)
