extends 战斗_单位控制
class_name 战斗_单位控制_nocard


var 最后手牌:Array[String]
var 最后手牌中的绿牌:Array[String]

var 已经打出过牌:bool = false

func 创造牌库() -> Array:
	var cards原数据:Array = life_sys.data["效果"].duplicate(true)
	
	var int总概率:float = 0
	var cards概率:Dictionary = {}#{累加概率:card}
	var card单个概率:Dictionary = {}
	
	var 牌库:Array[String]
	
	for i:Array in cards原数据:
		var i1:float
		if i[-1].is_valid_float():
			i1 = float(i[-1])
			i.remove_at(i.size() - 1)
		else :
			i1 = 1
		
		if i1 == 0:
			牌库.append_array(i)
			continue
		
		
		int总概率 += i1
		cards概率[int总概率] = i
		
		for i2:String in i:
			if card单个概率.has(i2):
				card单个概率[i2] += i1
			else :
				card单个概率[i2] = i1
	
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
		var 概率太小的保险:int = 牌库的数量
		var 次数:int = 0
		while !card or !DatatableLoader.get_data_model("card_data", card).种类 in ["攻击", "防御"]:
			次数 += 1
			if 次数 > 概率太小的保险:
				break
			
			var ram:float = RandomNumberGenerator.new().randf_range(0, 1)
			for i1:float in card单个概率:
				if ram <= i1:
					card = card单个概率[i1]
					break
		填充.append(card)
	for i:int in 进入蓝区的数量:
		var card:String
		while !card or !DatatableLoader.get_data_model("card_data", card).种类 in ["法术", "仪式"]:
			var ram:float = RandomNumberGenerator.new().randf_range(0, 1)
			for i1:float in card单个概率:
				if ram <= i1:
					card = card单个概率[i1]
					break
		填充.append(card)
	
	var 最后抽到的牌:String = 填充[0]
	填充.remove_at(0)
	填充.shuffle()
	填充.append(最后抽到的牌)
	
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


func 确认目标(lifes:Array[战斗_单位管理系统.Life_sys], efils:Array[战斗_单位管理系统.Life_sys]) -> void:
	if lifes.has(life_sys):
		life_sys.face_life = efils[0]
	else:
		life_sys.face_life = lifes[0]


func 第一次弃牌() -> Array:
	var 手牌:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards
	var ret:Array[战斗_单位管理系统.Card_sys] = 手牌.duplicate(true)
	for i:战斗_单位管理系统.Card_sys in 手牌:
		var card_name:String = i.nam
		if 最后手牌中的绿牌.has(card_name):
			ret.erase(i)
			最后手牌中的绿牌.erase(card_name)
	
	return ret


func 整理手牌() -> Array:
	var 手牌:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards.duplicate(true)
	var ret:Array[战斗_单位管理系统.Card_sys]
	for i:String in 最后手牌:
		for i1:战斗_单位管理系统.Card_sys in 手牌:
			if i1.nam == i:
				ret.append(i1)
				手牌.erase(i1)
				break
	ret.append_array(手牌)
	
	return ret


func 对象选择(arr:Array, count:int = 1, is_all:bool = true):
	var ret:Array = []
	arr.shuffle()
	if !is_all and len(arr) <= count:
		return arr
	for i:int in count:
		ret.append(arr[i])
	return ret


func 发动(可发动:Array[战斗_单位管理系统.Card_sys]) -> 战斗_单位管理系统.Card_sys:
	var ret:战斗_单位管理系统.Card_sys
	#发动
	if 可发动 != []:
		ret = 可发动[0]
	
		
	return ret

func 打出(可打出:Array[战斗_单位管理系统.Card_sys]) -> 战斗_单位管理系统.Card_sys:
	var ret:战斗_单位管理系统.Card_sys
	#打出
	if 可打出 != [] and !已经打出过牌:
		var cards:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards
		if 可打出.has(cards[0]):
			ret = cards[0]
			已经打出过牌 = true
	
	if !ret:
		emit_signal("结束")
		
	return ret


signal 主要阶段的一次打出或发动完成
func 主要阶段():
	await 主要阶段的一次打出或发动完成
	主要阶段打出()
	await 主要阶段的一次打出或发动完成
	
	var count:float = 0
	while count <= 3:
		count += RandomNumberGenerator.new().randf()
		主要阶段发动()
		await 主要阶段的一次打出或发动完成
	
	已经打出过牌 = false
	emit_signal("结束")

func 主要阶段打出() -> void:
	var ret:战斗_单位管理系统.Card_sys
	#打出
	if 打出cards != [] and !已经打出过牌:
		var cards:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards
		if 打出cards.has(cards[0]):
			ret = cards[0]
			已经打出过牌 = true
	
	if ret:
		emit_signal("主要阶段打出的信号", ret)
	else :
		call_deferred("emit_signal", "主要阶段的一次打出或发动完成")


func 主要阶段发动() -> void:
	var ret:战斗_单位管理系统.Card_sys
	#发动
	if 发动cards != []:
		ret = 发动cards[0]
	
	if ret:
		emit_signal("主要阶段发动的信号", ret)
	else :
		call_deferred("emit_signal", "主要阶段的一次打出或发动完成")

func 主要阶段判断(cards1:Array[战斗_单位管理系统.Card_sys], cards2:Array[战斗_单位管理系统.Card_sys]) -> void:
	super(cards1, cards2)
	call_deferred("emit_signal", "主要阶段的一次打出或发动完成")


func 结束阶段弃牌() -> Array[战斗_单位管理系统.Card_sys]:
	var ret:Array[战斗_单位管理系统.Card_sys]
	var cards:Array[战斗_单位管理系统.Card_sys] = life_sys.cards_pos["手牌"].cards.duplicate(true)
	while len(cards) > max(life_sys.speed, 1):
		ret.append(cards[-1])
		cards.remove_at(len(cards) - 1)
	return ret



func 选择一格(arr:Array) -> 战斗_单位管理系统.Card_pos_sys:
	if arr == []:
		return
	return arr[0]


func 选择效果发动(card:战斗_单位管理系统.Card_sys, arr_int:Array[int]) -> int:
	return arr_int[0]


func 选择单位(arr:Array[战斗_单位管理系统.Life_sys]) -> 战斗_单位管理系统.Life_sys:
	var arr1:Array = arr
	arr1.shuffle()
	return arr1[0]
