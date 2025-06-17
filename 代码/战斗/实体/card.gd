extends PanelContainer
class_name Card

@onready var 种类: TextureRect = %种类
@onready var 卡名: Label = %卡名
@onready var 卡图: TextureRect = %卡图


var card_data:CardData


func _init(card_name:String) -> void:
	card_data = DatatableLoader.get_data_model("card_data", card_name)
	
