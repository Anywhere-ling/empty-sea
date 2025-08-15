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
	可以继续.connect(_可以继续的信号)
	动画完成.connect(_动画完成的信号)


func 等待动画完成() -> void:
	if 未完成的动画 != 0:
		await 全部动画完成


func _add_history(data_sys:战斗_单位管理系统.Data_sys, tapy:String, data = null) -> void:
	data_sys.add_history(tapy, 回合系统.turn, 回合系统.period, data)

func _可以继续的信号() -> void:
	未完成的动画 += 1

func _动画完成的信号() -> void:
	未完成的动画 -= 1

func _请求动画(nam:String, data:Dictionary) -> void:
	event_bus.push_event("战斗_请求动画", [nam, data])



func 行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	card.get_parent().remove_card(card)
	life.cards_pos["行动"].add_card(card)
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#动画
	_请求动画("行动打出", {"life":life, "card":card})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "行动打出", [life, card], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("打出", [null, life, card])
	
	
	return true


func 非行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	card.get_parent().remove_card(card)
	pos.add_card(card)
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#动画
	_请求动画("非行动打出", {"life":life, "card":card, "pos":pos})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "非行动打出", [life, card, pos], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("打出", [null, life, card])
	
	return true


func 构造(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	card.get_parent().remove_card(card)
	pos.add_card(card)
	pos.move_card(card, 0)
	card.state = true
	_add_history(life, "构造", card)
	_add_history(card, "构造")
	
	#动画
	_请求动画("构造", {"life":life, "card":card, "pos":pos})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "构造", [life, card, pos], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("构造", [null, life, card])
	
	return true


func 非场上发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#检查
	var o_pos:String = card.get_parent().nam
	
	
	card.get_parent().remove_card(card)
	pos.add_card(card)
	
	#动画
	_请求动画("非场上发动", {"life":life, "card":card, "pos":pos})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "非场上发动", [life, card, pos], true])
	
	
	return true


func 改变方向(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	if card.direction == 1:
		card.direction = 0
	elif card.direction == 0:
		card.direction = 1
	card.reset_appear()
	_add_history(card, "改变方向")
	
	#动画
	_请求动画("改变方向", {"life":life, "card":card})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "改变方向", [life, card], true])
	
	
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
	_请求动画("反转", {"life":life, "card":card})
	await 可以继续
	#后续
	
	
	日志系统.callv("录入信息", [name, "反转", [life, card], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("反转", [null, life, card])
	
	return true


func 破坏(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#判断
	if card.pos == "绿区":
		
		日志系统.callv("录入信息", [name, "破坏", [life, card], false])
		return false
	
	
	card.get_parent().remove_card(card)
	life.cards_pos["绿区"].add_card(card)
	_add_history(card, "破坏")
	
	#动画
	_请求动画("破坏", {"life":life, "card":card})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "破坏", [life, card], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("破坏", [null, life, card])
	
	return true


func 加入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#判断
	if card.get_parent() == pos:
		
		日志系统.callv("录入信息", [name, "加入", [life, card, pos], false])
		return false
	
	
	card.get_parent().remove_card(card)
	pos.add_card(card)
	_add_history(life, "加入", card)
	_add_history(card, "加入", pos.nam)
	
	
	#动画
	_请求动画("加入", {"life":life, "card":card, "pos":pos})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "加入", [life, card, pos], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("加入", [null, life, card])
	
	return true


func 插入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#判断
	if card.get_parent() == pos:
		
		日志系统.callv("录入信息", [name, "加入", [life, card, pos], false])
		return false
	
	
	card.get_parent().remove_card(card)
	pos.add_card(card)
	pos.move_card(card, 1)
	_add_history(life, "插入", card)
	_add_history(card, "插入", pos.nam)
	
	
	#动画
	_请求动画("加入", {"life":life, "card":card, "pos":pos})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "插入", [life, card, pos], true])
	
	
	return true


func 创造(card_name:String) -> 战斗_单位管理系统.Card_sys:
	var card:= 单位管理系统.create_card(card_name)
	临时pos.add_card(card)
	card.face_up()
	if await card.get_value("种类") == "环境":
		card.direction = 0
	_add_history(card, "创造")
	
	#动画
	_请求动画("创造", {"card":card})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "创造", [card_name], true])
	
	
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
	card.get_parent().remove_card(card)
	life.cards_pos["手牌"].add_card(card)
	_add_history(life, "抽牌", card)
	_add_history(card, "抽牌")
	
	#动画
	_请求动画("抽牌", {"life":life, "card":card})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "抽牌", [life], true])
	
	
	await buff系统.单位与全部buff判断("抽牌", [null, life, card])
	
	return true


func 释放(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	card.get_parent().remove_card(card)
	临时pos.add_card(card)
	_add_history(life, "释放", card)
	_add_history(card, "释放")
	
	#动画
	_请求动画("释放", {"life":life, "card":card})
	await 可以继续
	
	#后续
	日志系统.callv("录入信息", [name, "释放", [life, card], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("释放", [null, life, card])
	
	return true


func 攻击(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, mode:String) -> bool:
	_add_history(life, mode, card)
	_add_history(card, mode)
	
	#动画
	if mode == "直接攻击":
		_请求动画("直接攻击", {"life":life, "card":card, "mode":mode})
	await 可以继续
	#后续
	
	日志系统.callv("录入信息", [name, "攻击", [life, card, mode], true])
	
	
	#buff判断
	await buff系统.单位与全部buff判断("攻击", [null, life, card])
	await buff系统.单位与全部buff判断(mode, [null, life, card])
	
	return true


func 加入战斗(控制, is_positive:bool) -> 战斗_单位管理系统.Life_sys:
	#生成life
	var life = 单位管理系统.create_life(控制, is_positive)
	
	
	#动画
	_请求动画("加入战斗", {"life":life, "is_positive":is_positive})
	await 可以继续
	
	控制.life_sys = life
	单位管理系统.创造牌库(life, 控制.创造牌库())
	
	
	日志系统.callv("录入信息", [name, "加入战斗", [life, is_positive], life])
	return life



func 死亡(life:战斗_单位管理系统.Life_sys) -> bool:
	#动画
	_请求动画("死亡", {"life":life})
	await 可以继续
	#后续
	
	日志系统.callv("录入信息", [name, "死亡", [life], true])
	_add_history(life, "死亡")
	
	
	return true




#纯动画
func 加入连锁的动画(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, effect_ind:int, speed:int) -> bool:
	#动画
	_请求动画("加入连锁的动画", {"life":life, "card":card, "effect_ind":effect_ind, "speed":speed})
	await 可以继续
	
	日志系统.callv("录入信息", [name, "加入连锁的动画", [life, card, effect_ind, speed], true])
	return true

func 退出连锁的动画(card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	_请求动画("退出连锁的动画", {"card":card})
	await 可以继续
	
	日志系统.callv("录入信息", [name, "退出连锁的动画", [card], true])
	return true

func 图形化数据改变(card:战斗_单位管理系统.Card_sys, key:String) -> bool:
	#动画
	_请求动画("图形化数据改变", {"card":card, "key":key})
	await 可以继续
	
	日志系统.callv("录入信息", [name, "图形化数据改变", [card, key], true])
	
	return true

func 创造牌库(life:战斗_单位管理系统.Life_sys) -> bool:
	#动画
	_请求动画("创造牌库", {"life":life})
	await 可以继续
	
	日志系统.callv("录入信息", [name, "创造牌库", [life], true])
	
	return true

func 整理手牌(life:战斗_单位管理系统.Life_sys) -> bool:
	#动画
	_请求动画("整理手牌", {"life":life})
	await 可以继续
	
	日志系统.callv("录入信息", [name, "整理手牌", [life], true])
	
	return true

func 场上发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	_请求动画("场上发动", {"life":life, "card":card})
	await 可以继续
	#后续
	
	日志系统.callv("录入信息", [name, "场上发动", [life, card], true])
	
	
	return true

func 无效(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	_请求动画("无效", {"life":life, "card":card})
	await 可以继续
	#后续
	
	日志系统.callv("录入信息", [name, "无效", [life, card], true])
	
	
	return true


#无动画
func 直接释放(card:战斗_单位管理系统.Card_sys) -> void:
	日志系统.callv("录入信息", [name, "直接释放", [card], null])
	
	释放与源.all_mp += 1
	if card.nam!= "源" and !释放与源.cards.has(card.nam):
		释放与源.cards.append(card.nam)
	
	临时pos.remove_card(card)
	card.free_self()
