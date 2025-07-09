extends Node
class_name 战斗_效果处理系统

signal 行动处理完成
signal 数据返回


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


var targets:Array = []
#[0:这个效果/buff的依赖卡牌(如果有
#1:拥有这次效果/buff的单位
#2:触发这次效果的卡牌/效果/事件(如果有
#]

var effect:Array
var features:Array[Array] = []

var all_lifes:Array




func _init(eff:Array, lifes:Array, fea:Array = [],  tar:Array = []) -> void:
	effect = eff
	all_lifes = lifes
	features = fea
	targets = tar.duplicate(true)

	targets.resize(10)


func start() -> Array:
	if _effect_process():
		return targets
	else :
		return []


func _effect_process() -> bool:
	for i:int in len(effect):
		var arr:Array = effect[i].duplicate(true)
		if arr[0] in effect标点:
			if effect标点[arr[0]].call(arr):
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], true])
			else :
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], false])
				return false
		
		if arr[0] in effect组件:
			if effect组件[arr[0]].call(arr):
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], true])
			else :
				
				event_bus.push_event("战斗_日志记录", [name, arr[0], [arr], false])
				return false

	
	return true



var effect标点:Dictionary ={
	
}





var effect组件:Dictionary = {
	
}


func _get_array(a) -> Array:
	if a is Array:
		return a
	return [a]

func _get_sub_index(sub:String) -> int:
	if sub.find("对象") == -1:
		return -1
	return int(sub.erase(0, 2))

func _get_cards(sub:String) -> Array[战斗_单位管理系统.Card_sys]:
	var data0 = targets[_get_sub_index(sub)].duplicate(true)
	data0 = _get_array(data0)
	if !data0[0] is 战斗_单位管理系统.Card_sys:
		return []
	return data0

func has_element(arr, target) -> bool:
	for item in arr:
		if item == target:  # 找到目标元素
			return true
		elif item is Array:  # 如果是子数组，递归检查
			if has_element(item, target):
				return true
	return false  # 遍历完未找到

#func _(data:Array) -> bool:return true

func _初始对象(data:Array) -> bool:
	var cards:Array[战斗_单位管理系统.Card_sys] = []
	
	#目标单位
	var lifes:Array[战斗_单位管理系统.Life_sys] = []
	match data[1] :
		"攻击目标":lifes = [targets[1].att_life]
		"自己":lifes = [targets[1]]
		"敌人":lifes = all_lifes[int(all_lifes[0].has(targets[1]))]
		"友方":lifes = all_lifes[int(!all_lifes[0].has(targets[1]))]
		"全部":lifes = all_lifes[0] + all_lifes[1]
		
	for life:战斗_单位管理系统.Life_sys in lifes:
		for pos:String in data[0]:
			if pos == "场上":
				for i:int in 6:
					cards.append_array(life.cards_pos[pos][i].cards)
			elif pos.is_valid_int():
				cards.append_array(life.cards_pos["场上"][pos].cards)
			else :
				cards.append_array(life.cards_pos[pos].cards)
	
	#对象
	targets[_get_sub_index(data[2])] = cards
	
	return true

func _以一种运算处理对象(data:Array) -> bool:
	var mode:String = ""
	if _get_sub_index(data[2]) == -1:
		if data[1] == "加":
			targets[_get_sub_index(data[0])].append_array(targets[_get_sub_index(data[2])])
		elif data[1] == "减":
			for i in _get_array(targets[_get_sub_index(data[0])]):
				_get_array(targets[_get_sub_index(data[2])]).erase(i)
		elif data[1] == "复制或乘算":
			targets[_get_sub_index(data[0])] = targets[_get_sub_index(data[2])]
	
	elif data[2].is_valied_float:
		if !targets[_get_sub_index(data[0])] is int:
			return false
		if data[1] == "加":
			targets[_get_sub_index(data[0])] += float(data[2])
		elif data[1] == "减":
			targets[_get_sub_index(data[0])] -= float(data[2])
		elif data[1] == "复制或乘算":
			targets[_get_sub_index(data[0])] = targets[_get_sub_index(data[0])] * float(data[2])
	
	else :
		if !targets[_get_sub_index(data[0])] is String:
			return false
		if data[1] == "加":
			targets[_get_sub_index(data[0])] += data[2]
		elif data[1] == "减":
			for i in data[2]:
				targets[_get_sub_index(data[0])].erase(targets[_get_sub_index(data[0])].find(i))
		elif data[1] == "复制或乘算":
			targets[_get_sub_index(data[0])] = targets[_get_sub_index(data[0])] * float(data[2])
	
	return true

func 以数据为对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	if data0 == []:
		return false
	data0 = data0[0]
	if !data0.is_face_up:
		return false
	
	var ret
	if data[1] == "位置":
		ret = data0.get_parent().name
	else :
		ret = data0.get_value(data[1])
		if data[1] in ["sp", "mp"]:
			ret = int(ret)
		
	targets[_get_sub_index(data[2])] = ret
	
	return true

func _以格为对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	if data0 == []:
		return false
	data0 = data0[0]
	
	var pos:战斗_单位管理系统.Card_pos_sys = data0.get_parent()
	if pos.name != "场上":
		return false
	
	var ret:int = targets[1].cards_pos["场上"].find(pos)
	
	if ret == -1:
		return false
	
	targets[_get_sub_index(data[2])] = ret
	
	return true

func _对象条件判断(data:Array) -> bool:
	#提取数据
	var data0 = targets[_get_sub_index(data[0])].duplicate(true)
	var data2
	if _get_sub_index(data[2]) != -1:
		data2 = targets[_get_sub_index(data[2])].duplicate(true)
	else :
		data2 = data[2].duplicate(true)
	#判断
	if data0 is String:
		if !data2 is String:
			return false
	elif data0 is Array:
		if !data2 is Array:
			return false
	elif data0 is int:
		if !(data2 is float or (data2 is String and data2.is_valid_float)):
			return false
		
	if data[1] == "相等":
		if data0 is String:
			return data0 == data2
		elif data0 is Array:
			return data0 == data2
		elif data0 is int:
			return data0 == int(data2)
	
	elif data[1] == "包含":if data0 is String:
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

func _取卡牌对象(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	var ret 
	event_bus.subscribe("战斗_请求选择返回", func(a):
		emit_signal("数据返回")
		ret = a
		, 1, true)
	event_bus.push_event("战斗_请求选择", [targets[1], data0, int(data[2]), bool(int(data[3]))])
	
	await 数据返回
	
	if ret == []:
		return false
	targets[_get_sub_index(data[0])] = ret
	
	return true

func _计算相似度(data:Array) -> bool:
	#提取
	var data0 = targets[_get_sub_index(data[0])].duplicate(true)
	var data1 = targets[_get_sub_index(data[1])].duplicate(true)
	
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



func _加入(data:Array) -> bool:
	#提取数据
	var data0 = _get_cards(data[0])
	
	var pos:战斗_单位管理系统.Card_pos_sys = targets[1].cards_pos[data[1]]
	
	var ret:bool = true
	for i:战斗_单位管理系统.Card_sys in data0:
		event_bus.subscribe("战斗_行动处理完成", func(a):
			emit_signal("行动处理完成")
			ret = a
			, 1, true)
		event_bus.push_event("战斗_行动_加入", [targets[1], i, pos])
		await 行动处理完成
	
	return ret
