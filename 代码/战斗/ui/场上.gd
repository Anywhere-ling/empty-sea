extends Control
class_name 战斗_场上

@onready var 动画系统: Node = %动画系统

@onready var 确认: Button = %确认
@onready var 取消: Button = %取消
@onready var 描述: Label = %描述
@onready var 容器: GridContainer = %容器
@onready var 容器大小: PanelContainer = $容器大小
@onready var 按钮: Control = %按钮


var 返回data:Array
var max:int
var min:int
var nodes:Array



var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
var 场地行数:int = C0nfig.场地行数

var life_sys:战斗_单位管理系统.Life_sys

func _ready() -> void:
	event_bus.subscribe("战斗_右键点击", func():if !取消.disabled and 取消.visible:call_deferred("_on_取消_button_up"))


func ready(poss:Array) -> void:
	容器大小.size = Vector2(800, 160 * 场地行数)
	容器大小.position = Vector2(-400, -80 * 场地行数)
	for i in 场地行数 * 5:
		var node:战斗_场上_单格 = preload(文件路径.tscn_场上_单格).instantiate()
		容器.add_child(node)
		node.set_card(poss[i])
		node.按钮按下.connect(_选择一格返回)
		动画系统.add_对照表(node)


func get_ind(x:int, y:int) -> 战斗_场上_单格:
	if x<1 or x>5 or y<1 or y>5:
		assert(false)
	return 容器.get_child(((y-1)*5)+x-1) as 战斗_场上_单格


func add_card(card:Card, x:int, y:int) -> void:
	var node: = get_ind(x, y)
	node.add_card(card)


func remove_card(card:Card, x:int, y:int) -> void:
	var node: = get_ind(x, y)
	node.remove_card(card)


func get_posi(x:int, y:int) -> Vector2:
	var node: = get_ind(x, y)
	return node.get_posi()


func set_button(x:int, y:int) -> void:
	var node: = get_ind(x, y)





func _选择一格返回(btn:战斗_场上_单格, pos:战斗_单位管理系统.Card_pos_sys) -> void:
	if max == 1:
		返回data = [pos]
		_on_确认_button_up()
		return
	
	if 返回data.size() >= max:
		btn.set_button_pressed(false)
		返回data.erase(pos)
		return
	
	if btn.button_pressed:
		返回data.append(pos)
	else :
		返回data.erase(pos)
	
	if 返回data.size() >= min:
		确认.disabled = false
	else :
		确认.disabled = true


func set_cards(arr:Array, p_描述:String = "无", count_max:int = 1, count_min:int = 1) -> void:
	描述.text = p_描述
	max = count_max
	min = count_min
	
	
	
	if min <= 0:
		取消.visible = true
	else:
		取消.visible = false
	按钮.visible = true
	
	for i in arr:
		get_ind(i.glo_x, i.y).set_button()
		if p_描述 == "攻击!":
			get_ind(i.glo_x, i.y).chnage_光圈颜色(Color.ORANGE_RED)
		else:
			get_ind(i.glo_x, i.y).chnage_光圈颜色(Color.DEEP_SKY_BLUE)


func free_cards() -> Array:
	var ret:Array = 返回data.duplicate(true)
	for i in 容器.get_children():
		i.dis_set_button()
	确认.disabled = true
	取消.visible = false
	按钮.visible = false
	返回data = []
	return ret




signal 按下
func _on_确认_button_up() -> void:
	emit_signal("按下")


func _on_取消_button_up() -> void:
	if 取消.disabled or !取消.visible:
		return
	free_cards()
	emit_signal("按下")
