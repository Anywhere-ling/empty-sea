extends Node

@onready var 效果系统: Node = %效果系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 单位控制系统: Node = %单位控制系统
@onready var 回合系统: Node = %回合系统
@onready var 日志系统: 战斗_日志系统 = %日志系统

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


func 请求进行下一连锁() -> void:
	日志系统.callv("录入信息", [name, "请求进行下一连锁", [], null])
	
	var life:战斗_单位管理系统.Life_sys = current_life
	var arr_lifes:Array[战斗_单位管理系统.Life_sys]
	var f_lifes:Array[战斗_单位管理系统.Life_sys]
	
	if 单位管理系统.lifes.has(life):
		arr_lifes = 单位管理系统.efils
		f_lifes = 单位管理系统.lifes
	else :
		arr_lifes = 单位管理系统.lifes
		f_lifes = 单位管理系统.efils
	
	
	#敌对对象
	for i:战斗_单位管理系统.Life_sys in frist_lifes:
		if arr_lifes.has(i):
			arr_lifes.erase(i)
			if await 单位控制系统.发动询问(i):
				return
	#友方
	for i:战斗_单位管理系统.Life_sys in frist_lifes:
		if f_lifes.has(i):
			f_lifes.erase(i)
			if await 单位控制系统.发动询问(i):
				return
	#攻击目标
	if life.att_life:
		if await 单位控制系统.发动询问(life.att_life):
			return
	#全部
	for i:战斗_单位管理系统.Life_sys in arr_lifes:
		if await 单位控制系统.发动询问(i):
			return
	for i:战斗_单位管理系统.Life_sys in f_lifes:
		if i != life:
			if await 单位控制系统.发动询问(i):
				return
	if await 单位控制系统.发动询问(life):
		return
	
	await start()

func add_chain(effect:战斗_单位管理系统.Effect_sys) -> bool:
	var card:战斗_单位管理系统.Card_sys = effect.get_parent()
	var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
	
	var targets:Array = [card, life, null]
	if now_可发动的效果.has(effect):
		targets = now_可发动的效果[effect]
	if effect.cost_effect:
		targets = await 效果系统.效果处理(effect.cost_effect, card, await effect.get_value("features"), targets)
	await 最终行动系统.等待动画完成()
	if targets:
		chain_state = 1
		current_life = life
		all_chain.append([effect, targets])
		
		日志系统.callv("录入信息", [name, "add_chain", [effect], true])
		return true
	
	日志系统.callv("录入信息", [name, "add_chain", [effect], false])
	return false

func set_now_speed(effect:战斗_单位管理系统.Effect_sys, speed:int) -> void:
	日志系统.callv("录入信息", [name, "set_now_speed", [effect, speed], null])
	
	all_chain[-1].append(speed)
	now_speed = speed
	
	now_可发动的效果.erase(effect)
	effect.count -= 1
	
	await 最终行动系统.加入连锁的动画(effect.get_parent().get_parent().get_parent(), effect.get_parent(), effect.get_parent().effects.find(effect), speed)
	





func start() -> void:
	日志系统.callv("录入信息", [name, "start", [], null])
	
	chain_state = 2
	event_bus.push_event("战斗_连锁处理开始")
	all_chain.reverse()
	for arr:Array in all_chain:
		var effect:战斗_单位管理系统.Effect_sys = arr[0]
		var card:战斗_单位管理系统.Card_sys = effect.get_parent()
		var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
		await 最终行动系统.退出连锁的动画(card)
		await 效果系统.效果处理(effect.main_effect, card, await effect.get_value("features"), arr[1])
	all_chain = []
	now_speed = -1
	chain_state = 0
	event_bus.push_event("战斗_连锁处理结束")
	emit_signal("连锁处理结束")
	await 卡牌打出与发动系统.行动组结束()
	

func 请求新连锁() -> void:
	now_可发动的效果 = next_可发动的效果.duplicate(true)
	next_可发动的效果 = {}
	if now_可发动的效果:
		await _请求新连锁()

func _请求新连锁() -> void:
	日志系统.callv("录入信息", [name, "请求新连锁", [], null])
	
	var life:战斗_单位管理系统.Life_sys = 回合系统.current_life
	var arr_lifes:Array[战斗_单位管理系统.Life_sys]
	var f_lifes:Array[战斗_单位管理系统.Life_sys]
	
	if await 单位控制系统.发动询问(life):
		return
	if 单位管理系统.lifes.has(life):
		arr_lifes = 单位管理系统.efils
		f_lifes = 单位管理系统.lifes
	else :
		arr_lifes = 单位管理系统.lifes
		f_lifes = 单位管理系统.efils
	
	#攻击目标
	if life.att_life:
		if await 单位控制系统.发动询问(life.att_life):
			return
	#全部
	for i:战斗_单位管理系统.Life_sys in arr_lifes:
		if await 单位控制系统.发动询问(i):
			return
	for i:战斗_单位管理系统.Life_sys in f_lifes:
		if await 单位控制系统.发动询问(i):
			return
	
	now_可发动的效果 = {}

func _储存取对象的目标(cards:Array) -> void:
	日志系统.callv("录入信息", [name, "_储存取对象的目标", [cards], null])
	
	for card:战斗_单位管理系统.Card_sys in cards:
		var life:战斗_单位管理系统.Life_sys = card.get_parent().get_parent()
		frist_lifes.erase(life)
		frist_lifes.append(life)
