extends PanelContainer
class_name 战斗_卡牌复制

@onready var 边距: MarginContainer = %边距
@onready var 左: Button = %左
@onready var 图片: TextureRect = %图片
@onready var 文本1: Label = %文本1
@onready var 文本2: Label = %文本2


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var card:Card
var pos:String

var 伴生:战斗_卡牌复制



func set_边距(x:int, y:int) -> void:
	边距.add_theme_constant_override("margin_bottom", y)
	边距.add_theme_constant_override("margin_top", y)
	边距.add_theme_constant_override("margin_left", x)
	边距.add_theme_constant_override("margin_right", x)


func set_card(p_card:Card) -> void:
	if card:
		card.图片或文字改变.disconnect(_重新渲染)
		card.卡牌被释放.disconnect(free_card)
	card = p_card
	card.图片或文字改变.connect(_重新渲染)
	图片.texture = card.图片.texture
	card.卡牌被释放.connect(free_card)
	visible = true


func _重新渲染(_a) -> void:
	图片.texture = card.图片.texture

func set_文本(a:String, b:String) -> void:
	文本1.text = a
	文本2.text = b




func select() -> bool:
	if 伴生:
		伴生.select()
	左.button_pressed = !左.button_pressed
	左.grab_focus()
	return 左.button_pressed

func dis_select() -> void:
	if 伴生:
		伴生.dis_select()
	左.button_pressed = false


func free_card() -> void:
	if card:
		card.卡牌被释放.disconnect(free_card)
		card.图片或文字改变.disconnect(_重新渲染)
	if 伴生:
		伴生.free_card()
	文本1.text = ""
	文本2.text = ""
	card = null
	pos = ""
	左.button_pressed = false
	visible = false
	



func _on_button_button_up() -> void:
	event_bus.push_event("战斗_卡牌被左键点击", card)
