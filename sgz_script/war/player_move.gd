extends "war_base.gd"

#武将移动
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤";
	
	FlowManager.bind_import_flow("actor_move_start",self,"actor_move_start");
	FlowManager.bind_import_flow("actor_move_ban",self,"actor_move_ban");
	FlowManager.bind_import_flow("actor_move_stop",self,"actor_move_stop");
	FlowManager.bind_import_flow("actor_move_stopped",self,"actor_move_stopped");
	FlowManager.bind_import_flow("actor_in_vallage",self,"actor_in_vallage");
	FlowManager.bind_import_flow("actor_in_rice",self,"actor_in_rice");
	FlowManager.bind_import_flow("actor_in_rice_buy_1",self,"actor_in_rice_buy_1");
	FlowManager.bind_import_flow("actor_in_rice_buy_2",self,"actor_in_rice_buy_2");
	FlowManager.bind_import_flow("actor_in_rice_buy_3",self,"actor_in_rice_buy_3");
	FlowManager.bind_import_flow("actor_in_rice_sell_1",self,"actor_in_rice_sell_1");
	FlowManager.bind_import_flow("actor_in_rice_sell_2",self,"actor_in_rice_sell_2");
	FlowManager.bind_import_flow("actor_in_rice_sell_3",self,"actor_in_rice_sell_3");
	FlowManager.bind_import_flow("actor_in_equip",self,"actor_in_equip");
	FlowManager.bind_import_flow("actor_in_weapon_menu",self,"actor_in_weapon_menu");
	FlowManager.bind_import_flow("actor_in_equip_menu",self,"actor_in_equip_menu");
	FlowManager.bind_import_flow("actor_in_equip_2",self,"actor_in_equip_2");
	FlowManager.bind_import_flow("actor_in_equip_3",self,"actor_in_equip_3");
	FlowManager.bind_import_flow("actor_in_equip_4",self,"actor_in_equip_4");
	FlowManager.bind_import_flow("actor_in_hospital",self,"actor_in_hospital");
	FlowManager.bind_import_flow("actor_in_hospital_2",self,"actor_in_hospital_2");
	FlowManager.bind_import_flow("actor_in_hospital_3",self,"actor_in_hospital_3");

	return

#按键操控
func _input_key(delta: float):
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var scene_war:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model()
	match view_model:
		101:#移动
			var actorId = DataManager.player_choose_actor
			var wa = DataManager.get_war_actor(actorId)
			if Input.is_action_just_pressed("ANALOG_UP"):
				_push_move(Vector2.UP)
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				_push_move(Vector2.DOWN)
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				_push_move(Vector2.LEFT)
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				_push_move(Vector2.RIGHT)
			if Global.is_action_pressed_BY():
				_pop_move()
				return
			if Global.is_action_pressed_AX():
				FlowManager.add_flow("actor_move_stop")
		102:
			if Global.is_action_pressed_AX():
				#按A时，移动停止
				LoadControl.set_view_model(-1)
				DataManager.set_env("历史移动记录", [])
				FlowManager.add_flow("player_ready")
		103:#进入村庄
			if Global.is_action_pressed_BY():
				if not SceneManager.dialog_msg_complete(false):
					return
				LoadControl.set_view_model(-1)
				FlowManager.add_flow("player_ready")
				return
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			match DataManager.get_env_str("村庄类型"):
				"米屋":
					FlowManager.add_flow("actor_in_rice")
				"装备店":
					FlowManager.add_flow("actor_in_equip")
				"医馆":
					FlowManager.add_flow("actor_in_hospital")
		104:#米屋
			var options = ["actor_in_rice_buy_1", "actor_in_rice_sell_1"]
			wait_for_options(options, "player_ready")
		105:#输入买米量
			var ret = wait_for_number_input("player_ready")
			var conNumberInput = SceneManager.input_numbers.get_current_input_node()
			var number:int = conNumberInput.get_number()
			var money = int(number*100/city.get_rice_buy_price())
			SceneManager.input_numbers.speak2("（金 {0}）".format([money]))
			if not ret or number == 0:
				return
			#确认数量
			LoadControl.set_view_model(-1)
			DataManager.set_env("数量", number)
			FlowManager.add_flow("actor_in_rice_buy_2")
		106:#确认买米数量
			wait_for_yesno("actor_in_rice_buy_3", "player_ready")
		108:#输入卖米量
			var ret = wait_for_number_input("player_ready")
			var conNumberInput = SceneManager.input_numbers.get_current_input_node()
			var number:int = conNumberInput.get_number()
			var money = int(number*city.get_rice_sell_price()/100)
			SceneManager.input_numbers.speak2("（金 {0}）".format([money]))
			if not ret or number == 0:
				return
			#确认数量
			LoadControl.set_view_model(-1)
			DataManager.set_env("数量", number)
			FlowManager.add_flow("actor_in_rice_sell_2")
		109:#确认卖米数量
			wait_for_yesno("actor_in_rice_sell_3", "player_ready")
		114:#装备店确认
			wait_for_confirmation("actor_in_equip_menu", "player_ready")
		115:#装备店菜单
			if Global.is_action_pressed_BY():
				if not bottom.is_msg_complete():
					return
				LoadControl.set_view_model(-1)
				FlowManager.add_flow("player_ready")
				return
			if Input.is_action_just_pressed("ANALOG_UP"):
				bottom.lsc.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				bottom.lsc.move_down()
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				bottom.lsc.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				bottom.lsc.move_right()
			if not Global.is_action_pressed_AX():
				return
			if not bottom.is_msg_complete():
				bottom.show_all_msg()
				return
			LoadControl.set_view_model(-1)
			var values = DataManager.get_env_array("列表值")
			var type = values[bottom.lsc.cursor_index]
			DataManager.set_env("大类型", type)
			DataManager.set_env("子类型", type)
			if type == "武器":
				FlowManager.add_flow("actor_in_weapon_menu")
				return
			FlowManager.add_flow("actor_in_equip_2")
		119:#武器店确认
			if Global.is_action_pressed_BY():
				if not bottom.is_msg_complete():
					return
				LoadControl.set_view_model(-1)
				FlowManager.add_flow("actor_in_equip_menu")
				return
			if Input.is_action_just_pressed("ANALOG_UP"):
				bottom.lsc.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				bottom.lsc.move_down()
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				bottom.lsc.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				bottom.lsc.move_right()
			if not Global.is_action_pressed_AX():
				return
			if not bottom.is_msg_complete():
				bottom.show_all_msg()
				return
			LoadControl.set_view_model(-1)
			var values = DataManager.get_env_array("列表值")
			var type = values[bottom.lsc.cursor_index]
			DataManager.set_env("子类型", type)
			if type == "武器":
				FlowManager.add_flow("actor_in_weapon_menu")
				return
			FlowManager.add_flow("actor_in_equip_2")
		116:#选择具体装备
			var menu = SceneManager.lsc_menu
			var all = DataManager.get_env_array("售卖装备")
			var curPage = DataManager.get_env_int("装备翻页")
			var maxPage = int((all.size() - 1) / 4)
			if maxPage > 0:
				if menu.lsc.cursor_index < 2 and Input.is_action_just_pressed("ANALOG_UP"):
					Input.action_release("ANALOG_UP")
					DataManager.set_env("装备翻页", curPage - 1)
				elif (menu.lsc.items.size() <= 2 or menu.lsc.cursor_index > 1) and Input.is_action_just_pressed("ANALOG_DOWN"):
					Input.action_release("ANALOG_DOWN")
					DataManager.set_env("装备翻页", curPage + 1)
			var page = DataManager.get_env_int("装备翻页")
			if page < 0:
				page = maxPage
			if page > maxPage:
				page = 0
			DataManager.set_env("装备翻页", page)
			if page != curPage:
				var items = []
				var values = []
				for i in range(page * 4, min(all.size(), page * 4 + 4)):
					var dic = all[i]
					items.append("{name}  \t{price}{color}{flag}".format(dic))
					values.append(dic["id"])
				DataManager.set_env("列表值", values)
				menu.lsc.items = items
				menu.lsc._set_data(32)
				var msg = "买哪个？（第{0}/{1}页）".format([
					page + 1, maxPage + 1,
				])
				menu.rtlMessage.text = msg
			var values = DataManager.get_env_int_array("列表值")
			wait_for_options([], "actor_in_equip_menu")
			var equipId = values[menu.lsc.cursor_index]
			var equipType = DataManager.get_env_str("大类型")
			var equip = clEquip.equip(equipId, equipType)
			var lastEquipId = DataManager.get_env_int("检视装备")
			if lastEquipId != equipId:
				var conEquipInfo:Control = SceneManager.conEquipInfo
				conEquipInfo.show_equipinfo(equip, "shop")
				conEquipInfo.show()
				DataManager.set_env("检视装备", equipId)
			if not Global.is_action_pressed_AX():
				return
			if not menu.is_msg_complete():
				menu.show_all_msg()
				return
			LoadControl.set_view_model(-1)
			var actorId = DataManager.player_choose_actor
			var remaining = equip.remaining()
			if remaining == 0:
				LoadControl._error("此装备已被卖完")
				return
			if not equip.actor_can_use(actorId):
				LoadControl._error("无论如何\n亦无法掌握这等宝物", actorId, 3)
				return
			var wa = DataManager.get_war_actor(actorId)
			if equip.price() > wa.war_vstate().money:
				LoadControl._error("军资不足以支付装备购买", actorId, 3)
				return
			DataManager.set_env("购买装备", equip.id)
			FlowManager.add_flow("actor_in_equip_3")
		117:#确认装备将花费多少
			wait_for_yesno("actor_in_equip_4", "actor_in_equip_menu")
		1171:#输入数量
			if wait_for_number_input("actor_in_equip_2"):
				LoadControl.set_view_model(-1)
				var cnt = SceneManager.input_numbers.get_current_input_node().get_number()
				DataManager.set_env("装备数量", cnt)
				FlowManager.add_flow("actor_in_equip_4")
				return
		124:#确认进入医馆
			wait_for_confirmation("actor_in_hospital_2", "player_ready")
		125:#确认治疗花费
			wait_for_confirmation("actor_in_hospital_3", "player_ready")
		199:#确认各种结果
			wait_for_confirmation("player_ready")
	return

#武将移动
func actor_move_start():
	var actorId = DataManager.player_choose_actor
	var map = SceneManager.current_scene().war_map
	var wa = DataManager.get_war_actor(actorId)
	if wa == null or not wa.can_move():
		FlowManager.add_flow("actor_move_ban")
		return;
	map.aStar.update_map_for_actor(wa)
	DataManager.set_env("历史移动记录", [])
	map.cursor.hide()
	map.next_shrink_actors = [actorId]
	#对白
	var msg = get_movement_message(wa)
	DataManager.set_env("对白", msg)
	DataManager.set_env("移动", 0)
	DataManager.unset_env("结束移动")
	#插入移动技能判定
	SkillHelper.auto_trigger_skill(actorId, 20003, "")
	msg = DataManager.get_env_str("对白")
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.dialog_msg_complete(true)
	LoadControl.set_view_model(101)
	return

#移动过程
func _push_move(dir:Vector2):
	#DataManager.game_trace("")
	var map = SceneManager.current_scene().war_map
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
	var prev:Vector2 = wa.position
	var target = prev + dir
	var moveHistory = DataManager.get_env_array("历史移动记录")
	if moveHistory.size() >= 100:
		#单次移动不可超过100步
		SceneManager.show_unconfirm_dialog("不可连续移动100步\n恳请休息……", wa.actorId, 3)
		return

	if not map.is_valid_position(target):
		return
	#原地踏步时返回
	if target == prev:
		return
	var cost = DataManager.get_move_cost(wa.actorId, target)
	if wa.action_point < cost["机"] or wa.poker_point < cost["点"]:
		return
	if not wa.move(target, true):
		return
	# 特殊判断，如果是仙兵种穿墙，有概率失败
	if wa.may_move_failed(prev, target):
		# 回弹
		wa.position = prev
		# 仍然扣点
		wa.poker_point = max(0, wa.poker_point - cost["点"])
		var msg = "？！\n（穿墙失败\n（剩余点数：{0}".format([wa.poker_point])
		wa.attach_free_dialog(msg, 2)
		FlowManager.add_flow("actor_move_stop")
		return
	#wa.position = prev
	moveHistory.append({
		"x": prev.x,
		"y": prev.y,
		"AP": wa.action_point,
		"P": wa.poker_point,
	})
	wa.action_point = max(0, wa.action_point - cost["机"])
	wa.poker_point = max(0, wa.poker_point - cost["点"])
	DataManager.set_env("历史移动记录", moveHistory)
	# 立刻更新机动力显示
	map.update_ap()
	#对白
	var msg = get_movement_message(wa)
	DataManager.set_env("对白", msg)
	DataManager.set_env("移动", 1)
	DataManager.set_env("移动消耗", cost)
	DataManager.set_env("移动中止", 0)
	#插入移动技能判定
	SkillHelper.auto_trigger_skill(wa.actorId, 20003, "")
	if DataManager.get_env_int("移动中止") > 0:
		LoadControl.set_view_model(-1)
		FlowManager.add_flow("actor_move_stop")
		return
	msg = DataManager.get_env_str("对白")
	wa.after_move()
	SceneManager.show_unconfirm_dialog(msg, wa.actorId)
	SceneManager.dialog_msg_complete(true)
	#DataManager.game_trace("MOVE")
	return

#移动撤销
func _pop_move():
	var war_map = SceneManager.current_scene().war_map
	var moveHistory = DataManager.get_env_array("历史移动记录")
	if moveHistory.empty():
		return
	var posInfo:Dictionary = moveHistory.pop_back()
	DataManager.set_env("历史移动记录", moveHistory)
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
	var pos = Vector2(
		int(Global.dic_val(posInfo, "x")),
		int(Global.dic_val(posInfo, "y"))
	)
	var ap = int(Global.dic_val(posInfo, "AP"))
	var pp = int(Global.dic_val(posInfo, "P"))
	wa.move(pos, true, true)
	var cost = {}
	cost["机"] = wa.action_point - ap
	cost["点"] = wa.poker_point - pp
	wa.action_point = ap
	wa.poker_point = pp
	war_map.update_ap()
	#对白
	var msg = get_movement_message(wa)
	DataManager.set_env("对白", msg)
	DataManager.set_env("移动消耗", cost)
	DataManager.set_env("移动", -1)
	#插入移动技能判定
	SkillHelper.auto_trigger_skill(wa.actorId, 20003, "")
	msg = DataManager.get_env_str("对白")
	wa.after_move(false)

	SceneManager.show_unconfirm_dialog(msg, wa.actorId)
	SceneManager.dialog_msg_complete(true)
	return

#无法移动
func actor_move_ban():
	SceneManager.show_unconfirm_dialog("当前已被禁止移动", DataManager.player_choose_actor, 3)
	LoadControl.set_view_model(102)
	return

# 停止移动
func actor_move_stop():
	DataManager.set_env("移动", 0)
	DataManager.set_env("结束移动", 1)
	if SkillHelper.auto_trigger_skill(DataManager.player_choose_actor, 20003, "actor_move_stopped"):
		DataManager.unset_env("结束移动")
		return
	DataManager.unset_env("结束移动")
	FlowManager.add_flow("actor_move_stopped")
	return

func actor_move_stopped():
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
	if wa == null:
		FlowManager.add_flow("player_ready")
		return
	DataManager.set_env("历史移动记录", [])
	#按A时，移动停止
	var dic_areas = wa.check_has_areas_by_labels(["伏兵"])
	if not dic_areas.empty():
		var fromActor = ActorHelper.actor(dic_areas["from_actorId"])
		var damage = int(Global.get_random(30,40)*fromActor.get_wisdom()/10)
		damage = min(damage, wa.actor().get_soldiers())
		# 暂时植入【破伏】的实现
		var msg = "{0}在此设下陷阱\n兵力下降{1}".format([fromActor.get_name(), damage])
		var mood = 3
		if SkillHelper.actor_has_skills(wa.actorId, ["破伏"]):
			damage = 0
			mood = 1
			msg = "{0}在此设下陷阱\n【破伏】免伤".format([fromActor.get_name()])
		if damage > 0:
			DataManager.damage_sodiers(fromActor.actorId, wa.actorId, damage)
		LoadControl._error(msg, wa.actorId, mood)
		return

	var war_map = SceneManager.current_scene().war_map
	var build_name = war_map.get_buildCN_by_position(wa.position)
	DataManager.set_env("村庄类型", build_name)
	
	if build_name in ["米屋", "装备店", "医馆"]:
		FlowManager.add_flow("actor_in_vallage")
		return
	FlowManager.add_flow("player_ready")
	return

#进入村庄
func actor_in_vallage():
	var actorId = DataManager.player_choose_actor
	SceneManager.show_confirm_dialog("是否进入村庄?", actorId)
	LoadControl.set_view_model(103)
	return

#进入米屋
func actor_in_rice():
	var actorId = DataManager.player_choose_actor
	var menu = ["买米", "卖米"]
	DataManager.set_env("列表值", menu)
	SceneManager.hide_all_tool()
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = menu
	SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(0, 62), Vector2(190, 40))
	SceneManager.lsc_menu.lsc._set_data(32)
	var msg = "此处是米屋\n买米还是卖米？"
	SceneManager.lsc_menu.show_msg(msg, Vector2.ZERO, 32)
	SceneManager.lsc_menu.show_orderbook(false)
	SceneManager.show_cityInfo(false)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(104)
	return

#--------买米---------
#输入买米量
func actor_in_rice_buy_1():
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	var wv = wa.war_vstate()
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var price = city.get_rice_buy_price()
	var limit = int(price * wv.money / 100)
	limit = min(limit, 9999 - wv.rice)
	var msg = "每100两金可买得{0}石米".format([price])
	SceneManager.show_input_numbers(msg, ["米"], [limit], [0])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(105)
	return

func actor_in_rice_buy_2():
	var actorId = DataManager.player_choose_actor
	var number = DataManager.get_env_int("数量")
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var cost = int(number * 100 / city.get_rice_buy_price())
	var msg = "花费{0}两金\n购买{1}石米可否?".format([cost, number])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(106)
	return

func actor_in_rice_buy_3():
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	var wv = wa.war_vstate()
	#买米数量
	var number = DataManager.get_env_int("数量")
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var cost = int(number*100/city.get_rice_buy_price())
	wv.rice = min(9999, wv.rice + number)
	wv.money = max(wv.money - cost, 0)
	var msg = "收入{0}石米".format([number])
	SceneManager.show_confirm_dialog(msg, actorId, 1)
	LoadControl.set_view_model(199)
	return

#--------卖米---------
#输入卖米量
func actor_in_rice_sell_1():
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	var wv = wa.war_vstate()
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var price = city.get_rice_sell_price()
	var limit = wv.rice
	limit = min(limit, int(float(9999 - wv.money) * 100.0 / float(price)))
	var msg = "每100石米可卖得{0}两金".format([price])
	SceneManager.show_input_numbers(msg, ["米"], [limit], [0])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(108)
	return

#确认卖米金额
func actor_in_rice_sell_2():
	var actorId = DataManager.player_choose_actor
	var number = DataManager.get_env_int("数量")
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var money = int(number*city.get_rice_sell_price()/100);
	var msg = "将{0}石米卖出\n换取{1}两金可否?".format([number, money])
	SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(109)
	return

func actor_in_rice_sell_3():
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	var wv = wa.war_vstate()
	#卖米数量
	var number = DataManager.get_env_int("数量")
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var money = int(number*city.get_rice_sell_price()/100)
	wv.money = min(9999, wv.money + money)
	wv.rice = max(wv.rice - number, 0)
	var msg = "收入{0}两金".format([money])
	SceneManager.show_confirm_dialog(msg, actorId, 1)
	LoadControl.set_view_model(199)
	return

#--------装备店---------
#装备店
func actor_in_equip():
	SceneManager.show_confirm_dialog("此处是装备店", DataManager.player_choose_actor)
	LoadControl.set_view_model(114)
	return

#装备店菜单
func actor_in_equip_menu():
	var actorId = DataManager.player_choose_actor
	SceneManager.hide_all_tool()
	var menu = StaticManager.EQUIPMENT_TYPES.duplicate()
	DataManager.set_env("列表值", menu)
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = menu
	SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(0, 10), Vector2(190, 40))
	SceneManager.lsc_menu.lsc._set_data(32)
	var msg = "购买何种装备？"
	SceneManager.lsc_menu.show_msg(msg, Vector2.ZERO, 32)
	SceneManager.lsc_menu.show_orderbook(false)
	SceneManager.show_cityInfo(false)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(115)
	return

func actor_in_weapon_menu():
	var actorId = DataManager.player_choose_actor
	SceneManager.hide_all_tool()
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var shop_type = city.get_war_equip_shop_type()
	var equip_dic = StaticManager.get_equip_shop_setting()[str(shop_type)];
	var menu = []
	for weapon_type in ["剑", "刀", "枪", "锤", "斧"]:
		if not weapon_type in equip_dic:
			continue
		if Array(equip_dic[weapon_type]).empty():
			continue
		menu.append(weapon_type)
	DataManager.set_env("列表值", menu)
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = menu
	SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(0, 10), Vector2(190, 40))
	SceneManager.lsc_menu.lsc._set_data(32)
	var msg = "购买何种武器？"
	SceneManager.lsc_menu.show_msg(msg, Vector2.ZERO, 32)
	SceneManager.lsc_menu.show_orderbook(false)
	SceneManager.show_cityInfo(false)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(119)
	return

#装备店详细菜单
func actor_in_equip_2():
	var wf = DataManager.get_current_war_fight()
	var city = wf.target_city()
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	var big_equip_type = get_env_str("大类型")
	var detail_equip_type = get_env_str("子类型")
	var sellings = city.get_war_selling_equips()
	var selling = []
	if detail_equip_type in sellings:
		selling = sellings[detail_equip_type]
	if big_equip_type == "道具":
		# 动态判断加入五铢令
		var wuzhu = clEquip.equip(StaticManager.JEWELRY_ID_WUZHU, "道具")
		if wuzhu.remaining() > 0 and wa != null and wa.get_main_actor_id() == wa.actorId:
			if wa.actor().get_moral() < 40:
				selling[0] = wuzhu
			else:
				var dongzhuo = ActorHelper.actor(StaticManager.ACTOR_ID_DONGZHUO)
				if wa.actor().personality_distance(dongzhuo) <= 10:
					selling[0] = wuzhu
	if big_equip_type == "坐骑":
		# 动态判断加入四轮车
		var silunche = clEquip.equip(StaticManager.STEED_SILUNCHE, "坐骑")
		if silunche.remaining() > 0 and wa != null and wa.get_main_actor_id() == wa.actorId:
			if wa.actor().get_wisdom() >= 99:
				selling[0] = silunche

	var pageSize = 4
	DataManager.set_env("检视装备", -1)
	DataManager.set_env("装备翻页", 0)
	var items = []
	var values = []
	var all = []
	for equip in selling:
		var color = equip.get_name_color_code()
		var flag = ""
		if equip.remaining() == 0:
			flag = "@DEL"
		var dic = {
			"id": equip.id,
			"price": equip.price(),
			"name": equip.name(),
			"color": color,
			"flag": flag,
		}
		if items.size() < 4:
			items.append("{name}  \t{price}{color}{flag}".format(dic))
			values.append(equip.id)
		all.append(dic)

	DataManager.set_env("列表值", values)
	DataManager.set_env("售卖装备", all)
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = items
	SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(0, 10), Vector2(190, 40))
	SceneManager.lsc_menu.lsc._set_data(28)
	SceneManager.hide_all_tool()
	var msg = "买哪个？"
	if all.size() > items.size():
		msg += "（第1/{0}页）".format([1 + int((all.size() - 1) / 4)])
	SceneManager.lsc_menu.show_msg(msg, Vector2.ZERO, 32)
	SceneManager.lsc_menu.show_orderbook(false)
	SceneManager.show_cityInfo(false)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(116)
	return

#确认装备数量
func actor_in_equip_3():
	var actorId = DataManager.player_choose_actor
	var equipType = DataManager.get_env_str("大类型")
	var equipId = DataManager.get_env_int("购买装备")
	var equip = clEquip.equip(equipId, equipType)
	var wa = DataManager.get_war_actor(actorId)
	var limit = int(wa.war_vstate().money / equip.price())
	limit = min(9, limit)
	if equip.remaining() > 0:
		limit = min(equip.remaining(), limit)
	if limit == 1:
		DataManager.set_env("装备数量", 1)
		var msg = "花费{0}两金\n购买1件{1}可否?".format([equip.price(), equip.name()])
		SceneManager.show_yn_dialog(msg, actorId)
		LoadControl.set_view_model(117)
		return
	var msg = "{0}需{1}金，购买几件?".format([equip.name(), equip.price()])
	SceneManager.show_input_numbers(msg, [equip.name()], [limit], [0])
	SceneManager.input_numbers.get_current_input_node().set_number(1)
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(1171)
	return

#确认装备购买结果
func actor_in_equip_4():
	var cnt = DataManager.get_env_int("装备数量")
	var equipType = DataManager.get_env_str("大类型")
	var equipId = DataManager.get_env_int("购买装备")
	var equip = clEquip.equip(equipId, equipType)
	if equip.remaining() > 0:
		cnt = min(equip.remaining(), cnt)
	var cost = cnt * equip.price()
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
	var wv = wa.war_vstate()
	var vs = wa.vstate()
	var actor = ActorHelper.actor(wa.actorId)
	wv.money = max(0, wv.money - cost)
	if equip.remaining() >= 0:
		equip.dec_count(cnt)
	var msg = ""
	# 当前装备
	var current = actor.get_equip(equip.type)
	# 替换装备
	if actor.set_equip(equip):
		msg = "花费{0}，{1}换装{2}".format([cost, actor.get_name(), equip.name()])
		# 身上装备入库
		vs.add_stored_equipment(current)
		msg += "\n{0}置入装备仓库".format([current.name()])
		# 多余购买的装备入库
		var added = 0
		for i in range(1, cnt):
			vs.add_stored_equipment(equip)
			added += 1
		if added > 0:
			msg += "\n另{0}件{1}已入库".format([added, equip.name()])
		#更新体力上限
		actor.set_hp(min(actor.get_max_hp(), actor.get_hp()))
	else:
		for i in cnt:
			vs.add_stored_equipment(equip)
		msg = "花费{0}\n无法装备此物\n{1}件{2}已入库".format([
			cost, cnt, equip.name(),
		])

	SceneManager.show_confirm_dialog(msg, wa.actorId)
	LoadControl.set_view_model(199)
	return

#--------医馆---------
func actor_in_hospital():
	LoadControl.set_view_model(124);
	SceneManager.hide_all_tool();
	SceneManager.show_confirm_dialog("此处是医馆", DataManager.player_choose_actor);
	
func actor_in_hospital_2():
	var actorId = DataManager.player_choose_actor
	var actor = ActorHelper.actor(actorId)
	if not actor.is_injured():
		SceneManager.show_confirm_dialog("并未受伤，正当奋战", actorId, 1)
		LoadControl.set_view_model(199)
		return
	var cost = 50
	DataManager.set_env("花费", cost)
	SceneManager.show_confirm_dialog("治疗需{0}两金".format([cost]), actorId)
	LoadControl.set_view_model(125)
	return

func actor_in_hospital_3():
	var actorId = DataManager.player_choose_actor
	var actor = ActorHelper.actor(actorId)
	var cost = DataManager.get_env_int("花费")
	var wa = DataManager.get_war_actor(actorId)
	var wv = wa.war_vstate()
	if wv.money < cost:
		SceneManager.show_confirm_dialog("军资不足", actorId, 3)
		LoadControl.set_view_model(199)
		return
	wv.money = max(0, wv.money - cost)
	var recover = Global.get_random(35, 45)
	recover = min(actor.get_max_hp() - int(actor.get_hp()), recover)
	recover = actor.recover_hp(recover)
	SceneManager.show_confirm_dialog("体力恢复{0}点".format([recover]), actorId, 1)
	LoadControl.set_view_model(199)
	return

func get_movement_message(wa:War_Actor)->String:
	var msg = "移动至何处？\n请策马"
	if "仙" == wa.get_troops_type():
		msg += "\n点数：{0}".format([wa.poker_point])
	return msg
