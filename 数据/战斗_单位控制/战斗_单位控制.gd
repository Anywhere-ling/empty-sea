extends Node
class_name 战斗_单位控制


signal 结束

var life_sys:战斗_单位管理系统.Life_sys


func _init(life:战斗_单位管理系统.Life_sys) -> void:
	life_sys = life



func 创造牌库() -> Array:
	return []

func 第一次弃牌() -> Array:
	return []

func 整理手牌() -> Array:
	return []

func 打出(cards:Array[战斗_单位管理系统.Card_sys]) -> 战斗_单位管理系统.Card_sys:
	return 

func 发动(cards:Array[战斗_单位管理系统.Card_sys]) -> 战斗_单位管理系统.Card_sys:
	return 


var 发动cards:Array[战斗_单位管理系统.Card_sys]
var 打出cards:Array[战斗_单位管理系统.Card_sys]

signal 主要阶段打出的信号
signal 主要阶段发动的信号

func 主要阶段():
	pass

func 主要阶段打出() -> void:
	return

func 主要阶段发动() -> void:
	return

func 主要阶段判断(cards1:Array[战斗_单位管理系统.Card_sys], cards2:Array[战斗_单位管理系统.Card_sys]) -> void:
	发动cards = cards1
	打出cards = cards2


func 结束阶段弃牌() -> Array[战斗_单位管理系统.Card_sys]:
	return []





func 选择效果发动(card:战斗_单位管理系统.Card_sys, arr_int:Array[int]) -> int:
	return 0

func 对象选择(arr:Array, count:int = 1, is_all:bool = true):
	pass

func 选择一格(arr:Array[战斗_单位管理系统.Card_pos_sys]) -> 战斗_单位管理系统.Card_pos_sys:
	return

func 选择单位(arr:Array[战斗_单位管理系统.Life_sys]) -> 战斗_单位管理系统.Life_sys:
	return

func 效果选项():
	pass
