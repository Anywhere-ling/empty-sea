extends Resource
class_name EquipData

@export var 卡名:String
@export var 重量:int
@export var 媒介:Array
@export var 卡牌:Array
@export var buff:Array


func get_dic_data() -> Dictionary:
	var dic:Dictionary
	dic["卡名"] = 卡名
	dic["重量"] = 重量
	dic["媒介"] = 媒介
	dic["卡牌"] = 卡牌
	dic["buff"] = buff
	
	return dic
