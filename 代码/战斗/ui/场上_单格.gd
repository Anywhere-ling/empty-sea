extends Panel
class_name 战斗_场上_单格

@onready var 中心: Control = %中心
@onready var 按钮: Button = %按钮
@onready var 光圈: Panel = %光圈
@onready var 动画: AnimationPlayer = %动画

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var pos_sys:战斗_单位管理系统.Pos_cs_sys
var x:int
var y:int

signal 按钮按下

func _ready() -> void:
	event_bus.subscribe("战斗_gui场上按钮被按下", func(a,b):按钮.visible = false)
	动画.play("可选择时的光圈浮动")

func set_card(p_pos:战斗_单位管理系统.Card_pos_sys) -> void:
	pos_sys = p_pos
	x = pos_sys.glo_x
	y = pos_sys.y


func get_pos_nam() -> String:
	return pos_sys.nam

func add_card(card:Card) -> void:
	if card.get_parent():
		card.get_parent().remove_child(card)
	
	中心.add_child(card)
	card.set_pos(self)
	reset_chlidren()


func remove_card(card:Card) -> void:
	中心.remove_child(card)
	reset_chlidren()



func reset_chlidren() -> void:
	var arr1:Array = 中心.get_children()
	if arr1.size() <= 1:
		return
	
	var arr2:Array = pos_sys.cards
	var arr3:Array = arr1.duplicate(true)
	
	arr3.sort_custom(func(a,b):return arr2.find(a.card_sys) < arr2.find(b.card_sys))
	arr3.reverse()
	if arr1 != arr3:
		for i in len(arr3):
			中心.move_child(arr3[i], i)


func get_posi() -> Vector2:
	return 中心.global_position


func set_button() -> void:
	按钮.visible = true

func dis_set_button() -> void:
	按钮.visible = false
	按钮.button_pressed = false

func set_button_pressed(a:bool) -> void:
	按钮.button_pressed = a


func chnage_光圈颜色(color:Color) -> void:
	光圈.modulate = color



func _on_按钮_button_up() -> void:
	emit_signal("按钮按下", self, pos_sys)
