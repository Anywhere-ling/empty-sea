extends Node


@onready var buff系统: Node = %buff系统
@onready var 回合系统: Node = %回合系统
@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 释放与源: Node = %释放与源
@onready var 日志系统: 战斗_日志系统 = %日志系统

var 临时pos:战斗_单位管理系统.Card_pos_sys

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

signal 可以继续
signal 动画完成
signal 全部动画完成
signal test
var 未完成的动画:int = 0:
	set(value):
		未完成的动画 = value
		if 未完成的动画 == 0:
			emit_signal("全部动画完成")


func _ready() -> void:
	动画完成.connect(_动画完成的信号)


func 等待动画完成() -> void:
	if 未完成的动画 != 0:
		await 全部动画完成


func _add_history(data_sys:战斗_单位管理系统.Data_sys, tapy:String, data = null) -> void:
	if data_sys:
		data_sys.add_history(tapy, 回合系统.turn, 回合系统.period, data)


func _动画完成的信号() -> void:
	未完成的动画 -= 1


var 动画index:int = 0
func _请求动画(nam:String, data:Dictionary) -> void:
	未完成的动画 += 1
	动画index += 1
	var ind:int = 动画index
	data["动画index"] = ind
	
	event_bus.push_event("战斗_请求动画", [nam, data])
	
	var ret:bool = true
	while ret:
		var ret_ind:int = await 可以继续
		if ret_ind == ind:
			ret = false


func 行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	card.remove_self()
	life.cards_pos["行动"].add_card(card)
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#动画
	await _请求动画("行动打出", {"life":life, "card":card})
	
	
	#后续
	日志系统.callv("录入信息", [name, "行动打出", [life, card], true])
	日志系统.录入日志("行动打出", [life, card])
	
	#buff判断
	await buff系统.单位与全部buff判断("打出", [null, life, card])
	
	
	return true


func 非行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	card.remove_self()
	pos.add_card(card)
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#动画
	await _请求动画("非行动打出", {"life":life, "card":card, "pos":pos})
	
	
	#后续
	日志系统.callv("录入信息", [name, "非行动打出", [life, card, pos], true])
	日志系统.录入日志("非行动打出", [life, card, pos])
	
	#buff判断
	await buff系统.单位与全部buff判断("打出", [null, life, card])
	
	return true


func 构造(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	card.remove_self()
	pos.add_card(card)
	card.state = true
	_add_history(life, "构造", card)
	_add_history(card, "构造")
	
	#动画
	await _请求动画("构造", {"life":life, "card":card, "pos":pos})
	
	
	#后续
	日志系统.callv("录入信息", [name, "构造", [life, card, pos], true])
	日志系统.录入日志("构造", [life, card, pos])
	
	#buff判断
	await buff系统.单位与全部buff判断("构造", [null, life, card])
	
	return true


func 非场上发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#检查
	var o_pos:String = card.get_parent().nam
	
	
	card.remove_self()
	pos.add_card(card)
	
	#动画
	await _请求动画("非场上发动", {"life":life, "card":card, "pos":pos})
	
	
	#后续
	日志系统.callv("录入信息", [name, "非场上发动", [life, card, pos], true])
	日志系统.录入日志("非场上发动", [life, card, pos])
	
	return true


func 改变方向(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	if card.direction == 1:
		card.direction = 0
	elif card.direction == 0:
		card.direction = 1
	card.reset_appear()
	_add_history(card, "改变方向")
	
	#动画
	await _请求动画("改变方向", {"life":life, "card":card})
	
	
	#后续
	日志系统.callv("录入信息", [name, "改变方向", [life, card], true])
	日志系统.录入日志("改变方向", [life, card])
	
	#buff判断
	await buff系统.单位与全部buff判断("改变方向", [null, life, card])
	
	return true


func 反转(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	if card.appear == 0:
		card.face_up()
	else:
		card.face_down()
	_add_history(card, "反转")
	
	#动画
	await _请求动画("反转", {"life":life, "card":card})
	
	#后续
	日志系统.callv("录入信息", [name, "反转", [life, card], true])
	日志系统.录入日志("反转", [life, card])
	
	#buff判断
	await buff系统.单位与全部buff判断("反转", [null, life, card])
	
	return true


func 破坏(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#判断
	if card.pos == "绿区":
		
		日志系统.callv("录入信息", [name, "破坏", [life, card], false])
		return false
	
	
	card.remove_self()
	life.cards_pos["绿区"].add_card(card)
	_add_history(card, "破坏")
	
	#动画
	await _请求动画("破坏", {"life":life, "card":card})
	
	
	#后续
	日志系统.callv("录入信息", [name, "破坏", [life, card], true])
	日志系统.录入日志("破坏", [life, card])
	
	#buff判断
	await buff系统.单位与全部buff判断("破坏", [null, life, card])
	
	return true


func 加入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#判断
	if card.get_parent() == pos:
		
		日志系统.callv("录入信息", [name, "加入", [life, card, pos], false])
		return false
	
	
	card.remove_self()
	pos.add_card(card)
	_add_history(life, "加入", card)
	_add_history(card, "加入", pos.nam)
	
	
	#动画
	await _请求动画("加入", {"life":life, "card":card, "pos":pos})
	
	
	#后续
	日志系统.callv("录入信息", [name, "加入", [life, card, pos], true])
	日志系统.录入日志("加入", [life, card, pos])
	
	#buff判断
	await buff系统.单位与全部buff判断("加入", [null, life, card])
	
	return true


func 插入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#判断
	if card.get_parent() == pos:
		
		日志系统.callv("录入信息", [name, "加入", [life, card, pos], false])
		return false
	
	
	card.remove_self()
	pos.add_card(card)
	pos.move_card(card, 1)
	_add_history(life, "插入", card)
	_add_history(card, "插入", pos.nam)
	
	
	#动画
	await _请求动画("加入", {"life":life, "card":card, "pos":pos})
	
	
	#后续
	日志系统.callv("录入信息", [name, "插入", [life, card, pos], true])
	日志系统.录入日志("插入", [life, card, pos])
	
	#buff判断
	await buff系统.单位与全部buff判断("插入", [null, life, card])
	
	return true


func 填入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 源:战斗_单位管理系统.Card_sys) -> bool:
	card.add_源(源)
	_add_history(life, "填入", 源)
	_add_history(card, "填入", 源)
	_add_history(源, "被填入", card)
	
	#动画
	await _请求动画("填入", {"life":life, "card":card, "源":源})
	
	
	#后续
	日志系统.callv("录入信息", [name, "填入", [life, card, 源], true])
	日志系统.录入日志("填入", [源, life, card])
	
	#buff判断
	await buff系统.单位与全部buff判断("填入", [null, life, card, 源])
	
	return true


func 流填入(life:战斗_单位管理系统.Life_sys, 源:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Pos_cs_sys) -> bool:
	pos.add_源(源, life.is_positive)
	_add_history(life, "流填入", 源)
	_add_history(pos, "流填入", 源)
	_add_history(源, "被填入", pos)
	
	#动画
	await _请求动画("流填入", {"life":life, "源":源, "pos":pos})
	
	
	#后续
	日志系统.callv("录入信息", [name, "流填入", [life, 源, pos], true])
	
	
	return true


func 去除(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 源:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	card.remove_源(源)
	pos.add_card(源)
	_add_history(life, "去除", 源)
	_add_history(card, "去除", 源)
	_add_history(源, "被去除", pos)
	
	#动画
	await _请求动画("去除", {"life":life, "card":card, "源":源, "pos":pos})
	
	
	#后续
	日志系统.callv("录入信息", [name, "去除", [life, card, 源, pos], true])
	日志系统.录入日志("去除", [life, card, 源, pos])
	
	#buff判断
	await buff系统.单位与全部buff判断("去除", [null, life, card, 源])
	
	return true


func 创造(life:战斗_单位管理系统.Life_sys, card_name:String) -> 战斗_单位管理系统.Card_sys:
	var card:= 单位管理系统.create_card(card_name)
	card.所属life = life
	临时pos.add_card(card)
	card.face_up()
	if await card.get_value("种类") == "环境":
		card.direction = 0
	_add_history(card, "创造")
	
	#动画
	await _请求动画("创造", {"card":card})
	
	
	#后续
	日志系统.callv("录入信息", [name, "创造", [card_name], true])
	日志系统.录入日志("创造", [life, card])
	
	#buff判断
	await buff系统.单位与全部buff判断("创造", [null, null, card])
	
	return card


func 抽牌(life:战斗_单位管理系统.Life_sys) -> bool:
	#判断
	if life.cards_pos["白区"].cards == []:
		
		日志系统.callv("录入信息", [name, "抽牌", [life], false])
		return false
	
	
	var card:战斗_单位管理系统.Card_sys = life.cards_pos["白区"].cards[0]
	card.face_up()
	card.remove_self()
	life.cards_pos["手牌"].add_card(card)
	_add_history(life, "抽牌", card)
	_add_history(card, "抽牌")
	
	#动画
	await _请求动画("抽牌", {"life":life, "card":card})
	
	
	#后续
	日志系统.callv("录入信息", [name, "抽牌", [life], true])
	日志系统.录入日志("抽牌", [life])
	
	await buff系统.单位与全部buff判断("抽牌", [null, life, card])
	
	return true


func 释放(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#buff判断
	await buff系统.单位与全部buff判断("释放前", [null, life, card])
	
	
	card.remove_self()
	临时pos.add_card(card)
	_add_history(life, "释放", card)
	_add_history(card, "释放")
	
	#动画
	await _请求动画("释放", {"life":life, "card":card})
	
	
	#后续
	日志系统.callv("录入信息", [name, "释放", [life, card], true])
	日志系统.录入日志("释放", [life, card])
	
	
	return true


func 攻击(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, mode:String) -> bool:
	_add_history(life, mode, card)
	_add_history(card, mode)
	
	#动画
	if mode == "直接攻击":
		await _请求动画("直接攻击", {"life":life, "card":card, "mode":mode})
	
	#后续
	
	日志系统.callv("录入信息", [name, "攻击", [life, card, mode], true])
	日志系统.录入日志("攻击", [life, card, mode])
	
	#buff判断
	await buff系统.单位与全部buff判断("攻击", [null, life, card])
	await buff系统.单位与全部buff判断(mode, [null, life, card])
	
	return true


func 加入战斗(控制, is_positive:bool) -> 战斗_单位管理系统.Life_sys:
	#生成life
	var life = 单位管理系统.create_life(控制, is_positive)
	
	
	#动画
	await _请求动画("加入战斗", {"life":life, "is_positive":is_positive})
	
	
	控制.life_sys = life
	单位管理系统.创造牌库(life, 控制.创造牌库())
	
	
	日志系统.callv("录入信息", [name, "加入战斗", [life, is_positive], life])
	return life


func 图形化数据改变(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, key:String) -> bool:
	if key == "组" and card.pos == "红区":
		life.reset_卡名无效()
	#动画
	await _请求动画("图形化数据改变", {"life":life, "card":card, "key":key})
	
	
	日志系统.callv("录入信息", [name, "图形化数据改变", [life, card, key], true])
	
	return true


func 死亡(life:战斗_单位管理系统.Life_sys) -> bool:
	#动画
	await _请求动画("死亡", {"life":life})
	
	#后续
	
	日志系统.callv("录入信息", [name, "死亡", [life], true])
	_add_history(life, "死亡")
	
	
	return true




#纯动画
func 加入连锁的动画(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, effect_ind:int) -> bool:
	#动画
	await _请求动画("加入连锁的动画", {"life":life, "card":card, "effect_ind":effect_ind})
	
	
	日志系统.callv("录入信息", [name, "加入连锁的动画", [life, card, effect_ind], true])
	return true

func 退出连锁的动画(card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	await _请求动画("退出连锁的动画", {"card":card})
	
	
	日志系统.callv("录入信息", [name, "退出连锁的动画", [card], true])
	return true

func 创造牌库(life:战斗_单位管理系统.Life_sys) -> bool:
	#动画
	await _请求动画("创造牌库", {"life":life})
	
	
	日志系统.callv("录入信息", [name, "创造牌库", [life], true])
	
	return true

func 单位图形化数据改变(life:战斗_单位管理系统.Life_sys, key:String) -> bool:
	#动画
	await _请求动画("单位图形化数据改变", {"life":life, "key":key})
	
	
	日志系统.callv("录入信息", [name, "单位图形化数据改变", [life, key], true])
	
	return true

func 整理手牌(life:战斗_单位管理系统.Life_sys) -> bool:
	#动画
	await _请求动画("整理手牌", {"life":life})
	
	
	日志系统.callv("录入信息", [name, "整理手牌", [life], true])
	
	return true

func 场上发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	await _请求动画("场上发动", {"life":life, "card":card})
	
	#后续
	
	日志系统.callv("录入信息", [name, "场上发动", [life, card], true])
	
	
	return true

func 无效(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	await _请求动画("无效", {"life":life, "card":card})
	
	#后续
	
	日志系统.callv("录入信息", [name, "无效", [life, card], true])
	
	
	return true

func 阻止(life:战斗_单位管理系统.Life_sys) -> bool:
	#动画
	await _请求动画("阻止", {"life":life})
	
	#后续
	
	日志系统.callv("录入信息", [name, "阻止", [life], true])
	
	
	return true

func 确认信息(test:String) -> bool:
	#动画
	await _请求动画("确认信息", {"test":test})
	
	#后续
	
	日志系统.callv("录入信息", [name, "确认信息", [test], true])
	
	
	return true

func 开始() -> bool:
	#动画
	await _请求动画("开始", {})
	
	#后续
	
	日志系统.callv("录入信息", [name, "开始", [], true])
	
	
	return true


#无动画
func 直接释放(card:战斗_单位管理系统.Card_sys) -> void:
	日志系统.callv("录入信息", [name, "直接释放", [card], null])
	
	if card.nam!= "源" and !释放与源.cards.has(card.nam):
		释放与源.cards.append(card.nam)
	
	临时pos.remove_card(card)
	card.free_self()
