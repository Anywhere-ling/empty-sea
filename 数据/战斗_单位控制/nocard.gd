extends 战斗_单位控制
class_name 战斗_单位控制_nocard


var 最后手牌:Array[String]
var 最后手牌中的绿牌:Array[String]

func 创造牌库() -> Array:
	var cards原数据:Array = life_sys.data["效果"].duplicate(true)
	
	var int总概率:int = 0
	var cards概率:Dictionary = {}#{累加概率:card}
	var card单个概率:Dictionary = {}
	
	for i:Array in cards原数据:
		var i1:float
		if i[-1].is_valid_float():
			i1 = i[-1]
			i.remove_at(-1)
		else :
			i1 = 1
		
		int总概率 += i1
		cards概率[int总概率] = i
		
		for i2:String in i:
			if card单个概率.has(i2):
				card单个概率[i2] += i1
			else :
				card单个概率[i2] = 0
	
	#转换成{累加概率:card}类型
	var 总单个概率:float = 0
	var card单个概率2:Dictionary
	var 进入蓝区的概率:float
	for i:String in card单个概率:
		总单个概率 += card单个概率[i]
		card单个概率2[总单个概率] = i
		if DatatableLoader.get_data_model("card_data", i).种类 in ["法术", "仪式"]:
			进入蓝区的概率 += card单个概率[i]
	进入蓝区的概率 = 进入蓝区的概率/总单个概率
	card单个概率 = {}
	for i:float in card单个概率2:
		card单个概率[i/总单个概率] = card单个概率2[i]
	
	#计算
	var 手牌数量:int = life_sys.speed
	var 进入蓝区的数量 = _simulate_draw(进入蓝区的概率, 手牌数量, life_sys.data.大小)
	var 牌库的数量:int = life_sys.data.大小#包含手牌
	
	#牌库
	var 牌库:Array[String]
	while len(牌库) < 牌库的数量:
		var ram:int = RandomNumberGenerator.new().randf_range(0, int总概率)
		for i:float in cards概率:
			if ram <= i:
				牌库.append_array(cards概率[i])
				break
	牌库.resize(牌库的数量)
	
	#最后手牌
	
	for i:int in 手牌数量:
		最后手牌.append(牌库[i])
	
	#最后手牌中的绿牌
	
	for i:String in 最后手牌:
		if DatatableLoader.get_data_model("card_data", i).种类 in ["攻击", "防御"]:
			最后手牌中的绿牌.append(i)
	
	#填充弃牌
	var 进入绿区的数量:int = 手牌数量 - len(最后手牌中的绿牌)
	
	for i:String in 最后手牌中的绿牌:
		牌库.erase(i)
	
	var 填充:Array[String] = []
	填充.append_array(最后手牌中的绿牌)
	for i:int in 进入绿区的数量:
		var card:String
		while !card or !DatatableLoader.get_data_model("card_data", card).种类 in ["攻击", "防御"]:
			var ram:int = RandomNumberGenerator.new().randf_range(0, 1)
			for i1:float in card单个概率:
				if ram <= i1:
					card = card单个概率[i1]
					break
		填充.append(card)
	for i:int in 进入蓝区的数量:
		var card:String
		while !card or !DatatableLoader.get_data_model("card_data", card).种类 in ["法术", "仪式"]:
			var ram:int = RandomNumberGenerator.new().randf_range(0, 1)
			for i1:float in card单个概率:
				if ram <= i1:
					card = card单个概率[i1]
					break
		填充.append(card)
	
	填充.append_array(牌库)
	牌库 = 填充
	牌库.resize(牌库的数量)
	
	
	return 牌库

# 单次模拟：返回抽到 y 张 A 时抽到的 B 的数量
func _simulate_draw(b: float, y: int, deck_size: int) -> int:
	var deck = []
	var num_B = int(b * deck_size)
	var num_A = deck_size - num_B

	# 初始化牌堆（0=A, 1=B）
	for i in num_A:
		deck.append(0)
	for i in num_B:
		deck.append(1)
	deck.shuffle()  # 洗牌
	
	var count_A = 0
	var count_B = 0
	
	while count_A < y and deck.size() > 0:
		var card = deck.pop_back()  # 不放回抽牌
		if card == 0:
			count_A += 1
		else:
			count_B += 1
	
	return count_B


func 第一次弃牌() -> Array:
	var 手牌:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards
	var ret:Array[战斗_单位管理系统.Card_sys]
	for i:战斗_单位管理系统.Card_sys in 手牌:
		var card_name:String = i.name
		if 最后手牌中的绿牌.has(card_name):
			ret.append(i)
			最后手牌中的绿牌.erase(card_name)
	
	return ret


func 整理手牌() -> Array:
	var 手牌:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards.duplicate(true)
	var ret:Array[战斗_单位管理系统.Card_sys]
	for i:String in 最后手牌:
		for i1:战斗_单位管理系统.Card_sys in 手牌:
			if i1.name == i:
				ret.append(i1)
				手牌.erase(i1)
				break
	ret.append_array(手牌)
	
	return ret


func 对象选择(arr:Array, count:int = 1, is_all:bool = true):
	var ret:Array = []
	arr.shuffle()
	for i:int in count:
		ret.append(arr[i])
	return ret


func 打出或发动(可发动:Array[战斗_单位管理系统.Card_sys], 可打出:Array[战斗_单位管理系统.Card_sys]) -> 战斗_单位管理系统.Card_sys:
	var ret:战斗_单位管理系统.Card_sys
	#打出
	if 可打出 != []:
		var cards:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards
		可打出.sort_custom(func(a,b):
			assert(cards.find(a) != -1 or cards.find(b) != -1, "不在手牌中")
			return cards.find(a) < cards.find(b))
		ret = 可打出[0]
	#发动
	elif 可发动 != []:
		ret = 可发动[0]
	
	if !ret:
		emit_signal("结束")
		
	return ret


func 选择一格(arr:Array[战斗_单位管理系统.Card_pos_sys]) -> 战斗_单位管理系统.Card_pos_sys:
	if arr == []:
		return
	return arr.pick_random()


func 选择效果发动(card:战斗_单位管理系统.Card_sys, arr_int:Array[int]) -> int:
	return arr_int[0]
