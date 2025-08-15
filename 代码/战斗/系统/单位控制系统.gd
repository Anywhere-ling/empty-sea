extends Node

@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var 发动判断系统: Node = %发动判断系统
@onready var 连锁系统: Node = %连锁系统
@onready var 回合系统: Node = %回合系统
@onready var 日志系统: 战斗_日志系统 = %日志系统


var control:Dictionary[战斗_单位管理系统.Life_sys, 战斗_单位控制]

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


func 请求选择单位(life:战斗_单位管理系统.Life_sys, mp:int) -> 战斗_单位管理系统.Life_sys:
	var arr:Array[战斗_单位管理系统.Life_sys]
	if 单位管理系统.lifes.has(life):
		for i:战斗_单位管理系统.Life_sys in 单位管理系统.efils:
			if mp >= 6 - len(卡牌打出与发动系统.get_可用的格子(i.cards_pos["场上"], ["卡牌"])):
				arr.append(i)
		
	else :
		for i:战斗_单位管理系统.Life_sys in 单位管理系统.lifes:
			if mp >= 6 - len(卡牌打出与发动系统.get_可用的格子(i.cards_pos["场上"], ["卡牌"])):
				arr.append(i)
	
	var ret:战斗_单位管理系统.Life_sys = await control[life].选择单位(arr)
	
	日志系统.callv("录入信息", [name, "请求选择单位", [life, mp], ret])
	return ret

func 请求选择(life:战斗_单位管理系统.Life_sys, 描述:String, arr:Array,  count_max:int = 1, count_min:int = 1) -> Array:
	var ret:Array = await control[life].对象选择(arr, 描述, count_max, count_min)
	
	日志系统.callv("录入信息", [name, "请求选择", [life, 描述, arr, count_max, count_min], ret])
	return ret

func 请求选择一格(life:战斗_单位管理系统.Life_sys, arr:Array, condition:Array) -> 战斗_单位管理系统.Card_pos_sys:
	arr = 卡牌打出与发动系统.get_可用的格子(arr, condition)
	var arr1:Array = await control[life].选择一格(arr)
	var ret:战斗_单位管理系统.Card_pos_sys
	if arr1:
		ret = arr1[0]
	else :
		ret = null
	
	日志系统.callv("录入信息", [name, "请求选择一格", [life, arr], ret])
	return ret

func 请求选择多格(life:战斗_单位管理系统.Life_sys, 描述:String, arr:Array,  count_max:int = 1, count_min:int = 1) -> Array:
	var arr1:Array = await control[life].选择一格(arr, 描述, count_max, count_min)
	var ret:Array = arr1
	
	日志系统.callv("录入信息", [name, "请求选择多格", [life, arr], ret])
	return ret

func 发动询问(life:战斗_单位管理系统.Life_sys) -> bool:
	var cards:Array[战斗_单位管理系统.Card_sys]
	var card:战斗_单位管理系统.Card_sys
	if 回合系统.period == "主要" and 回合系统.current_life == life:
		cards = await 发动判断系统.单位主要阶段发动判断(life)
	else :
		cards = await 发动判断系统.单位非主要阶段发动判断(life)
	
	card = await control[life].发动(cards)
	
	if !card:
		
		日志系统.callv("录入信息", [name, "发动询问", [life], false])
		return false
	
	await 卡牌打出与发动系统.发动(life, card)
	
	if 连锁系统.chain_state:
		await 连锁系统.连锁处理结束
	
	日志系统.callv("录入信息", [name, "发动询问", [life], true])
	return true
