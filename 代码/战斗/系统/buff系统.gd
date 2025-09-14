extends Node

@onready var 效果系统: Node = %效果系统
@onready var 回合系统: Node = %回合系统
@onready var 连锁系统: Node = %连锁系统
@onready var 日志系统: 战斗_日志系统 = %日志系统
@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 全部单位buffs:Array[战斗_单位管理系统.Buff_sys]

#按时间结束的buff次数
var start_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
var end_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
var chain_start_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
var chain_end_buffs:Dictionary[战斗_单位管理系统.Life_sys, Dictionary]
#{life:{buff:{次数}

func _ready() -> void:
	event_bus.subscribe("战斗_连锁处理开始", _战斗_连锁处理开始的信号, 2)
	event_bus.subscribe("战斗_连锁处理结束", _战斗_连锁处理结束的信号, 2)
	event_bus.subscribe("战斗_datasys被删除", func(a):if a is 战斗_单位管理系统.Buff_sys:全部单位buffs.erase(a))



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
	
	await 单位与全部buff判断("开始", [null, life, null])
		
	
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
	
	await 单位与全部buff判断("结束", [null, life, null])
	
	if end_buffs.has(life):
		for i:战斗_单位管理系统.Buff_sys in end_buffs[life]:
			if i:
				end_buffs[life][i] -= 1
				if end_buffs[life][i] == 0:
					i.free_self()
			else :
				end_buffs[life][i] = 0

func _战斗_连锁处理开始的信号() -> void:
	日志系统.callv("录入信息", [name, "_战斗_连锁处理开始的信号", [], null])
	
	await 单位与全部buff判断("连锁处理开始")
	
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
	
	await 单位与全部buff判断("连锁处理结束")
	
	for life:战斗_单位管理系统.Life_sys in chain_start_buffs:
		for i:战斗_单位管理系统.Buff_sys in chain_end_buffs[life]:
			await _buff判断(i, "连锁处理结束", [null, life, null])
			if i:
				chain_end_buffs[life][i] -= 1
				if chain_end_buffs[life][i] == 0:
					i.free_self()
			else :
				chain_end_buffs[life][i] = 0




func create_buff(buff_name, car:战斗_单位管理系统.Card_sys = null, 结束时间:String = "", 结束次数:int = 1) -> 战斗_单位管理系统.Buff_sys:
	var buff: = 战斗_单位管理系统.Buff_sys.new(buff_name, self, car)
	if 结束时间:
		_战斗_录入按时间结束的buff的信号(buff, 结束时间, 结束次数)
	if buff.影响.has("全部"):
		全部单位buffs.append(buff)
		add_child(buff)
	else :
		if car:
			car.get_所属life().add_buff(buff)
	
	日志系统.callv("录入信息", [name, "create_buff", [buff_name, car, 结束时间, 结束次数], buff])
	return buff

func create_buff_noname(影响:Array, eff:Array, car:战斗_单位管理系统.Card_sys) -> 战斗_单位管理系统.Buff_sys:
	var buff: = 战斗_单位管理系统.Buff_sys.new("", self, car)
	buff.nam = car.nam + "的buff"
	buff.影响 = 影响
	var effect := 战斗_单位管理系统.Effect_sys.new(eff, self)
	buff.effect = effect
	buff.add_child(effect)
	
	if buff.影响.has("全部"):
		全部单位buffs.append(buff)
		add_child(buff)
	else :
		if car:
			car.get_所属life().add_buff(buff)
	
	日志系统.callv("录入信息", [name, "create_buff", [car.nam + "的buff", car], buff])
	
	return buff



func free_buff(buff:战斗_单位管理系统.Buff_sys) -> void:
	buff.free_self()



func add_触发与固有buff(card:战斗_单位管理系统.Card_sys) -> void:
	var pos:战斗_单位管理系统.Card_pos_sys = card.get_parent()
	
	for effect:战斗_单位管理系统.Effect_sys in card.effects:
		if effect.features.has("触发") or effect.features.has("固有"):
			for buff:战斗_单位管理系统.Buff_sys in effect.buffs:
				free_buff(buff)
			if card.appear < 2 or card.pos in ["临时", "源区"]:
				continue
			
			var features:Array = await effect.get_value("features")
			if features.has(pos.nam) or features.has("任意"):
				effect.add_buffs()
				continue
			
			
			if ["行动", "手牌", "白区", "绿区", "蓝区", "红区"].any(func(a):return features.has(a)):
				continue
				
			if pos.nam == "场上":
				effect.add_buffs()



##1:受影响且通过,0:受影响且未通过，-1:未受影响
func 单位与全部buff判断(影响:String, targets:Array = [null, null, null]) -> int :
	日志系统.录入日志("单位与全部buff判断", [影响, targets[0], targets[1], targets[2], targets[3]])
	
	var ret:int = -1
	#"全部"buff
	if 影响 =="破坏":
		pass
	for buff:战斗_单位管理系统.Buff_sys in 全部单位buffs:
		if !buff:
			全部单位buffs.erase(null)
		var i:int = await _buff判断(buff, 影响, targets)
		if i == 1:
			ret = 1
	
	#所属
	if targets[1]:
		for buff:战斗_单位管理系统.Buff_sys in targets[1].buffs.duplicate(true):
			
			var i:int = await _buff判断(buff, 影响, targets)
			if i == 1:
				ret = 1
	
	return ret


##1:受影响且通过,0:受影响且未通过，-1:未受影响
func _buff判断(buff:战斗_单位管理系统.Buff_sys, 影响:String, targets:Array) -> int:
	日志系统.录入日志("buff判断", [buff, 影响, targets[0], targets[1], targets[2], targets[3]])
	
	if buff.影响.has(影响):
		
		targets = targets.duplicate(true)
		#依赖判断
		if buff.card:
			if targets[0] and targets[0] != buff.card:
				日志系统.callv("录入信息", [name, "_buff判断", [buff, 影响, targets], -1])
				return -1
			targets[0] = buff.card
		#触发判断
		if buff.触发:
			var effect:战斗_单位管理系统.Effect_sys = buff.触发
			if effect.get_value("features").has("触发"):
				if effect.count < 1 or !连锁系统.add_可发动的效果(effect):
					日志系统.callv("录入信息", [name, "_buff判断", [buff, 影响, targets], -1])
					return -1
		#录入buff的对象
		var new_targets:Array = buff.targets.duplicate(true)
		for i in len(targets):
			new_targets[i] = targets[i]
		targets = new_targets
		
		var cost_tar:Array = targets
		if buff.effect.cost_effect:
			cost_tar = await 效果系统.效果处理(buff.effect.cost_effect, null, buff.effect.features, targets)
		if cost_tar:
			var main_tar:Array = await 效果系统.效果处理(buff.effect.main_effect, null, buff.effect.features, cost_tar)
			if main_tar == []:
				日志系统.callv("录入信息", [name, "_buff判断", [buff, 影响, targets], 0])
				return 0
				
			else :
				if buff.触发:
					var effect:战斗_单位管理系统.Effect_sys = buff.触发
					if effect.get_value("features").has("触发"):
						if effect.features.has("触发"):
							连锁系统.add_可发动的效果(effect, main_tar)
					
					elif effect.get_value("features").has("固有"):
						cost_tar = await 效果系统.效果处理(effect.cost_effect, effect.get_parent(), effect.features, main_tar)
						if cost_tar:
							main_tar = await 效果系统.效果处理(effect.main_effect, effect.get_parent(), effect.features, cost_tar)
			
			日志系统.callv("录入信息", [name, "_buff判断", [buff, 影响, targets], 1])
			return 1
	
	return -1
