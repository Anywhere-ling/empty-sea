extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 最终行动系统: Node = %最终行动系统

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _ready() -> void:
	event_bus.subscribe("战斗_效果的行动_加入", 战斗_效果的行动_加入的信号)

func 效果处理(eff:Array, fea:Array = [], tar:Array = []) -> Array:
	var effect_processing:= 战斗_效果处理系统.new(eff, [单位管理系统.lifes, 单位管理系统.efils], fea, tar)
	var ret:Array = await effect_processing.start()
	
	event_bus.push_event("战斗_日志记录", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret


func 战斗_效果的行动_加入的信号(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> void:
	var ret:bool = await 最终行动系统.加入(life, card, pos)
	
	event_bus.push_event("战斗_日志记录", [name, "_效果发动判断", [life, card, pos], ret])
	event_bus.push_event("战斗_效果的行动处理返回", [ret])
