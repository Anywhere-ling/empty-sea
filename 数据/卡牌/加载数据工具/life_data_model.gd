extends Resource
class_name LifeData

@export var 卡名:String
@export var 种类:String
@export var 大小:int
@export var 组:Array
@export var 效果:Array


func get_dic_data() -> Dictionary:
	var dic:Dictionary
	dic["卡名"] = 卡名
	dic["种类"] = 种类
	dic["大小"] = 大小
	dic["组"] = 组
	dic["效果"] = 效果
	
	return dic
