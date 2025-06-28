extends Node2D
class_name 卡牌四区

@onready var 白区: Button = %白区
@onready var 绿区: Button = %绿区
@onready var 蓝区: Button = %蓝区
@onready var 红区: Button = %红区



func change_ccount(arr:Array[String]) -> void:
	白区.text = arr[0]
	绿区.text = arr[1]
	蓝区.text = arr[2]
	红区.text = arr[3]
