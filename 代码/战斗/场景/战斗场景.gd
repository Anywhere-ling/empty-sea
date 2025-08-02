extends Control

@onready var 战斗系统: Node = $战斗系统
@onready var 最终行动系统: Node = %最终行动系统
@onready var gui控制: 战斗_gui控制 = %gui控制


var 无gui:bool = true

func _text() -> void:
	无gui = false
	await add_life("test", false)
	await add_life(gui控制, true)
	战斗系统.start()
	


func _ready() -> void:
	await DatatableLoader.加载完成
	_text()

func _process(delta: float) -> void:
	if 无gui:
		最终行动系统.emit_signal("可以继续")
		最终行动系统.emit_signal("动画完成")


func add_life(life, is_positive:bool) -> void:
	await 战斗系统.add_life(life, is_positive)
