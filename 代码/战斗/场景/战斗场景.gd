extends Control

@onready var 战斗系统: Node = $战斗系统


func _ready() -> void:
	await DatatableLoader.加载完成
	add_life("test", true)
	add_life("test", false)
	战斗系统.start()


func add_life(life, is_positive:bool) -> void:
	战斗系统.add_life(life, is_positive)
