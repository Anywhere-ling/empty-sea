extends Node

@onready var 效果系统: Node = %效果系统
@onready var 回合系统: Node = %回合系统
@onready var 连锁系统: Node = %连锁系统
@onready var 日志系统: 战斗_日志系统 = %日志系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 全部单位buffs:Dictionary[战斗_单位管理系统.Buff_sys, 战斗_单位管理系统.Life_sys]

#按时间结束的buff
var start_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
var end_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
var chain_start_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
var chain_end_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
#{life:{buff:{次数}

func _ready() -> void:
	event_bus.subscribe("战斗_单位添加了buff", func(life, buff):
		if buff.data["影响"].has("全部"): 全部单位buffs[buff] = life)
	event_bus.subscribe("战斗_单位移除了buff", func(life, buff):
		全部单位buffs.erase(buff))
	event_bus.subscribe("战斗_录入按时间结束的buff", _战斗_录入按时间结束的buff的信号)
	event_bus.subscribe("战斗_连锁处理开始", _战斗_连锁处理开始的信号, 2)
	event_bus.subscribe("战斗_连锁处理结束", _战斗_连锁处理结束的信号, 2)
	event_bus.subscribe("战斗_添加触发与固有buff", _add_触发与固有buff, 2)
	



func _战斗_录入按时间结束的buff的信号(buff:战斗_单位管理系统.Buff_sys, 结束时间:String, 结束次数:int) -> void:
	日志系统.callv("录入信息", [name, "_战斗_录入按时间结束的buff的信号", [buff, 结束时间, 结束次数], null])
	var buffs:Dictionary
	
	match 结束时间:
		"开始":buffs = start_buffs
		"结束":buffs = end_buffs
		"连锁处理开始":buffs = chain_start_buffs
		"连锁处理结束":buffs = chain_end_buffs

	if 结束时间 and !buffs.has(回合系统.current_life):
		buffs[回合系统.current_life] = {}
	buffs[回合系统.current_life][buff] = 结束次数
	
	
func 开始阶段结算buff(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "开始阶段结算buff", [life], null])
	
	for i:战斗_单位管理系统.Buff_sys in life.buffs:
		await _buff判断(i, "开始", [null, life, null])
	
	if start_buffs.has(life):
		for i:战斗_单位管理系统.Buff_sys in start_buffs[life]:
			if i:
				start_buffs[life][i] -= 1
				if start_buffs[life][i] == 0:
					i.free_self()
			else :
				start_buffs[life][i] = 0

func 结束阶段结算buff(life:战斗_单位管理系统.Life_sys) -> void:
	日志系统.callv("录入信息", [name, "结束阶段结算buff", [life], null])
	
	for i:战斗_单位管理系统.Buff_sys in life.buffs:
		await _buff判断(i, "结束", [null, life, null])
	
	if start_buffs.has(life):
		for i:战斗_单位管理系统.Buff_sys in end_buffs[life]:
			if i:
				end_buffs[life][i] -= 1
				if end_buffs[life][i] == 0:
					i.free_self()
			else :
				end_buffs[life][i] = 0

func _战斗_连锁处理开始的信号() -> void:
	日志系统.callv("录入信息", [name, "_战斗_连锁处理开始的信号", [], null])
	
	for life:战斗_单位管理系统.Life_sys in chain_start_buffs:
		for i:战斗_单位管理系统.Buff_sys in chain_start_buffs[life]:
			await _buff判断(i, "连锁处理开始", [null, life, null])
			if i:
				chain_start_buffs[life][i] -= 1
				if chain_start_buffs[life][i] == 0:
					i.free_self()
			else :
				chain_start_buffs[life][i] = 0

func _战斗_连锁处理结束的信号() -> void:
	日志系统.callv("录入信息", [name, "_战斗_连锁处理结束的信号", [], null])
	
	for life:战斗_单位管理系统.Life_sys in chain_start_buffs:
		for i:战斗_单位管理系统.Buff_sys in chain_end_buffs[life]:
			await _buff判断(i, "连锁处理结束", [null, life, null])
			if i:
				chain_end_buffs[life][i] -= 1
				if chain_end_buffs[life][i] == 0:
					i.free_self()
			else :
				chain_end_buffs[life][i] = 0




func _add_触发与固有buff(card:战斗_单位管理系统.Card_sys) -> void:
	var pos:战斗_单位管理系统.Card_pos_sys = card.get_parent()
	if pos.nam == "临时":
		return
	
	for effect:战斗_单位管理系统.Effect_sys in card.effects:
		if effect.features.has("触发") or effect.features.has("固有"):
			for buff:战斗_单位管理系统.Buff_sys in effect.buffs:
				buff.free_self()
			if card.appear < 2:
				return
			
			var features:Array = await effect.get_value("features")
			if features.has(pos.nam) or features.has("任意"):
				effect.add_buffs()
				return
			
			for i:String in ["场上", "行动", "手牌", "白区", "绿区", "蓝区", "红区"]:
				if features.has(pos.nam):
					return
			if pos.nam == "场上":
				effect.add_buffs()



##1:受影响且通过,0:受影响且未通过，-1:未受影响
func 单位与全部buff判断(影响:String, targets:Array = [null, null, null]) -> int :
	var ret:int = -1
	#对发动单位的buff
	if targets[1]:
		for buff:战斗_单位管理系统.Buff_sys in targets[1].buffs:
			var i:int = await _buff判断(buff, 影响, targets)
			if i == 0:
				日志系统.callv("录入信息", [name, "单位与全部buff判断", [影响, targets], 0])
				return 0
			elif i == 1:
				ret = 1
	#"全部"buff
	for buff:战斗_单位管理系统.Buff_sys in 全部单位buffs:
		var targets2:Array = targets.duplicate(true)
		targets2[1] = 全部单位buffs[buff]
		
		var i:int = await _buff判断(buff, 影响, targets2)
		if i == 0:
			日志系统.callv("录入信息", [name, "单位与全部buff判断", [影响, targets], 0])
			return 0
		elif i == 1:
			ret = 1
	
	日志系统.callv("录入信息", [name, "单位与全部buff判断", [影响, targets], ret])
	return ret


##1:受影响且通过,0:受影响且未通过，-1:未受影响
func _buff判断(buff:战斗_单位管理系统.Buff_sys, 影响:String, targets:Array) -> int:
	if buff.data["影响"].has(影响):
		if buff.card:
			targets[0] = buff.card
		var new_targets:Array = buff.targets.duplicate(true)
		for i in len(targets):
			new_targets[i] = targets[i]
		targets = new_targets
		
		var cost_tar:Array = await 效果系统.效果处理(buff.effect.cost_effect, null, buff.effect.features, targets)
		if cost_tar:
			var main_tar:Array = await 效果系统.效果处理(buff.effect.main_effect, null, buff.effect.features, cost_tar)
			if main_tar == []:
				日志系统.callv("录入信息", [name, "_buff判断", [buff, 影响, targets], 0])
				return 0
				
			else :
				if buff.触发:
					var effect:战斗_单位管理系统.Effect_sys = buff.触发
					if effect.features.has("触发"):
						连锁系统.next_可发动的效果[effect] = main_tar
			
			日志系统.callv("录入信息", [name, "_buff判断", [buff, 影响, targets], 1])
			return 1
	
	return -1
