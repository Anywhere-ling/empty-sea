extends Node



var state_machine_manager : CoreSystem.StateMachineManager = CoreSystem.state_machine_manager
var game_state_machine = 战斗_回合系统_StateMachine.new()
var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var turn_lifes:Array[战斗_单位管理系统.Life_sys]
var current_life:战斗_单位管理系统.Life_sys
var 没有第一次抽牌的单位:Array[战斗_单位管理系统.Life_sys]


func _ready() -> void:
	game_state_machine.state_changed.connect(_阶段改变的信号)


func join_life(life:战斗_单位管理系统.Life_sys) -> void:
	turn_lifes.append(life)
	turn_lifes.sort_custom(func(a,b):return a.speed >= b.speed)
	没有第一次抽牌的单位.append(life)



##开始回合处理
func start() -> void:
	# 创建并注册主状态机
	state_machine_manager.register_state_machine(&"Batter", game_state_machine, self, &"初始")


func _回合结束的信号() -> void:
	#切换回合单位
	var index:int = turn_lifes.find(current_life)
	if index < len(turn_lifes) - 1:
		current_life = turn_lifes[index + 1]
	else :
		current_life = turn_lifes[0]



##进入下一个阶段
func swicth_state(state:String = "") -> void:
	if state:
		game_state_machine.switch(state)
	else :
		game_state_machine.swicth_next()



func _阶段改变的信号(from_state: BaseState, to_state: BaseState) -> void:
	match to_state.state_id:
		&"初始":_回合进入初始阶段()
		&"开始":_回合进入开始阶段()
		&"战斗":_回合进入战斗阶段()
		&"抽牌":_回合进入抽牌阶段()
		&"行动":_回合进入行动阶段()
		&"主要":_回合进入主要阶段()
		&"结束":_回合进入结束阶段()


func _回合进入初始阶段() -> void:
	current_life = turn_lifes[0]

	
func _回合进入开始阶段() -> void:
	event_bus.push_event("战斗_回合进入开始阶段", [current_life])
	
func _回合进入战斗阶段() -> void:
	event_bus.push_event("战斗_回合进入战斗阶段", [current_life])
	
func _回合进入抽牌阶段() -> void:
	event_bus.push_event("战斗_回合进入抽牌阶段", [current_life])
	
func _回合进入行动阶段() -> void:
	event_bus.push_event("战斗_回合进入行动阶段", [current_life])
	
func _回合进入主要阶段() -> void:
	event_bus.push_event("战斗_回合进入主要阶段", [current_life])
	
func _回合进入结束阶段() -> void:
	event_bus.push_event("战斗_回合进入结束阶段", [current_life])
	
