extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 单位控制系统: Node = %单位控制系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var buff系统: Node = %buff系统
@onready var 日志系统: 战斗_日志系统 = %日志系统
@onready var 回合系统: Node = %回合系统
@onready var 连锁系统: Node = %连锁系统
@onready var 场地系统: Node = %场地系统
@onready var 二级行动系统: Node = %二级行动系统
@onready var 效果处理系统: 战斗_效果处理系统 = %效果处理系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

func _ready() -> void:
	pass




func 效果处理(eff:Array, car:战斗_单位管理系统.Card_sys, fea:Array = [], tar:Array = []) -> Array:
	效果处理系统.init(eff, [单位管理系统.lifes, 单位管理系统.efils], car, fea, tar)
	var ret:Array = await 效果处理系统.start()
	
	日志系统.callv("录入信息", [name, "_效果发动判断", [eff, fea, tar], ret])
	return ret


func 可用移动(life:战斗_单位管理系统.Life_sys, 方向:Array, 格数1:int, 格数2:int = 0) -> Array:
	var cards:Array = 单位管理系统.get_给定显示以上的卡牌(life.get_all_cards(), 4)
	
	var ret1:Dictionary
	var ret2:Dictionary
	
	for card in cards:
		if card.get_parent().nam != "场上":
			continue
		for pos in await 单卡可用移动(life, card, 方向, 格数1, 格数2):
			if !ret2.has(pos):
				ret2[pos] = []
			if !ret2[pos].has(card):
				ret2[pos].append(card)
			
			if !ret1.has(card):
				ret1[card] = []
			if !ret1[card].has(pos):
				ret1[card].append(pos)
	
	return [ret1, ret2]


func 单卡可用移动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 方向:Array, 格数1:int, 格数2:int = 0) -> Array:
	var eff1:Array = [
		["线段取格", "对象0", "angle", "d1", "d2", "对象3"], 
		["视角化", "对象0", "对象3", "对象3"],
		["逐一", "对象3", 
			["初始对象", "对象3", "对象4"], 
			["否定", 
				["条件卡牌筛选", "对象4", "显现", "包含", "3"], 
				["计算数量", "对象4", "对象4"], 
				["数据判断", "对象4", "包含", "1"], 
			], 
			["对象处理", "对象5", "加", "对象3"]
		
		]
	]
	
	
	
	var ret:Array
	
	for i in 方向:
		var targets:Array = [card, life]
		eff1[0] = ["线段取格", "对象0", str(i), str(格数1), str(格数2), "对象3"]
		targets = await 效果处理(eff1, null, [], targets)
		if targets:
			ret.append_array(targets[5])
	
	return ret
