extends Node2D


@onready var life图: TextureRect = %life图

var life_data:LifeData




func _init(life_name) -> void:
	if life_name:
		life_data = DatatableLoader.get_data_model("life_data", life_name)
		display()


func display() -> void:
	var path:String
	if life_data["种类"] == "nocard":
		path = 文件路径.png_nocard(life_data.卡名)
	elif life_data["种类"] == "character":
		path = 文件路径.png_character(life_data.卡名)
	
	if FileAccess.file_exists(path):
		life图.texture = load(path)
	else :
		life图.texture = load(文件路径.png_test())
