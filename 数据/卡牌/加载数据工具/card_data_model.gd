extends Resource
class_name CardData

@export var 卡名:String
@export var 种类:String
@export var sp:int
@export var mp:int
@export var 特征:Array
@export var 媒介:Array
@export var 组:Array
@export var 文本:String
@export var 效果:Array


func get_dic_data() -> Dictionary:
	var dic:Dictionary
	dic["卡名"] = 卡名
	dic["种类"] = 种类
	dic["sp"] = sp
	dic["mp"] = mp
	dic["特征"] = 特征
	dic["媒介"] = 媒介
	dic["组"] = 组
	dic["文本"] = 文本
	dic["效果"] = 效果
	
	return dic
