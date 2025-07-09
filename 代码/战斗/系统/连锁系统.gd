extends Node

@onready var 效果系统: Node = %效果系统
@onready var 最终行动系统: Node = $"../最终行动系统"

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var now_speed:int = -1
var all_chain:Dictionary[战斗_单位管理系统.Effect_sys, Array]
var chain_state:int = 0
#0:未连锁，1:处理前，2:处理中

var current_life:战斗_单位管理系统.Life_sys
var frist_lifes:Array[战斗_单位管理系统.Life_sys]


func _ready() -> void:
	event_bus.subscribe("战斗_请求选择返回", func(a):
		_储存取对象的目标(a)
		, 2, false, 
		func(_p):
		return _p[0] != [] and _p[0][0] is 战斗_单位管理系统.Card_sys)



func add_chain(effect:战斗_单位管理系统.Effect_sys) -> bool:
	var card:战斗_单位管理系统.Card_sys = effect.get_parent()
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	
	var targets:Array = 效果系统.效果处理(effect.cost_effect, effect.get_value("features"), [card, life, null])
	if targets:
		chain_state = 1
		current_life = life
		all_chain[effect].append(targets)
		
		event_bus.push_event("战斗_日志记录", [name, "add_chain", [effect], true])
		return true
	
	event_bus.push_event("战斗_日志记录", [name, "add_chain", [effect], false])
	return false

func set_now_speed(effect:战斗_单位管理系统.Effect_sys, speed:int) -> void:
	event_bus.push_event("战斗_日志记录", [name, "set_now_speed", [effect, speed], null])
	
	all_chain[effect].append(speed)
	now_speed = speed
	
	await 最终行动系统.加入连锁的动画(effect.get_parent().get_parent().get_parent(), effect.get_parent().get_parent(), speed)
	
	event_bus.push_event("战斗_请求进行下一连锁")





func start() -> void:
	event_bus.push_event("战斗_日志记录", [name, "start", [], null])
	
	chain_state = 2
	event_bus.push_event("战斗_连锁处理开始")
	for effect:战斗_单位管理系统.Effect_sys in all_chain:
		var card:战斗_单位管理系统.Card_sys = effect.get_parent()
		var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
		效果系统.效果处理(effect.cost_effect, effect.get_value("features"), all_chain[effect][0])
	chain_state = 0
	event_bus.push_event("战斗_连锁处理结束")
	now_speed = -1

func _储存取对象的目标(cards:Array[战斗_单位管理系统.Card_sys]) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_储存取对象的目标", [cards], null])
	
	for card:战斗_单位管理系统.Card_sys in cards:
		var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
		frist_lifes.erase(life)
		frist_lifes.append(life)
