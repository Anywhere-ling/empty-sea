extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


func 效果处理(eff:Array, fea:Array = [], tar:Array = []) -> Array:
	var effect_processing:= 战斗_效果处理系统.new(eff, [单位管理系统.lifes, 单位管理系统.efils], fea, tar)
	var ret:Array = effect_processing.start()
	
	event_bus.push_event("战斗_日志记录", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret
