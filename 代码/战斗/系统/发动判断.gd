extends 战斗_效果处理系统
class_name 战斗_发动判断系统


var effect可判断:Array = [
	"逐一",
	
	"改变主视角",
	"初始区",
	"初始对象",
	"以全局数据为对象",
	"以数据为对象",
	"以单位为对象",
	"以区为对象",
	"以序号为对象",
	"以场上为对象",
	
	"对象处理",
	"数据判断",
	"计算数量",
	"计算相似度",
	"效果判断",
	"非条件卡牌筛选",
	"格筛选",
	"合成检测",
	
	"取卡牌对象",
	"取格对象",
	
	"去除",
	"移动",
]


func _effect_process(p_effect:Array) -> bool:
	for i:int in len(p_effect):
		var arr:Array = p_effect[i].duplicate(true)
		#发动判断
		if !arr[0] in effect可判断:
			break
		
		elif arr[0] in effect标点:
			var eff_nam:String = arr.pop_at(0)
			if !await effect标点[eff_nam].call(arr):
				
				日志系统.callv("录入信息", ["战斗_发动判断系统", eff_nam, [arr, targets], false])
				return false
		
		elif arr[0] in effect组件:
			var eff_nam:String = arr.pop_at(0)
			if !await effect组件[eff_nam].call(arr):
				
				日志系统.callv("录入信息", ["战斗_发动判断系统", eff_nam, [arr, targets], false])
				return false

	
	return true




func _取卡牌对象(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	
	if !data0:
		return false
	
	var 最小数量:int = int(data[3])
	var 最大数量:int = int(data[2])
	var 描述:String = data[1]
	if 最小数量 == -1:
		最小数量 = 最大数量
	assert(最大数量 > -1, "卡牌data数据错误")
	
	if len(data0) < 最小数量:
		return false
	
	
	return true

func _取格对象(data:Array) -> bool:
	#提取数据
	var data0:Array
	for i in _gett(data[0], true, false, 战斗_单位管理系统.Card_pos_sys):
		if i.nam == "场上":
			data0.append(i)
	
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
	
	
	return true



func _去除(data:Array) -> bool:
	#提取数据
	var data0 = _gett(data[0], true, false, 战斗_单位管理系统.Card_sys)
	var data1 = data[1]
	var is_活性:bool = false
	if data1 == "活性":
		is_活性 = true
	
	var cards1:Dictionary
	for card:战斗_单位管理系统.Card_sys in data0:
		for i in card.get_素材(is_活性):
			cards1[i] = card
	
	if len(cards1) < int(data[2]):
		if is_活性:
			return false
		else :
			for card:战斗_单位管理系统.Card_sys in data0:
				for i in card.get_素材(true):
					cards1[i] = card
			if len(cards1) < int(data[2]):
				return false
	
	
	return true


func _移动(data:Array) -> bool:
	var data0 = _gett(data[0], false, false, 战斗_单位管理系统.Card_sys)
	
	var pos:战斗_单位管理系统.Card_pos_sys = _get_array(targets[_get_sub_index(data[1])])[0]
	if pos.nam != "场上" or pos.appear == 4:
		return false
	
	
	return true
