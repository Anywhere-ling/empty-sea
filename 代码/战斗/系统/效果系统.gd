extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 单位控制系统: Node = %单位控制系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var buff系统: Node = %buff系统
@onready var 日志系统: 战斗_日志系统 = %日志系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _ready() -> void:
	pass


func 效果处理(eff:Array, car:战斗_单位管理系统.Card_sys, fea:Array = [], tar:Array = []) -> Array:
	var effect_processing:= 战斗_效果处理系统.new(self, eff, [单位管理系统.lifes, 单位管理系统.efils], car, fea, tar)
	var ret:Array = await effect_processing.start()
	effect_processing.queue_free()
	await 最终行动系统.等待动画完成()
	
	日志系统.callv("录入信息", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret
