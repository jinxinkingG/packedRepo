extends "res://script/effects_base.gd"

# 获取当前武将所在城市
func get_working_city_id()->int:
	return DataManager.get_office_city_by_actor(actorId)

#回到主动技菜单
func back_to_skill_menu():
	LoadControl.end_script()
	LoadControl.load_script("res://resource/sgz_script/affiars/barrack_skills.gd")
	FlowManager.add_flow("skill_list")
	return

# 从列表中选择目标
func wait_for_choose_item(nextFlow:String, backFlow:String=""):
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return
		if backFlow != "":
			FlowManager.add_flow(backFlow)
			return
		back_to_skill_menu()
		return

	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.lsc_menu_top.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.lsc_menu_top.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.lsc_menu_top.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.lsc_menu_top.lsc.move_right()

	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	var list = DataManager.get_env_array("列表值")
	var item = list[SceneManager.lsc_menu_top.lsc.cursor_index]
	DataManager.set_env("目标项", item)
	FlowManager.add_flow(nextFlow)
	return

# 从底部菜单中选择目标
func wait_for_choose_menu_item(nextFlow:String, backFlow:String=""):
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return
		if backFlow != "":
			LoadControl.set_view_model(-1)
			FlowManager.add_flow(backFlow)
		return

	if Input.is_action_just_pressed("ANALOG_UP"):
		SceneManager.lsc_menu.lsc.move_up()
	if Input.is_action_just_pressed("ANALOG_DOWN"):
		SceneManager.lsc_menu.lsc.move_down()
	if Input.is_action_just_pressed("ANALOG_LEFT"):
		SceneManager.lsc_menu.lsc.move_left()
	if Input.is_action_just_pressed("ANALOG_RIGHT"):
		SceneManager.lsc_menu.lsc.move_right()

	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	var list = get_env_array("列表值")
	var item = list[SceneManager.lsc_menu.lsc.cursor_index]
	set_env("目标项", item)
	LoadControl.set_view_model(-1)
	FlowManager.add_flow(nextFlow)
	return

# 等待是否确认，决定去哪个分支
func wait_for_yesno(flowForYes:String, flowForNo:String="enter_barrack_menu", endOnNo:bool=true)->void:
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

# 等待从武将列表中选人
# @param backFlow: 按 B 时返回到哪里
# @param endOnBack: 返回时是否 end_script
# @param disableStart: 禁用「开始」键，表示该场合下「开始」键另有用途
# @return true 表示选中，false 表示未选择
func wait_for_choose_actor(backFlow:String="", endOnBack:bool=false, disableStart:bool=false)->bool:
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
		if backFlow == "":
			back_to_skill_menu()
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

# 信息发动后的结果确认
func wait_for_skill_result_confirmation(nextFlow:String="player_ready"):
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	DataManager.twinkle_citys.clear()
	LoadControl.set_view_model(-1)
	if nextFlow == "":
		LoadControl.end_script()
	else:
		FlowManager.add_flow(nextFlow)
	return

# 大地图选择城市
func wait_for_choose_city(delta:float, backFlow:String, quickChoices:PoolIntArray=[])->int:
	var vstateId = int(DataManager.vstates_sort[DataManager.vstate_no]);
	if Input.is_action_pressed("ANALOG_UP"):
		SceneManager.current_scene().cursor_move_up(delta)
	if Input.is_action_pressed("ANALOG_DOWN"):
		SceneManager.current_scene().cursor_move_down(delta)
	if Input.is_action_pressed("ANALOG_LEFT"):
		SceneManager.current_scene().cursor_move_left(delta)
	if Input.is_action_pressed("ANALOG_RIGHT"):
		SceneManager.current_scene().cursor_move_right(delta)
	if Input.is_action_just_pressed("EMU_START"):
		if not quickChoices.empty():
			var cityId = SceneManager.current_scene().get_curosr_point_city();
			if cityId >= 0:
				var current = quickChoices.find(cityId)
				current = (current + 1) % quickChoices.size()
				SceneManager.current_scene().set_city_cursor_position(quickChoices[current])
			else:
				SceneManager.current_scene().set_city_cursor_position(quickChoices[0])
			SceneManager.dialog_msg_complete(true)
	if backFlow != "" and Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete():
			return -1
		FlowManager.add_flow(backFlow)
		return -1
	if not Global.is_action_pressed_AX():
		return -1
	if not SceneManager.dialog_msg_complete(true):
		return -1
	var cityId = SceneManager.current_scene().get_curosr_point_city()
	if cityId < 0:
		SceneManager.show_unconfirm_dialog("此处并没有城")
		return -1
	return cityId

# 更新开发倍率，皆为乘法
func change_develop_rate(costRate:float, effectRate:float)->void:
	var cmd = DataManager.get_current_develop_command()
	cmd.costRate *= costRate
	cmd.effectRate *= effectRate
	return

func bind_bottom_menu(items:PoolStringArray, vals:Array, msg:String, columns:int=1):
	set_env("列表值", vals)
	SceneManager.lsc_menu.lsc.columns = columns
	SceneManager.lsc_menu.lsc.items = items
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg(msg)
	SceneManager.lsc_menu.show_orderbook(true)
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(true)
	SceneManager.lsc_menu.lsc.cursor_index = 0
	SceneManager.lsc_menu.show()
	return

# 剧情对话
func play_dialog(actorId:int, msg:String, mood:int, nextViewModel:int, yn:bool=false, options:PoolStringArray=["是", "否"]):
	if yn:
		SceneManager.show_yn_dialog(msg, actorId, mood, options)
	else:
		SceneManager.show_confirm_dialog(msg, actorId, mood)
	LoadControl.set_view_model(nextViewModel)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
