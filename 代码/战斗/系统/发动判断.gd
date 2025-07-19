extends 战斗_效果处理系统
class_name 战斗_发动判断系统


var effect可判断:Array = [
	"逐一",
	
	"初始对象",
	"对象处理",
	"以数据为对象",
	"以格为对象",
	"数据判断",
	"取卡牌对象",
	"计算相似度",
	"效果判断",
]


func _effect_process(p_effect:Array) -> bool:
	for i:int in len(p_effect):
		var arr:Array = p_effect[i].duplicate(true)
		#发动判断
		if !arr[0] in effect可判断:
			break
		
		if arr[0] in effect标点:
			var eff_nam:String = arr.pop_at(0)
			if await effect标点[eff_nam].call(arr):
				
				event_bus.push_event("战斗_日志记录", ["战斗_发动判断系统", eff_nam, [arr], true])
			else :
				
				event_bus.push_event("战斗_日志记录", ["战斗_发动判断系统", eff_nam, [arr], false])
				return false
		
		if arr[0] in effect组件:
			var eff_nam:String = arr.pop_at(0)
			if await effect组件[eff_nam].call(arr):
				
				event_bus.push_event("战斗_日志记录", ["战斗_发动判断系统", eff_nam, [arr], true])
			else :
				
				event_bus.push_event("战斗_日志记录", ["战斗_发动判断系统", eff_nam, [arr], false])
				return false

	
	return true
