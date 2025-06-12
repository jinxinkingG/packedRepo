extends "res://script/clEnvBase.gd"

# 等待从武将列表中选人
# @param backFlow: 按 B 时返回到哪里
# @param endOnBack: 返回时是否 end_script
# @param disableStart: 禁用「开始」键，表示该场合下「开始」键另有用途
# @return true 表示选中，false 表示未选择
func wait_for_choose_list_actor(backFlow:String, endOnBack:bool=false, disableStart:bool=false)->bool:
	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.actorlist.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.actorlist.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.actorlist.page_up()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.actorlist.page_down()
	if Input.is_action_just_pressed("EMU_SELECT"):
		SceneManager.actorlist.sort_toggle();
	if Input.is_action_just_pressed("EMU_START"):
		if disableStart:
			return true
		SceneManager.actorlist.move_to(-1)

	if Global.is_action_pressed_BY():
		if not SceneManager.actorlist.is_msg_complete():
			return false
		FlowManager.add_flow(backFlow)
		if endOnBack:
			LoadControl.end_script()
		return false

	if not Global.is_action_pressed_AX():
		return false
	if not SceneManager.actorlist.is_msg_complete():
		SceneManager.actorlist.show_all_msg()
		return false
	return true

# 等待从战场地图武将中选人
# @param backFlow: 按 B 时返回到哪里
# @param endOnBack: 返回时是否 end_script
# @return true 表示选中，false 表示未选择
func wait_for_choose_actor(backFlow:String, endOnBack:bool=false, showActorInfo:bool=true)->bool:
	var targets = PoolIntArray(DataManager.common_variable["可选目标"])
	if targets.empty():
		return false
	var current = int(DataManager.common_variable["武将"])
	var index = targets.find(current)
	if index < 0:
		index = 0
		DataManager.common_variable["武将"] = targets[0]
	if Input.is_action_just_pressed("ANALOG_UP"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.UP)
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.DOWN)
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.LEFT)
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		index = ActorHelper.find_next_war_actor(targets, index, Vector2.RIGHT)
	current = targets[index]
	var wa = DataManager.get_war_actor(current)
	if wa == null or wa.disabled or not wa.has_position():
		return false
	DataManager.common_variable["武将"] = current
	var map = SceneManager.current_scene().war_map
	map.set_cursor_location(wa.position, true)
	if showActorInfo:
		SceneManager.show_actor_info(current, false)
		map.next_shrink_actors = [current]
	if Global.is_action_pressed_BY():
		if not SceneManager.actorlist.is_msg_complete():
			return false
		LoadControl.set_view_model(-1)
		FlowManager.add_flow(backFlow)
		if endOnBack:
			LoadControl.end_script()
		return false

	if not Global.is_action_pressed_AX():
		return false
	if not SceneManager.actorlist.is_msg_complete():
		SceneManager.actorlist.show_all_msg()
		return false
	LoadControl.set_view_model(-1)
	DataManager.common_variable["目标"] = targets[index]
	return true

# 等待是否确认，决定去哪个分支
func wait_for_yesno(flowForYes:String, flowForNo:String, endOnNo:bool=false)->void:
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.actor_dialog.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.actor_dialog.move_right()
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete(false):
			return
		FlowManager.add_flow(flowForNo)
		return
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	match SceneManager.actor_dialog.lsc.cursor_index:
		0:
			FlowManager.add_flow(flowForYes)
		1:
			if endOnNo:
				LoadControl.end_script()
			FlowManager.add_flow(flowForNo)
	return

# 简单等待信息确认
func wait_for_confirmation(nextFlow:String="player_ready", prevFlow:String="")->void:
	if prevFlow != "" and Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return
		LoadControl.set_view_model(-1)
		FlowManager.add_flow(prevFlow)
		return
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	LoadControl.set_view_model(-1)
	FlowManager.add_flow(nextFlow)
	return

# 浏览目标，但并不点击
func wait_for_view_item()->int:
	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.lsc_menu_top.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.lsc_menu_top.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.lsc_menu_top.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.lsc_menu_top.lsc.move_right()
	return SceneManager.lsc_menu_top.lsc.cursor_index

# 等待从目标中选择一个（比如物品）
# @return 如果已经做出了正确的处理或不需要处理，false，如果需要处理，true
func wait_for_choose_item(backFlow:String, endOnBack:bool=false)->int:
	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.lsc_menu_top.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.lsc_menu_top.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.lsc_menu_top.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.lsc_menu_top.lsc.move_right()
	if backFlow != "" and Global.is_action_pressed_BY():
		if not SceneManager.actor_dialog.is_msg_complete():
			return -1
		if backFlow != "":
			FlowManager.add_flow(backFlow)
			if endOnBack:
				LoadControl.end_script()
		return -1
	if not Global.is_action_pressed_AX():
		return -1
	if not SceneManager.actor_dialog.is_msg_complete():
		SceneManager.actor_dialog.show_all_msg()
		return -1
	var option = SceneManager.lsc_menu_top.lsc.cursor_index
	return option

# 等待从选项中选择一个
# @return 如果已经做出了正确的处理或不需要处理，false，如果需要处理，true
func wait_for_options(optionFlows:PoolStringArray, backFlow:String, endOnBack:bool=false)->bool:
	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.lsc_menu.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.lsc_menu.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.lsc_menu.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.lsc_menu.lsc.move_right()
	if backFlow != "" and Global.is_action_pressed_BY():
		if not SceneManager.lsc_menu.is_msg_complete():
			return false
		FlowManager.add_flow(backFlow)
		if endOnBack:
			LoadControl.end_script()
		return false
	if not Global.is_action_pressed_AX():
		return false
	if not SceneManager.lsc_menu.is_msg_complete():
		SceneManager.lsc_menu.show_all_msg()
		return false
	var option = SceneManager.lsc_menu.lsc.cursor_index
	if option >= 0 and option < optionFlows.size():
		FlowManager.add_flow(optionFlows[option])
		return false
	return true

# 等待输入数值
func wait_for_number_input(backFlow:String, allowZero:bool=false)->bool:
	var conNumberInput = SceneManager.input_numbers.get_current_input_node()
	if Input.is_action_just_pressed("ANALOG_UP"):
		conNumberInput.cursor_number_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		conNumberInput.cursor_number_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		conNumberInput.cursor_move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		conNumberInput.cursor_move_right()
	if Input.is_action_just_pressed("EMU_SELECT"):
		conNumberInput.set_number(conNumberInput.min_number)
	if Input.is_action_just_pressed("EMU_START"):
		conNumberInput.set_number(conNumberInput.max_number)
	if Global.is_action_pressed_BY():
		if not SceneManager.input_numbers.is_msg_complete():
			return false
		if SceneManager.input_numbers.pre_input_index():
			var input = SceneManager.input_numbers.get_current_input_node();
			input.set_number(0, true)
			return false
		FlowManager.add_flow(backFlow)
		return false
	if not Global.is_action_pressed_AX():
		return false
	if not SceneManager.input_numbers.is_msg_complete():
		SceneManager.input_numbers.show_all_msg()
		return false
	var number:int = conNumberInput.get_number()
	if not allowZero and number == 0:
		return false
	return true

func show_actor_targets(actorId:int, targets:PoolIntArray, msg:String="请选择目标")->bool:
	var scene_war = SceneManager.current_scene()
	var war_map = scene_war.war_map;

	if targets.empty():
		war_map.cursor.hide();
		LoadControl._error("当前没有可用的目标", actorId)
		return false
	war_map.cursor.show();
	DataManager.common_variable["可选目标"] = targets
	var wa = DataManager.get_war_actor(targets[0])
	war_map.set_cursor_location(wa.position, true)
	DataManager.common_variable["武将"] = targets[0]
	war_map.show_can_choose_actors(targets)
	SceneManager.show_actor_info(wa.actorId, true, msg)
	war_map.next_shrink_actors = [targets[0]]
	return true
