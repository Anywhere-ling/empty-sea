extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 回合系统: Node = %回合系统

var control:Dictionary[战斗_单位管理系统.Life_sys, 战斗_单位控制_nocard]


func add_life(life, is_positive:bool) -> void:
	#生成life
	if life is String:
		life = 单位管理系统.create_life(life, is_positive)
	
	#绑定控制
	if life.data["种类"] == "nocard":
		control[life] = 战斗_单位控制_nocard.new(life)
	
	#加入回合
	回合系统.join_life(life)
	
	#创造牌库
	单位管理系统.创造牌库(life, control[life].创造牌库())


func 第一次抽牌(life:战斗_单位管理系统.Life_sys) -> void:
	pass



var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _绑定信号() -> void:
	event_bus.subscribe("战斗_请求选择", _战斗_请求选择的信号)


func _战斗_请求选择的信号(life:战斗_单位管理系统.Life_sys, arr:Array, count:int = 1, is_all:bool = true) -> void:
	var ret:Array = control[life].对象选择(arr, count, is_all)
	event_bus.push_event("战斗_请求选择返回", [ret])
