extends "res://addons/GDDataForge/source/data_loader.gd"
#用于加载卡牌文件，给gdddataforge使用




## 加载数据表
func load_datatable(table_path: StringName) -> Dictionary:
	var file_func:String#.文件夹.txt中的方法
	var flie_文件夹:= FileAccess.open(table_path,FileAccess.READ)
	file_func = flie_文件夹.get_line()
	
	
	
	
	var file_data : Dictionary = {}
	
	#加载卡牌名总表
	var card_folder := DirAccess.open(文件路径.get(file_func))
	var ok := DirAccess.get_open_error()
	if ok != OK: 
		push_error("未能正确打开文件！")
	
	#加载每个卡牌文件
	card_folder.list_dir_begin()  # 开始遍历
	var file_name = card_folder.get_next().get_basename()
	
	while file_name != "":
		if not card_folder.current_is_dir():  # 忽略子文件夹
			file_data[file_name] = 文件路径.get(file_func) + file_name + ".json"
		file_name = card_folder.get_next().get_basename()
	
	card_folder.list_dir_end()
	
	
	#将每个文件单独转换为数组[卡名,...,[效果1,...]]
	for card_name:String in file_data:
		var json_text = FileAccess.get_file_as_string(file_data[card_name])
		var json = JSON.parse_string(json_text)
		file_data[card_name] = json
		
		
		#var card_file := FileAccess.open(file_data[card_name], FileAccess.READ)
		#var card_data:Array = card_file.get_csv_line()
		#while not card_file.eof_reached():
			#var effect:PackedStringArray = card_file.get_csv_line()
			## 跳过空行或无效行
			#if effect.size() == 0 or (effect.size() == 1 and effect[0] == ""):
				#continue
		#
			#card_data.append(effect)
		#file_data[card_name] = card_data
	#
	##对这个数组的处理
	#for card_name:String in file_data:
		#var card_data:Array = file_data[card_name]
		#var new_card_data:Dictionary = {
			#"卡名":card_data[0],
			#"种类":card_data[1],
			#"sp":card_data[2],
			#"mp":card_data[3],
			#"特征":card_data[4],
			#"媒介":card_data[5],
			#"组":card_data[6],
			#"文本":card_data[7],
			#"效果":[]
		#}
		#
		##分割效果
		#for effect:Array in card_data[8]:
			#var new_effect:Array
			#for index1:int in len(effect):
				##第一次分割
				#var i1:PackedStringArray = effect[index1].split("/" , false)
				##如果无法分割
				#if len(i1) == 1:
					#new_effect.append(i1[0])
					#continue
				#
				#var new_i1:Array
				#for index2:int in len(i1):
					##第二次分割
					#var i2:Array = i1[index2].split("_" , false)
					##如果无法分割
					#if len(i2) == 1:
						#new_i1.append(i2[0])
						#continue
					#
					#new_i1.append(i2)
				#new_effect.append(new_i1)
			#new_card_data["效果"].append(new_effect)
		#
		#file_data[card_name] = new_card_data
	#
	
	
	
	return file_data
