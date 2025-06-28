extends Node
class_name 战斗_单位控制

var life_sys:战斗_单位管理系统.Life_sys


func _init(life:战斗_单位管理系统.Life_sys) -> void:
	life_sys = life



func 创造牌库() -> Array:
	return []

func 第一次弃牌() -> Array:
	return []

func 整理手牌() -> Array:
	return []

func 行动阶段() -> 战斗_单位管理系统.Card_sys:
	return 

func 主要阶段():
	pass

func 效果发动():
	pass

func 对象选择(arr:Array, count:int = 1, is_all:bool = true):
	pass

func 效果选项():
	pass
