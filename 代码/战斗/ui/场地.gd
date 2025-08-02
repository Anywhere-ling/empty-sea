extends Control
class_name 战斗_场地

@onready var _0: Control = %"0"
@onready var _1: Control = %"1"
@onready var _2: Control = %"2"
@onready var _3: Control = %"3"
@onready var _4: Control = %"4"
@onready var _5: Control = %"5"


func get_posi(pos:String) -> Vector2:
	var node:Control
	match pos:
		"场地0":node = _0
		"场地1":node = _1
		"场地2":node = _2
		"场地3":node = _3
		"场地4":node = _4
		"场地5":node = _5

	return node.global_position
