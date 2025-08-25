extends Control
class_name 战斗_可选卡牌容器


@onready var 按钮: HBoxContainer = %按钮
@onready var 描述: Label = %描述
@onready var 单位: PanelContainer = %单位
@onready var 数量: Label = %数量
@onready var 确认: Button = %确认
@onready var 取消: Button = %取消
@onready var control_3: Control = %Control3
@onready var 展开: Button = %展开

@export var 边距:Vector2

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var cards:Dictionary
#[Card, 战斗_卡牌复制]
var lifes:Dictionary
var 可用lifes:Array
var max:int
var min:int
var 显示:战斗_可选卡牌容器_子节点
var is_展开:bool = false
var cont_life:战斗_单位管理系统.Life_sys

var select_cards:Array[Card]

func _ready() -> void:
	event_bus.subscribe("战斗_右键点击", func():if 展开.button_pressed:展开.button_pressed = false)
	event_bus.subscribe("战斗_右键点击", func():if !取消.disabled and 取消.visible: call_deferred("_on_取消_button_up"))
	event_bus.subscribe("战斗_显示单位切换", func(a,b):change_life(a.life_sys))

func add_life(life:战斗_单位管理系统.Life_sys) -> void:
	var scr = preload(文件路径.tscn_战斗_可选卡牌容器_子节点).instantiate()
	lifes[life] = scr
	单位.add_child(scr)
	scr.边距 = 边距
	scr.visible = false
	if life.种类 == "c0ntrol":
		cont_life = life

func change_life(life:战斗_单位管理系统.Life_sys) -> void:
	if !lifes.has(life):
		return
	if 显示:
		显示.visible = false
	显示 = lifes[life]
	显示.visible = true
	
	显示.change_mode(is_展开)


func set_cards(arr:Array, p_描述:String = "无", count_max:int = 1, count_min:int = 1) -> void:
	描述.text = p_描述
	max = count_max
	min = count_min
	
	if min <= 0:
		取消.visible = true
		control_3.visible = true
	else:
		取消.visible = false
		control_3.visible = false
	
	for card in arr:
		add_card(card)
	
	if 可用lifes.has(lifes[cont_life]):
		change_life(cont_life)
	
	set_数量_text()



func add_card(card:Card) -> void:
	var life_sys:战斗_单位管理系统.Life_sys = card.card_sys.get_parent().get_parent()
	var scr:战斗_可选卡牌容器_子节点 = lifes[life_sys]
	
	cards[card] = scr.add_card(card)
	
	if !可用lifes.has(scr):
		可用lifes.append(scr)

func select(card:Card) -> void:
	if !cards.has(card):
		return
	if max == 1:
		if cards[card].select():
			if len(select_cards) > 0:
				cards[select_cards[0]].dis_select()
				select_cards = []
			select_cards.append(card)
		else:
			_on_确认_button_up()
	else :
		if cards[card].select():
			if len(select_cards) >= max:
				return
			if !select_cards.has(card):
				select_cards.append(card)
		else:
			select_cards.erase(card)
	
	set_数量_text()

func set_数量_text() -> void:
	数量.text = str(len(select_cards)) + "(" + str(min) + "~" + str(max) + ")"
	
	确认.disabled = len(select_cards) < min


func free_cards() -> Array:
	for i in cards:
		cards[i].free_card()
	cards = {}
	可用lifes = []
	显示 = null
	展开.button_pressed = false
	取消.visible = false
	is_展开 = false
	visible = false
	var ret = select_cards.duplicate(true)
	select_cards = []
	
	return ret



func _on_展开_toggled(toggled_on: bool) -> void:
	is_展开 = toggled_on
	if toggled_on:
		size.y = 850
		position.y -= 600
	else:
		size.y = 250
		position.y += 600
	
	if 显示:
		显示.change_mode(is_展开)



signal 按下
func _on_确认_button_up() -> void:
	if 确认.disabled or !确认.visible:
		return
	emit_signal("按下")

func _on_取消_button_up() -> void:
	if 取消.disabled or !取消.visible:
		return
	free_cards()
	emit_signal("按下")
