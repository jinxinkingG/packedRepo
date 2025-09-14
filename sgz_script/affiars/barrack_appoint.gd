extends "affairs_base.gd"

#任命
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤"
	FlowManager.bind_signal_method("appoint_menu", self)
	FlowManager.bind_signal_method("appoint_start", self)
	FlowManager.bind_signal_method("appoint_1", self)
	FlowManager.bind_signal_method("appoint_2", self)
	FlowManager.bind_signal_method("appoint_3", self)
	FlowManager.bind_signal_method("appoint_defence", self)
	FlowManager.bind_signal_method("appoint_defence_2", self)
	FlowManager.bind_signal_method("appoint_delegate", self)
	FlowManager.bind_signal_method("appoint_delegate_set", self)
	FlowManager.bind_signal_method("appoint_delegate_cancel", self)
	return

#按键操控
func _input_key(delta: float):
	var processor = "_on_view_model_{0}".format([LoadControl.get_view_model()])
	if self.has_method(processor):
		self.call(processor, delta)
	return

func _on_view_model_240(delta: float):
	# 选择任命选项（任命太守、防御出阵、委任开发）
	var optionFlows = ["appoint_start", "appoint_defence", "appoint_delegate"]
	wait_for_options(optionFlows, "enter_barrack_menu", true)
	return

func _on_view_model_241(delta: float):
	if not wait_for_choose_actor("enter_barrack_menu", true):
		return

	DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor()
	if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 10008, ""):
		return

	LoadControl.set_view_model(-1)
	FlowManager.add_flow("appoint_2")
	return

func _on_view_model_242(delta: float):
	wait_for_confirmation("appoint_3", "city_enter_menu")

#任命菜单
func appoint_menu():
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var menu_array = ["任命太守","防御出阵","委任开发"];
	DataManager.common_variable["列表值"]=menu_array;
	SceneManager.lsc_menu.lsc.columns = 1;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("作何任命？");
	SceneManager.lsc_menu.show_orderbook(true);
	DataManager.cityInfo_type = 1;
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(240)
	return

#任命太守：判断是否可以任命太守
func appoint_start():
	LoadControl.set_view_model(240);
	if(AutoLoad.playerNo != FlowManager.controlNo):
		return;
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_lord_id() in city.get_actor_ids():
		LoadControl._affiars_error("君主所在城\n太守由君主担任");
		return;
	FlowManager.add_flow("appoint_1");
	return

#显示武将列表
func appoint_1():
	LoadControl.set_view_model(241);
	var city = clCity.city(DataManager.player_choose_city)
	var props = ["体", "武", "政", "德", "忠", "兵力"]
	SceneManager.show_actorlist(city.get_actor_ids(), false, "任命何人为太守?", false, props)
	return

#对话确认：任命XXX
func appoint_2():
	LoadControl.set_view_model(242);
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var city = clCity.city(DataManager.player_choose_city)
	var msg = "任命{0}为{1}太守".format([
		actor.get_name(), city.get_name()
	])
	SceneManager.show_confirm_dialog(msg)
	return

func appoint_3():
	LoadControl.set_view_model(-1)
	var city = clCity.city(DataManager.player_choose_city)
	var actorId = int(DataManager.player_choose_actor)
	clCity.move_out(actorId)
	city.insert_actor(0, actorId)
	SkillHelper.update_all_skill_buff("SET_SATRAP")
	FlowManager.add_flow("city_enter_menu")
	return

#任命防御出阵武将
func appoint_defence():
	var city = clCity.city(DataManager.player_choose_city)
	var actorIds = city.get_actor_ids()
	if actorIds.size() < 3:
		var msg = "{0}只有{1}人守备\n无须设定防御出阵".format([
			city.get_full_name(), actorIds.size(),
		])
		LoadControl._affiars_error(msg)
		return
	var limit = min(10, actorIds.size())
	var msg = "设定防御出阵（{0}/{0}）".format([limit])
	SceneManager.actorlist.set_highlight(-1)
	SceneManager.show_actorlist_army(actorIds, true, msg, false)
	SceneManager.actorlist.clear_picked_actors()
	for i in limit:
		SceneManager.actorlist.set_actor_picked(actorIds[i])
	LoadControl.set_view_model(251)
	return

func _on_view_model_251(delta: float):
	if not wait_for_choose_actor("enter_barrack_menu", true):
		return

	var city = clCity.city(DataManager.player_choose_city)
	var actorIds = city.get_actor_ids()
	var limit = min(10, actorIds.size())
	var actorId = SceneManager.actorlist.get_select_actor()
	if actorId == actorIds[0]:
		# 太守默认出战，不允许取消
		if not SceneManager.actorlist.is_actor_picked(actorId):
			SceneManager.actorlist.set_actor_picked(actorId, limit)
		else:
			SceneManager.actorlist.rtlMessage.text = "太守必须作为主将出战"
		return
	# 选择了结束
	if actorId == -1:
		if SceneManager.actorlist.get_picked_actors().size() < limit:
			SceneManager.actorlist.rtlMessage.text = "须选择{0}人防御出阵".format([limit])
			return
		SceneManager.actorlist.set_highlight(-1)
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("appoint_defence_2")
		return
	if actorIds.size() <= 10:
		# 十人及以下，换人模式
		var lastActorId = SceneManager.actorlist.get_highlighted()
		if lastActorId < 0:
			SceneManager.actorlist.set_highlight(actorId)
		elif lastActorId == actorId:
			# 再次选择同一武将，取消高亮
			SceneManager.actorlist.set_highlight(-1)
		else:
			# 选择了另一个武将，换位
			SceneManager.actorlist.set_highlight(-1)
			var idxA = actorIds.find(lastActorId)
			var idxB = actorIds.find(actorId)
			if idxA >= 0 and idxB >= 0:
				actorIds[idxA] = actorId
				actorIds[idxB] = lastActorId
				city.set_actors(actorIds)
		SceneManager.actorlist.clear_picked_actors()
		var picked = actorIds.slice(0, limit - 1)
		var msg = "设定防御出阵（{0}/{0}）".format([limit])
		SceneManager.actorlist.update_actor_list(actorIds, picked, msg)
	else:
		# 十人以上，传统模式
		if actorId >= 0:
			# 选择了某个武将
			SceneManager.actorlist.set_actor_picked(actorId, limit)
			SceneManager.actorlist.rtlMessage.text = "选择十人防御出阵（{0}/{1}）".format([
				SceneManager.actorlist.get_picked_actors().size(), limit,
			])
			return
		# 选择了结束
		if SceneManager.actorlist.get_picked_actors().size() < limit:
			SceneManager.actorlist.rtlMessage.text = "选择十人防御出阵（{0}/{1}）".format([
				SceneManager.actorlist.get_picked_actors().size(), limit,
			])
		return
	return

#将选中的10人移到前列
func appoint_defence_2():
	var city = clCity.city(DataManager.player_choose_city)
	var picked = SceneManager.actorlist.get_picked_actors()
	var i:int = 0
	var currentLeader = city.get_actor_ids()[0]
	if currentLeader in picked:
		picked.erase(currentLeader)
		i = 1
	for actorId in picked:
		clCity.move_out(actorId)
		city.insert_actor(i, actorId)
		i += 1
	SceneManager.actorlist.set_highlight(-1)
	FlowManager.add_flow("city_enter_menu")
	return

#委任开发
func appoint_delegate():
	if DataManager.is_challange_game():
		var msg = "挑战赛模式\n禁用委任"
		LoadControl._affiars_error(msg, -5)
		return
	var city = clCity.city(DataManager.player_choose_city)
	var leaderId = city.get_leader_id()
	if city.is_delegated():
		var msg = "{0}已委任于在下\n主公是否要亲自治理？".format([
			city.get_full_name()
		])
		SceneManager.show_yn_dialog(msg, leaderId, 2)
		LoadControl.set_view_model(262)
		return
	if leaderId == city.get_lord_id():
		var msg = "君主所在城池\n不可委任"
		LoadControl._affiars_error(msg)
		return
	if DataManager.get_city_num_by_vstate(city.get_vstate_id(), true) == 1:
		var msg = "不可委任全部城池"
		LoadControl._affiars_error(msg)
		return
	var msg = "将{0}委任于{1}\n此城将不再累加命令书\n可否？".format([
		city.get_full_name(), ActorHelper.actor(leaderId).get_name(),
	])
	SceneManager.show_yn_dialog(msg, -1, 2)
	LoadControl.set_view_model(261)
	return

func _on_view_model_261(delta:float)->void:
	wait_for_yesno("appoint_delegate_set", "appoint_menu")
	return

func _on_view_model_262(delta:float)->void:
	wait_for_yesno("appoint_delegate_cancel", "appoint_menu")
	return

func appoint_delegate_set()->void:
	var city = clCity.city(DataManager.player_choose_city)
	city.set_delegated(true)
	var leaderId = city.get_leader_id()
	var msg = "定不负所托！"
	SceneManager.show_confirm_dialog(msg, leaderId, 1)
	LoadControl.set_view_model(263)
	return

func appoint_delegate_cancel()->void:
	var city = clCity.city(DataManager.player_choose_city)
	city.set_delegated(false)
	var leaderId = city.get_leader_id()
	var msg = "{0}已取消委任".format([
		city.get_full_name(),
	])
	SceneManager.show_confirm_dialog(msg, -1, 2)
	LoadControl.set_view_model(263)
	return

func _on_view_model_263(delta:float)->void:
	wait_for_confirmation("city_enter_menu")
	return
