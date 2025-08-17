extends Node
class_name 战斗_效果处理系统

signal 数据返回


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


var targets:Array = []
#[0:这个效果/buff的依赖/对象卡牌
#1:拥有这次效果/buff的单位
#2:触发这次效果的卡牌/效果/事件
#3:buff的数据/
#]

var card_sys:战斗_单位管理系统.Card_sys

var effect:Array
var features:Array = []

var all_lifes:Array

var 最终行动系统: Node
var 单位控制系统: Node
var 发动判断系统: Node
var 卡牌打出与发动系统: Node
var 单位管理系统: 战斗_单位管理系统
var 日志系统: 战斗_日志系统
var 回合系统: Node
var 连锁系统: Node
var buff系统: Node

func _init(node:Node, eff:Array, lifes:Array, car:战斗_单位管理系统.Card_sys = null, fea:Array = [],  tar:Array = []) -> void:
	最终行动系统 = node.最终行动系统
	单位控制系统 = node.单位控制系统
	发动判断系统 = node.发动判断系统
	卡牌打出与发动系统 = node.卡牌打出与发动系统
	单位管理系统 = node.单位管理系统
	日志系统 = node.日志系统
	回合系统 = node.回合系统
	连锁系统 = node.连锁系统
	buff系统 = node.buff系统
	
	effect = eff
	all_lifes = lifes
	card_sys = car
	features = fea
	targets = tar

	targets.resize(10)


func start() -> Array:
	if await _effect_process(effect):
		return targets
	else :
		return []

func _effect_process(p_effect:Array) -> bool:
	for i:int in len(p_effect):
		if card_sys.is_无效():
			await 最终行动系统.无效(card_sys.get_parent().get_parent(), card_sys)
			return false
		
		var arr:Array = p_effect[i].duplicate(true)
		if arr[0] in effect标点:
			var eff_nam:String = arr.pop_at(0)
			if !await effect标点[eff_nam].call(arr):
				
				日志系统.callv("录入信息", ["战斗_效果处理系统", eff_nam, [arr, targets], false])
				return false
		
		elif arr[0] in effect组件:
			var eff_nam:String = arr.pop_at(0)
			if !await effect组件[eff_nam].call(arr):
				
				日志系统.callv("录入信息", ["战斗_效果处理系统", eff_nam, [arr, targets], false])
				return false

	
	return true



var effect标点:Dictionary ={
	"逐一":_逐一,
}

var effect组件:Dictionary = {
	"初始对象":_初始对象,
	"初始区":_初始区,
	"以全局数据为对象":_以全局数据为对象,
	"以数据为对象":_以数据为对象,
	"以单位为对象":_以单位为对象,
	"以区为对象":_以区为对象,
	"以序号为对象":_以序号为对象,
	"改变主视角":_改变主视角,
	
	"对象处理":_对象处理,
	"数据判断":_数据判断,
	"计算相似度":_计算相似度,
	"效果判断":_效果判断,
	"非条件卡牌筛选":_非条件卡牌筛选,
	"格筛选":_格筛选,
	"合成检测":_合成检测,
	
	"取卡牌对象":_取卡牌对象,
	"取格对象":_取格对象,
	
	"加入":_加入,
	"破坏":_破坏,
	"反转":_反转,
	"改变方向":_改变方向,
	"盖放":_盖放,
	"释放":_释放,
	"创造":_创造,
	"去掉":_去掉,
	"插入":_插入,
	"改变可视数据":_改变可视数据,
	"改变单位可视数据":_改变单位可视数据,
	"删除可视数据改变":_删除可视数据改变,
	"阻止":_阻止,
	"合成":_合成,
	
	"添加buff":_添加buff,
}



func _get_array(a) -> Array:
	if !a:
		return []
	if a is Array:
		return a
	return [a]

func _get_sub_index(sub:String) -> int:
	if sub.find("对象") == -1:
		return -1
	return int(sub.erase(0, 2))

func _get_cards(sub:String) -> Array:
	if !targets[_get_sub_index(sub)]:
		return []
	var data0 = targets[_get_sub_index(sub)]
	data0 = _get_array(data0).duplicate(true)
	for i in data0:
		if !i is 战斗_单位管理系统.Card_sys:
			return []
	return data0

func _get_bool(sub:String) -> bool:
	if sub == "是":
		return true
	else:
		return false

func has_element(arr, target) -> bool:
	for item in arr:
		if item == target:  # 找到目标元素
			return true
		elif item is Array:  # 如果是子数组，递归检查
			if has_element(item, target):
				return true
	return false  # 遍历完未找到

#func _(data:Array) -> bool:return true

func _逐一(data:Array) -> bool:
	var index:String = data[0]
	if _get_sub_index(index) == -1:
		return false
	var data0 = targets[_get_sub_index(data[0])].duplicate(true)
	
	if !data0 is Array:
		return false
	
	data.remove_at(0)
	var ret:bool = false
	
	for i in data0:
		targets[_get_sub_index(index)] = i
		if await  _effect_process(data):
			ret = true
	
	targets[_get_sub_index(index)] = data0
	
	return ret



func _改变主视角(data:Array) -> bool:
	var poss:Array = []
	var data0 = data[0]
	if _get_sub_index(data0) != -1:
		data0 = _get_array(targets[_get_sub_index(data0)])[0]
		
	match data0 :
		"攻击目标":data0 = [targets[1].att_life]
		"自己":data0 = [targets[1]]
		"对面":data0 = [targets[1].face_life]
		"敌人":data0 = all_lifes[int(all_lifes[0].has(targets[1]))]
		"友方":data0 = all_lifes[int(!all_lifes[0].has(targets[1]))]
		"全部":data0 = all_lifes[0] + all_lifes[1]
	
	
	targets[1] = data0
	
	return true

func _初始区(data:Array) -> bool:
	var poss:Array = []
	var data0:Array
	for i in data[0]:
		if _get_sub_index(i) != -1:
			i = targets[_get_sub_index(i)]
		data0.append(i)
		
	#目标单位
	var lifes:Array = []
	match data[1] :
		"攻击目标":lifes = [targets[1].att_life]
		"自己":lifes = [targets[1]]
		"对面":lifes = [targets[1].face_life]
		"敌人":lifes = all_lifes[int(all_lifes[0].has(targets[1]))]
		"友方":lifes = all_lifes[int(!all_lifes[0].has(targets[1]))]
		"全部":lifes = all_lifes[0] + all_lifes[1]
		
	for life:战斗_单位管理系统.Life_sys in lifes:
		for pos:String in data0:
			if pos == "场上":
				for i:int in 6:
					poss.append(life.cards_pos[pos][i])
			elif pos.is_valid_int():
				poss.append(life.cards_pos["场上"][int(pos)])
			else :
				poss.append(life.cards_pos[pos])
	
	#对象
	targets[_get_sub_index(data[2])] = poss
	
	return true

func _初始对象(data:Array) -> bool:
	var cards:Array = []
	
	#目标单位
	var poss:Array = _get_array(targets[_get_sub_index(data[0])])
	
	
	for pos:战斗_单位管理系统.Card_pos_sys in poss:
		if pos.nam == "场上":
			if pos.cards:
				var cards1:Array = pos.cards.duplicate(true)
				cards.append(cards1.pop_at(0))
				cards.append_array(单位管理系统.get_给定显示以上的卡牌(cards1, 2))
		else :
			cards.append_array(pos.cards)
	
	#对象
	
	targets[_get_sub_index(data[1])] = cards
	
	return true

func _以全局数据为对象(data:Array) -> bool:
	#提取数据
	
	var ret
	if data[0] == "连锁状态":
		ret = 连锁系统.chain_state
	elif data[0] == "回合阶段":
		ret = 回合系统.period
	elif data[0] == "回合单位":
		ret = 回合系统.current_life
	elif data[0] == "回合数":
		ret = 回合系统.turn
	
	if ret == null:
		return false
	targets[_get_sub_index(data[1])] = ret
		
	
	return true

func _以数据为对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	if data0 == []:
		return false
	data0 = data0[0]
	
	
	var ret
	if data[1] == "位置":
		ret = data0.pos
	elif data[1] == "显现":
		ret = data0.appear
	elif data[1] == "方向":
		ret = data0.direction
	elif data[1] == "上一位置":
		if len(data0.his_pos) >= 2:
			ret = data0.his_pos[-2]
		else:
			return false
	
	if !data0.appear:
		pass
	elif data[1] == "构造状态":
		ret = int(data0.state)
	elif data[1] == "素材数量":
		var pos:战斗_单位管理系统.Card_pos_sys = data0.get_parent()
		if pos.nam != "场上":
			return false
		ret = []
		for card in pos.cards:
			if card.appear == 1:
				ret.append(card)
		ret = len(ret)
	else :
		ret = data0.get_value(data[1])
		if data[1] in ["sp", "mp"]:
			ret = int(ret)
	
	if ret == null:
		return false
	targets[_get_sub_index(data[2])] = ret
		
	
	return true

func _以单位为对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	if data0 == []:
		return false
	data0 = data0[0]
	
	var pos:战斗_单位管理系统.Card_pos_sys = data0.get_parent()
	if pos.name == "临时":
		return false
	
	targets[_get_sub_index(data[1])] = pos.get_parent()
	
	return true

func _以区为对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	if data0 == []:
		return false
	data0 = data0[0]
	
	var pos:战斗_单位管理系统.Card_pos_sys = data0.get_parent()
	if pos.name == "临时":
		return false
	
	targets[_get_sub_index(data[1])] = pos
	
	return true

func _以序号为对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_array(targets[_get_sub_index(data[0])])
	if data0 == []:
		return false
	data0 = data0[0]
	
	
	if data0.name != "场上":
		return false
	
	var ret:int = data0.get_parent.cards_pos["场上"].find(data0)
	
	
	targets[_get_sub_index(data[2])] = ret
	
	return true



func _对象处理(data:Array) -> bool:
	var data0 = targets[_get_sub_index(data[0])]
	var mode:String = ""
	if _get_sub_index(data[2]) != -1:
		var data2 = _get_array(targets[_get_sub_index(data[2])])
		if data[1] == "加":
			data0 = _get_array(data0)
			data0.append_array(data2)
		elif data[1] == "减":
			for i in data2:
				_get_array(data0).erase(i)
		elif data[1] == "复制或乘算":
			if data0 is Array:
				for i in data0.duplicate(true):
					data0.erase(i)
				for i in data2:
					data0.append(i)
			else :
				data0 = data2
	
	elif data0 is Array:
		if data[1] == "加":
			data0.append(data[2])
		elif data[1] == "减":
			data0.erase(data[2])
		elif data[1] == "复制或乘算":
			for i in data0.duplicate(true):
				data0.erase(i)
			data0.append(data[2])
	
	elif data[2].is_valid_float():
		if !data0 is int and !data0 is float:
			return false
		if data[1] == "加":
			data0 += float(data[2])
		elif data[1] == "减":
			data0 -= float(data[2])
		elif data[1] == "复制或乘算":
			data0 = data0 * float(data[2])
	
	
	
	else :
		if !data0 is String:
			return false
		if data[1] == "加":
			data0 += data[2]
		elif data[1] == "减":
			for i in data[2]:
				data0.erase(data0.find(i))
		elif data[1] == "复制或乘算":
			data0 = data[2]
	
	targets[_get_sub_index(data[0])] = data0
	return true

func _数据判断(data:Array) -> bool:
	#提取数据
	var data0 = targets[_get_sub_index(data[0])]
	var data2
	if !data[2].is_valid_float() and _get_sub_index(data[2]) != -1:
		data2 = _get_array(targets[_get_sub_index(data[2])])
	else :
		data2 = data[2]
	
	
	
	
	#判断
	if data0 is String:
		if !data2 is String:
			return false
	elif data0 is Array:
		if !data2 is Array:
			return false
	elif data0 is int or data0 is float:
		if !(data2 is float or data2 is int or (data2 is String and data2.is_valid_float())):
			return false
		
	if data[1] == "相等":
		if data0 is String:
			return data0 == data2
		elif data0 is Array:
			return data0 == data2
		elif data0 is int:
			return data0 == int(data2)
	
	elif data[1] == "包含":
		if data0 is String:
			return !data0.find(data2) == -1
		elif data0 is Array:
			return data2.all(func(a):return !data0.find(a) == -1)
		elif data0 is int:
			return !str(data0).find(str(data2)) == -1
	
	elif data[1] == "被包含":
		if data0 is String:
			return !data2.find(data0) == -1
		elif data0 is Array:
			return data0.all(func(a):return !data2.find(a) == -1)
		elif data0 is int:
			return !str(data2).find(str(data0)) == -1
	
	
	#转换
	if data0 is String:
		data0 = len(data0)
		data2 = len(data2)
	elif data0 is Array:
		data0 = len(data0)
		data2 = len(data2)
	elif data0 is int:
		data2 = int(data2)
	
	if data[1] == "数量大等于":
		return data0 >= data2
	elif data[1] == "数量小等于":
		return data0 <= data2
	elif data[1] == "数量等于":
		return data0 == data2
		
	
	return false

func _计算相似度(data:Array) -> bool:
	#提取
	var data0 = targets[_get_sub_index(data[0])]
	var data1 = targets[_get_sub_index(data[1])]
	
	if data0 is String:
		#判断
		if !data1 is String:
			return false
		#分割
		data0 = data0.split()
		data1 = data1.split()
	elif data0 is Array:
		if !data1 is Array:
			return false
		data0 = data0.duplicate(true)
		data1 = data1.duplicate(true)
	
	
	var o_count:int = len(data1)
	
	for i in data0:
		data1.erase(i)
	
	targets[_get_sub_index(data[0])] = o_count - len(data1)
	
	return true

func _效果判断(data:Array) -> bool:
	#提取
	var data0 = targets[_get_sub_index(data[0])].duplicate(true)
	if !data0 is Array:
		return false
	
	if !has_element(data0, data[1]):
		return false
	
	return true

func _非条件卡牌筛选(data:Array) -> bool:
	#提取
	var data0 = _get_cards(data[0])
	if !data0:
		return false
	var data1:String = data[1]
	var data2:int = int(data[2])
	
	if data2 > data0.size():
		return false
	
	var ret:Array
	if data1 == "随机":
		data0.shuffle()
	elif data1 == "倒序":
		data0.reverse()
	
	for i in data2:
		ret.append(data0[i])
	
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _格筛选(data:Array) -> bool:
	#提取
	var data0 = targets[_get_sub_index(data[0])].duplicate(true)
	if !data0:
		return false
	var data1:Array = data[1]
	
	
	var ret:Array = 卡牌打出与发动系统.get_可用的格子(data0, data1)
	
	
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _合成检测(data:Array) -> bool:
	#提取
	var life:战斗_单位管理系统.Life_sys = targets[1]
	var 蓝区cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["蓝区"].cards, 3)
	var 场上cards:Array[战斗_单位管理系统.Card_sys]
	for i in 6:
		if life.cards_pos["场上"][i].cards:
			场上cards.append(life.cards_pos["场上"][i].cards[0])
	场上cards = 单位管理系统.get_给定显示以上的卡牌(场上cards, 2)
	var 手牌cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["手牌"].cards, 3)
	
	var data0:Array
	for i in data[0]:
		if _get_sub_index(i) != -1:
			data0.append_array(targets[_get_sub_index(i)].duplicate(true))
		else :
			data0.append_array(蓝区cards)
			data0.append_array(手牌cards)
	var data1:Array
	for i in data[1]:
		if _get_sub_index(i) != -1:
			data1.append_array(targets[_get_sub_index(i)].duplicate(true))
		else :
			data1.append_array(蓝区cards)
			data1.append_array(场上cards)
	var data2:Array
	for i in data[2]:
		if _get_sub_index(i) != -1:
			data2.append_array(targets[_get_sub_index(i)].duplicate(true))
		else :
			data2.append_array(蓝区cards)
			data2.append_array(场上cards)
	
	
	if !发动判断系统.合成构造判断(data0, data1, data2):
		return false
	
	
	return true



func _取卡牌对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	if data0 == []:
		return false
	
	var 最小数量:int = int(data[3])
	var 最大数量:int = int(data[2])
	var 描述:String = data[1]
	if 最小数量 == -1:
		最小数量 = 最大数量
	assert(最大数量 > -1, "卡牌data数据错误")
	
	if len(data0) < 最小数量:
		return false
	
	for card in data0:
		var life = card.get_parent().get_parent()
		await buff系统.单位与全部buff判断("可被取为对象", [card, null, card_sys, data0])
	
	var ret:Array = await 单位控制系统.请求选择(targets[1], 描述, data0, 最大数量, 最小数量)
	
	for card in ret:
		var life = card.get_parent().get_parent()
		await buff系统.单位与全部buff判断("被取为对象", [card, null, card_sys, ret])
	
	
	
	if !ret:
		return false
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _取格对象(data:Array) -> bool:
	#提取数据
	var data0 = targets[_get_sub_index(data[0])].duplicate(true)
	
	if data0 == []:
		return false
	
	var 最小数量:int = int(data[3])
	var 最大数量:int = int(data[2])
	var 描述:String = data[1]
	if 最小数量 == -1:
		最小数量 = 最大数量
	assert(最大数量 > -1, "卡牌data数据错误")
	
	if len(data0) < 最小数量:
		return false
	
	var ret:Array = await 单位控制系统.请求选择多格(targets[1], 描述, data0, 最大数量, 最小数量)
	
	if ret == []:
		return false
	targets[_get_sub_index(data[0])] = ret
	
	return true



func _加入(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	var pos:战斗_单位管理系统.Card_pos_sys = _get_array(targets[_get_sub_index(data[1])])[0]
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 最终行动系统.加入(targets[1], i, pos):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _破坏(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	
	var ret:bool = true
	for card:战斗_单位管理系统.Card_sys in data0:
		var pos:战斗_单位管理系统.Card_pos_sys = card.get_parent()
		if !await 最终行动系统.破坏(pos.get_parent(), card):
			ret = false
		if pos.nam == "场上":
			var cards1:Array = []
			for i in pos.cards:
				if i.appear == 1:
					cards1.append(i)
			
			for i:战斗_单位管理系统.Card_sys in cards1:
				var life:战斗_单位管理系统.Life_sys = i.get_parent().get_parent()
				await 最终行动系统.加入(life, i, life.cards_pos["绿区"])
	
	
	await 最终行动系统.等待动画完成()
	return ret

func _反转(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 最终行动系统.反转(i.get_parent().get_parent(), i):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _改变方向(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 最终行动系统.改变方向(i.get_parent().get_parent(), i):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _盖放(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	var data1 = targets[_get_sub_index(data[1])][0]
	if !data0:
		return false
	
	if !data1:
		return false
	var pos:战斗_单位管理系统.Card_pos_sys = data1
	
	var ret:bool = true
	
	for card:战斗_单位管理系统.Card_sys in data0:
		if card.appear:
			if !await 最终行动系统.反转(card.get_parent().get_parent(), card):
				ret = false
				continue
		
		if !await 最终行动系统.加入(card.get_parent().get_parent(), card, pos):
			ret = false
			continue
		
		if card.direction:
			if !await 最终行动系统.改变方向(card.get_parent().get_parent(), card):
				ret = false
				continue
	
	await 最终行动系统.等待动画完成()
	return ret

func _释放(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 最终行动系统.释放(i.get_parent().get_parent(), i):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _创造(data:Array) -> bool:
	#提取数据
	var data0
	if _get_sub_index(data[0]) != -1:
		data0 = targets[_get_sub_index(data[0])].duplicate(true)
		data0 = _get_array(data0)
		if data0:
			data0 = data0[0]
		else :
			return false
	else :
		data0 = data[0]
	
	
	var ret = await 最终行动系统.创造(data0)
	
	if !ret:
		return false
	
	targets[_get_sub_index(data[1])] = [ret]
	
	await 最终行动系统.等待动画完成()
	return true

func _去掉(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	var cards1:Array
	for i in data0:
		var pos:战斗_单位管理系统.Card_pos_sys = i.get_parent()
		if pos.nam != "场上":
			return false
		
		for card in pos.cards:
			if card.appear == 1:
				cards1.append(card)
	
	if len(cards1) < int(data[1]):
		return false
	
	var cards2:Array
	for i in int(data[1]):
		cards2.append(cards1[i])
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in cards2:
		var life:战斗_单位管理系统.Life_sys = i.get_parent().get_parent()
		if !await 最终行动系统.加入(life, i, life.cards_pos["绿区"]):
			ret = false
	
	if _get_sub_index(data[2]) != -1:
		targets[_get_sub_index(data[2])] = cards2
	
	await 最终行动系统.等待动画完成()
	return ret

func _插入(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	var pos:战斗_单位管理系统.Card_pos_sys = _get_array(targets[_get_sub_index(data[1])])[0]
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		if !await 最终行动系统.插入(targets[1], i, pos):
			ret = false
	
	await 最终行动系统.等待动画完成()
	return ret

func _改变可视数据(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	var data1 = data[1]
	var data2 = data[2]
	var data3 = data[3]
	if _get_sub_index(data[3]) != -1:
		data3 = targets[_get_sub_index(data[3])]
	
	var ind:int = 单位管理系统.get_数据改变唯一标识()
	if data1 in ["sp", "mp"]:
		if data3 is Array:
			data3 = data3[0]
		if !data3.is_valid_float():
			return false
		
		for i in data0:
			i.add_value(data1, [data2, int(data3), ind])
	
	elif data1 in ["特征", "组"]:
		data3 = _get_array(data3)
		for i in len(data3):
			data3[i] = str(data3[i])
		
		for i in data0:
			i.add_value(data1, [data2, data3, ind])
	
	elif data1 in ["卡名"]:
		if data3 is Array:
			data3 = data3[0]
		
		for i in data0:
			i.add_value(data1, [data2, data3.split(), ind])
	
	elif data1 in ["种类"]:
		if data3 is Array:
			data3 = data3[0]
		
		for i in data0:
			i.add_value(data1, [data2, data3, ind])
	
	if _get_sub_index(data[2]) != -1:
		targets[_get_sub_index(data[2])] = ind
	
	for i in data0:
		await 最终行动系统.图形化数据改变(i, data1)
	
	await 最终行动系统.等待动画完成()
	return true

func _改变单位可视数据(data:Array) -> bool:
	#提取数据
	var data0 = _get_array(targets[_get_sub_index(data[0])])
	var data1 = data[1]
	var data2 = data[2]
	var data3 = data[3]
	if _get_sub_index(data[3]) != -1:
		data3 = targets[_get_sub_index(data[3])]
	
	if data1 == "mode":
		data1 = "att_mode"
	
	var ind:int = 单位管理系统.get_数据改变唯一标识()
	if data1 in ["speed"]:
		if data3 is Array:
			data3 = data3[0]
		if !data3.is_valid_float():
			return false
		
		for i in data0:
			i.add_value(data1, [data2, int(data3), ind])
	
	elif data1 in ["att_mode", "state", "组无效"]:
		data3 = _get_array(data3)
		for i in len(data3):
			data3[i] = str(data3[i])
		
		for i in data0:
			i.add_value(data1, [data2, data3, ind])
	
	
	if _get_sub_index(data[2]) != -1:
		targets[_get_sub_index(data[2])] = ind
	
	for i in data0:
		await 最终行动系统.单位图形化数据改变(i, data1)
	
	await 最终行动系统.等待动画完成()
	return true

func _删除可视数据改变(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	var data1 = targets[_get_sub_index(data[1])]
	
	var key:String
	for i in data0:
		key = i.remove_value(data1)
	
	if key:
		for i in data0:
			await 最终行动系统.图形化数据改变(i, key)
	
	return true

func _阻止(data:Array) -> bool:
	#提取数据
	var data0 = _get_array(targets[_get_sub_index(data[0])])
	
	for i:战斗_单位管理系统.Life_sys in data0:
		i.state.append("阻止")
		await 最终行动系统.单位图形化数据改变(i, "state")
	
	
	return true

func _合成(data:Array) -> bool:
	#提取
	var life:战斗_单位管理系统.Life_sys = targets[1]
	var 蓝区cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["蓝区"].cards, 3)
	var 场上cards:Array[战斗_单位管理系统.Card_sys]
	for i in 6:
		if life.cards_pos["场上"][i].cards:
			场上cards.append(life.cards_pos["场上"][i].cards[0])
	场上cards = 单位管理系统.get_给定显示以上的卡牌(场上cards, 2)
	var 手牌cards:Array[战斗_单位管理系统.Card_sys] = 单位管理系统.get_给定显示以上的卡牌(life.cards_pos["手牌"].cards, 3)
	
	var data0:Array
	for i in data[0]:
		if _get_sub_index(i) != -1:
			data0.append_array(targets[_get_sub_index(i)].duplicate(true))
		else :
			data0.append_array(蓝区cards)
			data0.append_array(手牌cards)
	var data1:Array
	for i in data[1]:
		if _get_sub_index(i) != -1:
			data1.append_array(targets[_get_sub_index(i)].duplicate(true))
		else :
			data1.append_array(蓝区cards)
			data1.append_array(场上cards)
	var data2:Array
	for i in data[2]:
		if _get_sub_index(i) != -1:
			data2.append_array(targets[_get_sub_index(i)].duplicate(true))
		else :
			data2.append_array(蓝区cards)
			data2.append_array(场上cards)
	
	var cards:Dictionary = 发动判断系统.合成构造判断(data0, data1, data2)
	if !cards:
		await 最终行动系统.确认信息("没有可进行的合成")
		return false
	
	if !await 单位控制系统.请求合成(targets[1], cards):
		return false
	
	
	return true



func _添加buff(data:Array) -> bool:
	#提取数据
	var data1
	if _get_sub_index(data[2]) != -1:
		data1 = targets[_get_sub_index(data[1])]
	
	var buff: = 单位管理系统.create_buff(data[0], data1, data[2], int(data[3]))
	
	buff.targets = targets
	targets[1].add_buff(buff)
	
	if _get_sub_index(data[4]) != -1:
		targets[_get_sub_index(data[4])] = buff
	
	return true
