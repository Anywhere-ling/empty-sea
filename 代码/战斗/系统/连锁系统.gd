extends Node

@onready var 效果系统: Node = %效果系统

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var now_speed:int = -1
var all_chain:Dictionary[战斗_单位管理系统.Effect_sys, int]
var chain_state:int = 0
#0:未连锁，1:处理前，2:处理中



func add_chain(effect:战斗_单位管理系统.Effect_sys) -> bool:
	var card:战斗_单位管理系统.Card_sys = effect.get_parent()
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	
	if 效果系统.效果处理(effect.cost_effect, effect.features, [card, life, null]):
		chain_state = 1
		return true
	return false

func set_now_speed(effect:战斗_单位管理系统.Effect_sys, speed:int) -> void:
	all_chain[effect] = speed
	now_speed = speed




func start() -> void:
	chain_state = 2
	event_bus.push_event("战斗_连锁处理开始")
	for effect:战斗_单位管理系统.Effect_sys in all_chain:
		var card:战斗_单位管理系统.Card_sys = effect.get_parent()
		var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
		效果系统.效果处理(effect.cost_effect, effect.features, [card, life, null])
	chain_state = 0
	event_bus.push_event("战斗_连锁处理结束")
	now_speed = -1
