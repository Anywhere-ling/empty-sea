extends Node

@onready var 效果系统: Node = %效果系统
@onready var 回合系统: Node = %回合系统
@onready var 日志系统: Node = %日志系统


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
	event_bus.subscribe("战斗_连锁处理开始", _战斗_连锁处理开始的信号)
	event_bus.subscribe("战斗_连锁处理结束", _战斗_连锁处理结束的信号)



func _战斗_录入按时间结束的buff的信号(buff:战斗_单位管理系统.Buff_sys, 结束时间:String, 结束次数:int) -> void:
	event_bus.push_event("战斗_日志记录", [name, "_战斗_录入按时间结束的buff的信号", [buff, 结束时间, 结束次数], null])
	
	match 结束时间:
		"开始":start_buffs[回合系统.current_life][buff] = 结束次数
		"结束":end_buffs[回合系统.current_life][buff] = 结束次数
		"连锁处理开始":chain_start_buffs[回合系统.current_life][buff] = 结束次数
		"连锁处理结束":chain_end_buffs[回合系统.current_life][buff] = 结束次数

func 开始阶段结算buff(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "开始阶段结算buff", [life], null])
	
	for i:战斗_单位管理系统.Buff_sys in life.buffs:
		await _buff判断(i, "开始阶段", [null, life, null])
	
	for i:战斗_单位管理系统.Buff_sys in start_buffs[life]:
		start_buffs[life][i] -= 1
		if start_buffs[life][i] == 0:
			i.free_self()

func 结束阶段结算buff(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "结束阶段结算buff", [life], null])
	
	for i:战斗_单位管理系统.Buff_sys in life.buffs:
		await _buff判断(i, "结束阶段", [null, life, null])
	
	for i:战斗_单位管理系统.Buff_sys in end_buffs[life]:
		end_buffs[life][i] -= 1
		if end_buffs[life][i] == 0:
			i.free_self()

func _战斗_连锁处理开始的信号() -> void:
	event_bus.push_event("战斗_日志记录", [name, "_战斗_连锁处理开始的信号", [], null])
	
	for life:战斗_单位管理系统.Life_sys in chain_start_buffs:
		for i:战斗_单位管理系统.Buff_sys in chain_start_buffs[life]:
			chain_start_buffs[life][i] -= 1
			if chain_start_buffs[life][i] == 0:
				i.free_self()

func _战斗_连锁处理结束的信号() -> void:
	event_bus.push_event("战斗_日志记录", [name, "_战斗_连锁处理结束的信号", [], null])
	
	for life:战斗_单位管理系统.Life_sys in chain_start_buffs:
		for i:战斗_单位管理系统.Buff_sys in chain_end_buffs[life]:
			chain_end_buffs[life][i] -= 1
			if chain_end_buffs[life][i] == 0:
				i.free_self()






##1:受影响且通过,0:受影响且未通过，-1:未受影响
func 单位与全部buff判断(影响:String, targets:Array = [null, null, null]) -> int :
	var ret:int = -1
	#对发动单位的buff
	for buff:战斗_单位管理系统.Buff_sys in targets[1].buffs:
		var i:int = _buff判断(buff, 影响, targets)
		if i == 0:
			event_bus.push_event("战斗_日志记录", [name, "单位与全部buff判断", [影响, targets], 0])
			return 0
		elif i == 1:
			ret = 1
	#"全部"buff
	for buff:战斗_单位管理系统.Buff_sys in 全部单位buffs:
		var targets2:Array = targets.duplicate(true)
		targets2[1] = 全部单位buffs[buff]
		
		var i:int = _buff判断(buff, 影响, targets2)
		if i == 0:
			event_bus.push_event("战斗_日志记录", [name, "单位与全部buff判断", [影响, targets], 0])
			return 0
		elif i == 1:
			ret = 1
	
	event_bus.push_event("战斗_日志记录", [name, "单位与全部buff判断", [影响, targets], ret])
	return ret


##1:受影响且通过,0:受影响且未通过，-1:未受影响
func _buff判断(buff:战斗_单位管理系统.Buff_sys, 影响:String, targets:Array = [null, null, null]) -> int:
	if buff.data["影响"].has(影响):
		if 效果系统.效果处理(buff.effect.cost_effect, buff.effect.features, targets):
			if !效果系统.效果处理(buff.effect.main_effect, buff.effect.features, targets):
				event_bus.push_event("战斗_日志记录", [name, "_buff判断", [buff, 影响, targets], 0])
				return 0
			event_bus.push_event("战斗_日志记录", [name, "_buff判断", [buff, 影响, targets], 1])
			return 1
	
	event_bus.push_event("战斗_日志记录", [name, "_buff判断", [buff, 影响, targets], -1])
	return -1
