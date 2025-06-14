extends "affairs_base.gd"

const view_model_name = "内政-玩家-步骤";

const MARKET_TYPES = {
	"武": "fair_wu.png",
	"知": "fair_sch.png",
	"医": "fair_hos.png",
	"商": "fair_bus.png"
}

func get_view_model():
	if(!DataManager.common_variable.has(view_model_name)):
		return -1;
	return int(DataManager.common_variable[view_model_name]);

func set_view_model(view_model:int):
	DataManager.common_variable[view_model_name] = int(view_model);
	return

func _init() -> void:
	FlowManager.bind_import_flow("player_start", self)
	FlowManager.bind_import_flow("player_before_start", self)
	FlowManager.bind_import_flow("player_drama_events", self)
	FlowManager.bind_import_flow("player_monthly_trigger", self)
	FlowManager.bind_import_flow("player_deal_10001", self)
	FlowManager.bind_import_flow("player_ready", self)
	FlowManager.bind_import_flow("player_show_cityline", self)
	FlowManager.bind_import_flow("player_end", self)
	FlowManager.bind_import_flow("player_end_clear", self)
	FlowManager.bind_import_flow("city_actorinfolist", self)
	FlowManager.bind_import_flow("city_enter_menu", self)
	FlowManager.bind_import_flow("enter_town_menu", self)
	FlowManager.bind_import_flow("enter_barrack_menu", self)
	FlowManager.bind_import_flow("enter_warehouse_menu", self)
	FlowManager.bind_import_flow("enter_fair_menu", self)
	FlowManager.bind_import_flow("player_actor_follower", self)
	FlowManager.bind_import_flow("player_actor_follower_1", self)
	FlowManager.bind_import_flow("enter_temple_menu", self)
	FlowManager.bind_import_flow("show_affair_log", self)
	FlowManager.bind_import_flow("close_affair_log", self)
	FlowManager.bind_import_flow("change_level_start", self)
	FlowManager.bind_import_flow("change_level", self)
	FlowManager.bind_import_flow("player_free_dialog", self)
	FlowManager.bind_import_flow("player_join", self)
	FlowManager.bind_import_flow("player_leave", self)
	FlowManager.bind_import_flow("player_leave_confirmed", self)
	return

func _process(delta: float) -> void:
	if(AutoLoad.playerNo != FlowManager.controlNo):
		return;
	_input_key(delta);
	return

func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.get_bottom();
	var view_model = get_view_model();
	match view_model:
		0:#玩家回合开始：提示本月有命令书的数量
			scene_affiars.set_city_cursor_position(DataManager.player_choose_city);
			if SceneManager.cityInfo.visible and bottom != null:
				if(Input.is_action_just_pressed("ANALOG_UP")):
					bottom.show_cityInfo((bottom.current_info + 1) % 4);
				if(Input.is_action_just_pressed("ANALOG_DOWN")):
					bottom.show_cityInfo((bottom.current_info + 3) % 4);
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				#每月第一次按A，修正监狱和君主非太守问题
				_fix_ceil_actor_status()
				_fix_lord_actor_position()
				DataManager.twinkle_citys.clear();
				FlowManager.add_flow("player_ready");
		1:#选城
			var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
			#print("{0}:{1}".format([str(DataManager.vstates_sort),DataManager.vstate_no]))
			if(Input.is_action_pressed("ANALOG_UP")):
				scene_affiars.cursor_move_up(delta);
				SceneManager.show_cityInfo(false)
			if(Input.is_action_pressed("ANALOG_DOWN")):
				scene_affiars.cursor_move_down(delta);
				SceneManager.show_cityInfo(false)
			if(Input.is_action_pressed("ANALOG_LEFT")):
				scene_affiars.cursor_move_left(delta);
				SceneManager.show_cityInfo(false)
			if(Input.is_action_pressed("ANALOG_RIGHT")):
				scene_affiars.cursor_move_right(delta);
				SceneManager.show_cityInfo(false)
			if(Input.is_action_just_pressed("EMU_START")):
				var vstate_controlNo = DataManager.get_current_control_sort()
				var player:Player = DataManager.players[vstate_controlNo];
				var controlled = player.get_control_citys();
				var cityId = scene_affiars.get_curosr_point_city();
				if cityId >= 0:
					var current = controlled.find(cityId)
					current = (current + 1) % controlled.size()
					cityId = controlled[current]
				else:
					cityId = controlled[0]
				scene_affiars.set_city_cursor_position(cityId)
				##scalarize
				DataManager.player_choose_city = cityId
				SceneManager.show_affairs_menu(false)
				DataManager.cityInfo_type = 1
				SceneManager.show_cityInfo(true)
			if(Input.is_action_just_pressed("EMU_SELECT")):
				FlowManager.add_flow("player_show_cityline");
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var cityId = scene_affiars.get_curosr_point_city();
				if(cityId<0):
					SceneManager.show_unconfirm_dialog("此处并没有城");
					return;
				var city = clCity.city(cityId)
				match city.get_vstate_id():
					-1:
						SceneManager.show_unconfirm_dialog("此乃无主之地");
						return;
					vstateId:
						pass
					_:
						if DataManager.is_alliance(vstateId, city.get_vstate_id()):
							SceneManager.show_unconfirm_dialog("此乃盟友城池")
						else:
							SceneManager.show_unconfirm_dialog("此乃敌方城池")
						return
				var vstate_controlNo = DataManager.get_current_control_sort()
				var player:Player = DataManager.players[vstate_controlNo];
				if(!cityId in player.get_control_citys()):
					SceneManager.show_unconfirm_dialog("没有权限控制该城");
					return;
				DataManager.player_choose_city = cityId;
				FlowManager.add_flow("city_enter_menu")
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				var cityId = scene_affiars.get_curosr_point_city();
				if(cityId<0):
					return;
				var city = clCity.city(cityId)
				if city.get_vstate_id() != vstateId:
					return;
				DataManager.player_choose_city = cityId;
				FlowManager.add_flow("city_actorinfolist");
		2:#武将信息列表
			var conEquipInfo:Control = SceneManager.conEquipInfo;
			var actorId = SceneManager.actor_info.get_current_actorId()
			var actor = ActorHelper.actor(actorId)
			var earray = StaticManager.EQUIPMENT_TYPES
			var equ_type_index = DataManager.get_env_int("装备信息.类型号")
			if(!SceneManager.actor_info.is_rolling()):
				var equ_type:String = StaticManager.EQUIPMENT_TYPES[equ_type_index]
				conEquipInfo.show_equipinfo(actor.get_equip(equ_type), "info");
				conEquipInfo.show();
			else:
				conEquipInfo.hide();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				equ_type_index -= 1;
				if(equ_type_index < 0):
					equ_type_index = earray.size()-1;
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				equ_type_index += 1;
				if(equ_type_index >= earray.size()):
					equ_type_index = 0;
			DataManager.set_env("装备信息.类型号", equ_type_index)
			if(Input.is_action_pressed("ANALOG_UP")):
				SceneManager.actor_info.prev_actor();
			if(Input.is_action_pressed("ANALOG_DOWN")):
				SceneManager.actor_info.next_actor();
			if(Global.is_action_pressed_AX()):
				FlowManager.add_flow("player_ready");
			if(Global.is_action_pressed_BY()):
				FlowManager.add_flow("player_ready");
		3:#城市菜单
			if not is_instance_valid(bottom):
				return;
			if Input.is_action_just_pressed("ANALOG_UP") or Input.is_action_just_pressed("ANALOG_DOWN"):
				if bottom.current_info==0:
					bottom.show_cityInfo(1)
				else:
					bottom.show_cityInfo(0)
			var optionFlows = [
				"enter_town_menu", "enter_barrack_menu",
				"enter_warehouse_menu", "enter_fair_menu",
				"enter_temple_menu"
			]
			wait_for_options(optionFlows, "player_ready", false, bottom)
		4:#城池连线图
			if Global.is_action_pressed_AX():
				var scene = SceneManager.current_scene()
				var mode = scene.city_line_mode
				scene.show_city_line(true, mode + 1)
				return
			if Global.is_action_pressed_BY():
				var scene = SceneManager.current_scene()
				var mode = scene.city_line_mode
				scene.show_city_line(true, mode - 1)
				return
			if Input.is_action_just_pressed("EMU_SELECT"):
				FlowManager.add_flow("player_ready")
				return
			if Input.is_action_just_pressed("EMU_START"):
				FlowManager.add_flow("show_affair_log")
				return
		5: #查看大地图日志
			var affair_log = SceneManager.current_scene().get_node_or_null("affair_log")
			if affair_log != null:
				if Global.is_action_pressed_Left():
					affair_log.scroll_page_up()
				if Global.is_action_pressed_Right():
					affair_log.scroll_page_down()
				if Global.is_action_pressed_Up():
					affair_log.scroll_up()
				if Global.is_action_pressed_Down():
					affair_log.scroll_down()
			if Global.is_action_pressed_BY():
				if not SceneManager.dialog_msg_complete(true):
					return
				FlowManager.add_flow("close_affair_log")
				return
			if Input.is_action_just_pressed("EMU_SELECT"):
				if not SceneManager.dialog_msg_complete(true):
					return
				FlowManager.add_flow("close_affair_log")
				return
		100:#城镇菜单
			if wait_for_options([], "city_enter_menu"):
				match SceneManager.lsc_menu.lsc.cursor_index:
					0:#城镇开发
						FlowManager.add_flow("load_script|affiars/town_develop.gd");
						FlowManager.add_flow("develop_menu");
					1:#武将移动
						FlowManager.add_flow("load_script|affiars/town_move.gd");
						FlowManager.add_flow("move_start");
					2:#情报搜集
						FlowManager.add_flow("load_script|affiars/town_search.gd");
						FlowManager.add_flow("search_start");
					3:#防灾
						FlowManager.add_flow("load_script|affiars/town_defence.gd");
						FlowManager.add_flow("defence_start");
					4:#策略
						FlowManager.add_flow("load_script|affiars/town_policy.gd");
						FlowManager.add_flow("enter_town_policy_menu");
					5:#建言
						FlowManager.add_flow("load_script|affiars/town_suggest.gd");
						FlowManager.add_flow("suggestion_3");
		200:#军营菜单
			if wait_for_options([], "city_enter_menu"):
				var menu_array = DataManager.get_env_array("列表值")
				var menu = menu_array[SceneManager.lsc_menu.lsc.cursor_index]
				match menu:
					"出征":
						var forbidden = DataManager.get_env_dict("内政.MONTHLY.禁出征")
						var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
						var vstateKey = str(vstateId)
						if vstateKey in forbidden:
							var reason = Global.arrval(forbidden[vstateKey])
							if reason.size() == 2:
								var source = reason[0]
								var formula = reason[1]
								if source != "" and Global.count_formula_bool(formula):
									var msg = "因【{0}】本月不可出征".format([source])
									SceneManager.lsc_menu.show_msg(msg)
									return
						FlowManager.add_flow("load_script|affiars/barrack_attack.gd");
						FlowManager.add_flow("attack_choose_target_city");
					"征兵":
						FlowManager.add_flow("load_script|affiars/barrack_conscription.gd");
						FlowManager.add_flow("conscription_start");
					"侦察":
						FlowManager.add_flow("load_script|affiars/barrack_inspect.gd");
						FlowManager.add_flow("inspect_start");
					"任命":
						FlowManager.add_flow("load_script|affiars/barrack_appoint.gd");
						FlowManager.add_flow("appoint_menu");
					"监狱":
						FlowManager.add_flow("load_script|affiars/barrack_ceil.gd");
						FlowManager.add_flow("ceil_menu");
					"技能":
						DataManager.common_variable["列表页码"]=0;
						FlowManager.add_flow("load_script|affiars/barrack_skills.gd");
						FlowManager.add_flow("skill_list");
		300:#仓库菜单
			if wait_for_options([], "city_enter_menu"):
				var menu_array = DataManager.get_env_array("列表值")
				match SceneManager.lsc_menu.lsc.cursor_index:
					0: #物资运送
						FlowManager.add_flow("load_script|affiars/warehouse_transgood.gd");
						FlowManager.add_flow("transgoods_start");
					1: #装备库"
						DataManager.set_env("列表页码", 0)
						FlowManager.add_flow("load_script|affiars/warehouse_equip.gd");
						FlowManager.add_flow("wh_equip_init");
					2: #"赏赐"
						FlowManager.add_flow("load_script|affiars/warehouse_award.gd");
						FlowManager.add_flow("award_menu");
		400:#市集菜单
			if wait_for_options([], "city_enter_menu", false, SceneManager.image_menu):
				var market_type_list = DataManager.get_env_array("列表值")
				match market_type_list[SceneManager.image_menu.cursor_index]:
					"武":
						FlowManager.add_flow("load_script|affiars/fair_equipshop.gd");
						FlowManager.add_flow("equip_start");
					"知":
						FlowManager.add_flow("load_script|affiars/fair_school.gd");
						FlowManager.add_flow("school_start");
					"医":
						FlowManager.add_flow("load_script|affiars/fair_hospital.gd");
						FlowManager.add_flow("hospital_check_injury");
					"商":
						FlowManager.add_flow("load_script|affiars/fair_pawnshop.gd");
						FlowManager.add_flow("pawnshop_menu");
		500:#自动跟随提示
			wait_for_confirmation("player_actor_follower_1")
		501:#跟随确认
			wait_for_confirmation("next_vstate_events")
		700:#寺庙
			if wait_for_options([], "city_enter_menu"):
				match SceneManager.lsc_menu.lsc.cursor_index:
					0:#访隐
						FlowManager.add_flow("load_script|affiars/temple_seeunoffice.gd");
						FlowManager.add_flow("enter_seeunoffice_menu");
					1:#祈祷
						FlowManager.add_flow("load_script|affiars/temple_hope.gd");
						FlowManager.add_flow("hope_start");
					2:#结束
						FlowManager.add_flow("load_script|affiars/town_end.gd");
						FlowManager.add_flow("endmonth_start");
					3:#修改难度
						set_view_model(-1)
						FlowManager.add_flow("change_level_start")
					4:#归隐山林
						set_view_model(-1)
						FlowManager.add_flow("player_leave")
		701:#修改难度
			if wait_for_options([], "enter_temple_menu"):
				set_view_model(-1)
				FlowManager.add_flow("change_level")
		702:#难度修改完毕
			wait_for_confirmation("city_enter_menu")
		703:#确认归隐
			wait_for_yesno("player_leave_confirmed", "enter_temple_menu", false)
		800:#中途加入
			var option = wait_for_choose_item("month_init", true)
			var actorIds = DataManager.get_env_int_array("列表值")
			if option < 0 or option >= actorIds.size():
				return
			set_view_model(-1)
			var actorId = actorIds[option]
			if actorId == -1:
				var page = DataManager.get_env_int("内政.中途加入.翻页")
				DataManager.set_env("内政.中途加入.翻页", page + 1)
				FlowManager.add_flow("player_join")
			elif actorId == -2:
				var page = DataManager.get_env_int("内政.中途加入.翻页")
				DataManager.set_env("内政.中途加入.翻页", page - 1)
				FlowManager.add_flow("player_join")
			else:
				var p = Player.new()
				p.actorId = actorIds[option]
				DataManager.players.clear()
				DataManager.players.append(p)
				FlowManager.add_flow("month_init")
			return
		999:#确认对话
			if SceneManager.cityInfo.visible:
				if Input.is_action_just_pressed("ANALOG_UP"):
					SceneManager.show_cityInfo((DataManager.cityInfo_type + 1) % 4)
				if Input.is_action_just_pressed("ANALOG_DOWN"):
					SceneManager.show_cityInfo((DataManager.cityInfo_type + 3) % 4)
			wait_for_confirmation("city_enter_menu")
	return

#玩家回合开始阶段前，技能触发专用
func player_before_start():
	DataManager.record_affair_log("== <y{0}年{1}月>，玩家行动 ==".format([
		DataManager.year, DataManager.month,
	]))
	SkillHelper.update_all_skill_buff("PLAYER_BEFORE_START")
	if DataManager.month == 1:
		DataManager.auto_save("annualy")
		DataManager.record_affair_log("== <y年度自动存档>完毕 ==")
	else:
		DataManager.auto_save("monthly")
		DataManager.record_affair_log("== <y月度自动存档>完毕 ==")
	FlowManager.add_flow("player_drama_events")
	return

func player_drama_events():
	# 先触发剧情事件
	var process = DataManager.drama_events_process
	for event in StaticManager.get_drama_events(DataManager.drama_path):
		if DataManager.is_drama_event_processed(event["name"]):
			continue
		var script = LoadControl.load_script(event["script"])
		if script == null or not script.has_method("event_start"):
			continue
		script.name = event["name"]
		script.returnFlow = "player_drama_events"
		if script.event_start():
			# 如果满足触发条件，等待事件完成
			return
		else:
			# 结束刚才加载的脚本
			LoadControl.end_script()
	FlowManager.add_flow("player_monthly_trigger")
	return

func player_monthly_trigger():
	# 恢复允许存档
	DataManager.game_saving_enabled = true
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var key = "player_before_start.技能触发武将.{0}".format([vstateId])

	var actorIds = []
	# 遍历所属城市的出仕武将
	for city in clCity.all_cities([vstateId]):
		actorIds.append_array(city.get_actor_ids())
	DataManager.common_variable[key] = actorIds
	FlowManager.add_flow("player_deal_10001")
	return

func player_deal_10001():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var key = "player_before_start.技能触发武将.{0}".format([vstateId])
	var actorIds = Array(DataManager.common_variable[key])
	while not actorIds.empty():
		var actorId = actorIds.pop_front()
		DataManager.common_variable[key] = actorIds
		if SkillHelper.auto_trigger_skill(actorId, 10001, "player_deal_10001"):
			return
	DataManager.common_variable.erase(key)

	var cityId = -1
	for city in clCity.all_cities([vstateId]):
		DataManager.player_choose_city = city.ID
		if city.is_delegated():
			auto_develop_city(city)
	DataManager.set_env("内政.玩家.初始化", 0)
	OrderHistory.reset(vstateId)
	LoadControl.end_script()
	FlowManager.add_flow("load_script|affiars/town_suggest.gd");
	FlowManager.add_flow("suggestion_start");
	return

#玩家回合开始阶段
func player_start():
	var inited = DataManager.get_env_int("内政.玩家.初始化")
	if inited > 0:
		set_view_model(-1)
		FlowManager.add_flow("player_ready")
		return
	# 关闭技能列表缓存
	SkillHelper.reset_skills_list_cache(false)
	DataManager.show_orderbook = true
	if DataManager.orderbook <= 0:
		set_view_model(-1)
		FlowManager.add_flow("player_end");
		return;
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	var actor = ActorHelper.actor(player.actorId)
	var cityId = DataManager.get_actor_at_cityId(player.actorId);
	DataManager.player_choose_city = cityId
	SceneManager.current_scene().set_city_cursor_position(cityId)
	SceneManager.current_scene().cursor.show()
	var msg = "{0}大人\n本月有{1}命令书".format([actor.get_name(),DataManager.orderbook]);
	if DataManager.month == 4:
		msg+="\n★各地出现上等马匹";
	SceneManager.show_confirm_dialog(msg)
	DataManager.set_env("内政.玩家.初始化", 1)
	set_view_model(0)
	return

#玩家回合等待操作阶段
func player_ready():
	Global.clear_waits()
	LoadControl.end_script()
	if DataManager.orderbook <= 0:
		set_view_model(-1)
		FlowManager.add_flow("player_end")
		return
	SoundManager.play_bgm("", true, true)
	SceneManager.clear_bottom();
	DataManager.twinkle_citys.clear();
	DataManager.show_orderbook = true;
	LoadControl.view_model_name = view_model_name;
	SkillHelper.update_all_skill_buff("PLAYER_READY")
	var scene_affiars:Control = SceneManager.current_scene();
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	var actor = ActorHelper.actor(player.actorId)
	scene_affiars.show_city_line(false);
	scene_affiars.cursor.show();
	scene_affiars.set_city_cursor_position(DataManager.player_choose_city);
	SceneManager.show_unconfirm_dialog(actor.get_name()+"大人\n向哪座城市下达命令？");
	LoadControl.view_model_name = view_model_name;
	set_view_model(1)
	DataManager.clear_common_variable(["lsc"])
	return

#玩家回合结束
func player_end():
	# 等待诱发技结束
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.wait:
		return
	var vstate_controlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstate_controlNo];
	if SkillHelper.auto_trigger_skill(player.actorId, 10099, "player_end_clear"):
		return
	player_end_clear()
	return

func player_end_clear():
	set_view_model(-1)
	DataManager.show_orderbook = false
	SceneManager.clear_bottom()
	SceneManager.hide_all_tool()
	SceneManager.current_scene().cursor.hide();
	FlowManager.set_current_control_playerNo(0)
	LoadControl.load_script("affiars/auto_events/affiars_auto_run.gd")
	FlowManager.add_flow("turn_control_end")
	return

#显示城池连线
func player_show_cityline():
	set_view_model(4);
	var scene_affiars:Control = SceneManager.current_scene()
	scene_affiars.show_city_line(true, 0)
	scene_affiars.cursor.hide()
	DataManager.show_orderbook = false
	SceneManager.show_unconfirm_dialog("「A/B」键切换信息\n「开始」查看大地图日志\n「选择」键返回")
	return

#--------------0级：选择城市------------------
#B键展示城池武将
func city_actorinfolist():
	set_view_model(2);
	DataManager.set_env("装备信息.类型号", 0)
	
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	var scene_affiars:Control = SceneManager.current_scene();
	var city = clCity.city(DataManager.player_choose_city)
	SceneManager.show_actor_info_list(city.get_actor_ids())
	scene_affiars.cursor.hide();
	return

#A键进入城市菜单
func city_enter_menu():
	Global.clear_waits()
	LoadControl.end_script()
	if DataManager.orderbook <= 0:
		set_view_model(-1)
		FlowManager.add_flow("player_end")
		return
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_vstate_id() != vstateId:
		set_view_model(-1)
		FlowManager.add_flow("player_ready")
		return
	# 清除光标位置，只保留当前的第一级光标
	var idx = DataManager.get_env_int("lsc.city_enter_menu")
	DataManager.clear_common_variable(["lsc"])
	DataManager.set_env("lsc.city_enter_menu", idx)
	SceneManager.current_scene().cursor.hide();
	DataManager.twinkle_citys = [city.ID]
	SceneManager.show_affairs_menu()
	set_view_model(3)
	return

#-----------------1级：四大选项内的菜单----------------------
#-------（100）城镇-------
func enter_town_menu():
	LoadControl.end_script();
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var menu_array = ["城镇开发","武将移动","情报搜集","防灾","策略","建言"];
	DataManager.common_variable["列表值"]=menu_array;
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("此处是城镇，请下达命令");
	SceneManager.lsc_menu.show_orderbook(true);
	DataManager.cityInfo_type = 1;
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show()
	set_view_model(100)
	return

#-------（200）军营-------
func enter_barrack_menu():
	LoadControl.end_script();
	var city = clCity.city(DataManager.player_choose_city)
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [city.ID]
	SceneManager.hide_all_tool();
	var value_array = ["出征","征兵","侦察","任命"];
	if DataManager.get_game_setting("监狱系统") != "无":
		value_array.append("监狱")
	if DataManager.get_game_setting("技能系统") == "是":
		value_array.append("技能")
	var menu_array = value_array.duplicate();
	var ceilActors = city.get_ceil_actor_ids()
	if not ceilActors.empty() and DataManager.get_game_setting("监狱系统") != "无":
		menu_array[4]="监狱({0}人)".format([ceilActors.size()]);
	
	DataManager.common_variable["列表值"]=value_array;
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("此处是军队，请下达命令");
	SceneManager.lsc_menu.show_orderbook(true);
	DataManager.cityInfo_type = 2;
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show();
	set_view_model(200)
	return

#-------（300）仓库-------
func enter_warehouse_menu():
	set_view_model(300);
	LoadControl.end_script();
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var menu_array = ["物资运送","装备库","赏赐"];
	DataManager.common_variable["列表值"]=menu_array;
	SceneManager.lsc_menu.lsc.columns = 2;
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();
	SceneManager.lsc_menu.show_msg("此处是仓库，请下达命令");
	SceneManager.lsc_menu.show_orderbook(true);
	DataManager.cityInfo_type = 3;
	SceneManager.show_cityInfo(true);
	SceneManager.lsc_menu.show();
	var idx = DataManager.get_env_int("内政.集市选项")
	if idx >= 0:
		SceneManager.lsc_menu.lsc.cursor_index = idx
		DataManager.unset_env("内政.集市选项")
	return

#-------（400）市集-------
func enter_fair_menu():
	set_view_model(400);
	LoadControl.end_script();
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	DataManager.twinkle_citys = [DataManager.player_choose_city];
	SceneManager.hide_all_tool();
	var city = clCity.city(DataManager.player_choose_city)
	var market_type:String = str(city.get_property("集市"))
	#图片数组
	var items_array = [];
	#值数组
	var market_type_list = [];
	var separation = 90;
	
	#开发到一定程度，自动解锁四个功能
	if city.well_developed():
		market_type = "武知医商";
	else:
		var flag = int(SkillRangeBuff.max_val_for_city("城市集市", city.ID))
		if flag > 0 and market_type != "武知医商":
			var market_types = ["武", "知", "医", "商"]
			var result = []
			for i in market_types.size():
				var t = market_types[i]
				if t in market_type:
					result.append(t)
					continue
				if flag & (0x1 << (3 - i)):
					result.append(t)
					continue
			market_type = "".join(result)
	for key in MARKET_TYPES:
		if key in market_type:
			var icon = MARKET_TYPES[key]
			items_array.append("res://resource/images/picture/" + icon)
			market_type_list.append(key)
	
	SceneManager.image_menu.items = items_array;
	DataManager.common_variable["列表值"] = market_type_list;
	SceneManager.image_menu.set_lsc(separation+(4-items_array.size())*30);#间隔
	SceneManager.image_menu._set_data(1.5);
	SceneManager.image_menu.show_msg("此处是市集，请下达命令");
	SceneManager.image_menu.show_orderbook(true);
	DataManager.cityInfo_type = 3;
	SceneManager.show_cityInfo(true);
	SceneManager.image_menu.show();
	return

#-------武将自动跟随-------
func player_actor_follower():
	var player:Player = DataManager.players[FlowManager.controlNo]
	var parentId = DataManager.get_env_int("自动跟随.父")
	var childId = DataManager.get_env_int("自动跟随.子")
	var cityId = DataManager.get_env_int("自动跟随.城市")
	SceneManager.current_scene().cursor.hide()
	var playerName = ActorHelper.actor(player.actorId).get_name()
	var childName = ActorHelper.actor(childId).get_name()
	DataManager.twinkle_citys = [cityId]
	var msg = "{0}大人\n{1}已长大成人\n加入麾下".format([playerName, childName])
	SceneManager.show_confirm_dialog(msg)
	set_view_model(500)
	return

#自动跟随确认
func player_actor_follower_1():
	var childId = DataManager.get_env_int("自动跟随.子")
	SceneManager.show_confirm_dialog("愿效犬马之劳！", childId)
	set_view_model(501)
	return


#-------（700）寺庙-------
func enter_temple_menu():
	LoadControl.end_script()
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [DataManager.player_choose_city]
	SceneManager.hide_all_tool()
	var items = ["访隐","祈祷","结束本月","修改难度","归隐山林"]
	var msg = "此处是寺庙，请下达命令"
	bind_bottom_menu(items, items, msg, 2)
	DataManager.cityInfo_type = 3
	SceneManager.show_cityInfo(true)
	set_view_model(700)
	return

func _fix_ceil_actor_status():
	if DataManager.get_game_setting("监狱系统") != "无":
		return
	for city in clCity.all_cities():
		while not city.get_ceil_actor_ids().empty():
			var ceilActorId = city.get_ceil_actor_ids()[0]
			city.ceil_remove_actor(ceilActorId)
			var ceilActor = ActorHelper.actor(ceilActorId)
			ceilActor.set_status_dead()
			ceilActor.set_loyalty(50)
	return

func _fix_lord_actor_position():
	for vs in clVState.all_vstates():
		if not vs.is_alive():
			continue
		var lordId = vs.get_lord_id()
		var cityId = DataManager.get_office_city_by_actor(lordId)
		if cityId < 0:
			continue
		var city = clCity.city(cityId)
		if city.get_actor_ids().find(lordId) > 0:
			clCity.move_to(lordId, cityId)
	return

func show_affair_log():
	var affair_log = SceneManager.current_scene().get_node_or_null("affair_log")
	if affair_log == null:
		return

	var msg = "[B] / [选择]，回到大地图\n上下左右移动查看日志"
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.dialog_msg_complete(true)
	affair_log.update_data()
	affair_log.show()
	set_view_model(5	)
	return

func close_affair_log():
	var affair_log = SceneManager.current_scene().get_node_or_null("affair_log")
	if affair_log == null:
		return
	affair_log.hide()
	FlowManager.add_flow("player_show_cityline")
	return

func change_level_start()->void:
	SceneManager.current_scene().cursor.hide()
	DataManager.twinkle_citys = [DataManager.player_choose_city]
	SceneManager.hide_all_tool()
	var items = StaticManager.DIFFICULTY_NAMES.duplicate()
	items.erase("普通")
	DataManager.set_env("列表值", items)

	SceneManager.lsc_menu.lsc.items = items
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data()

	var msg = "当前难度：{0}，修改为".format([
		StaticManager.DIFFICULTY_NAMES[DataManager.diffculities]
	])
	SceneManager.lsc_menu.show_msg(msg)
	SceneManager.lsc_menu.show_orderbook(true)
	DataManager.cityInfo_type = 1
	SceneManager.show_cityInfo(true)
	SceneManager.lsc_menu.show()

	set_view_model(701)
	return

func change_level()->void:
	SceneManager.current_scene().cursor.hide()
	var levelName = DataManager.get_env_str("菜单选项")
	var level = StaticManager.DIFFICULTY_NAMES.find(levelName)
	level = max(0, level)
	levelName = StaticManager.DIFFICULTY_NAMES[level]
	DataManager.diffculities = level
	DataManager.twinkle_citys = [DataManager.player_choose_city]
	SceneManager.hide_all_tool()
	SceneManager.show_confirm_dialog("已将游戏难度改为：" + levelName)
	set_view_model(702)
	return

func auto_develop_city(city:clCity.CityInfo)->bool:
	if not city.is_delegated():
		return false
	var msg = "- <y{0}>尝试委任行动".format([
		city.get_name(),
	])
	DataManager.record_affair_log(msg)
	var developments = [
		["dev", "防灾", city.get_defence(), 99],
		["auto_reward", [70, 1000, 100]],
		["dev", "土地", city.get_land(), 999],
		["dev", "产业", city.get_eco(), 999],
		["dev", "人口", city.get_pop(), 50000],
		["auto_reward", [90, 2000, 100]],
		["dev", "人口", city.get_pop(), 100000, 10003],
		["auto_supply", [9000, 50000, 90]],
		["auto_soldiers", [3000, 100000, 50000, 10000]],
		["dev", "人口", city.get_pop(), 200000],
		["auto_search", [50]],
		["dev", "人口", city.get_pop(), 999900],
		["auto_search", [100]],
	]
	for dev in developments:
		if dev[0] != "dev":
			if has_method(dev[0]) and call(dev[0], city, dev[1]):
				return true
			else:
				continue
		if dev[2] < dev[3]:
			# 保存当前 cmd，避免与玩家操作冲突
			var prevCmd = DataManager.get_current_develop_command()
			var cmd = DataManager.new_develop_command(dev[1], city.get_leader_id(), city.ID)
			cmd.delegated = 1
			cmd.decide_cost()
			if cmd.get_real_cost() > city.get_gold():
				# 恢复之前的 cmd，避免与玩家操作冲突
				DataManager.affair_command = prevCmd
				continue
			cmd.execute()
			cmd.affair_report()
			# 恢复之前的 cmd，避免与玩家操作冲突
			DataManager.affair_command = prevCmd
			return true
	return false

func auto_reward(city:clCity.CityInfo, setting:Array)->bool:
	var loyalty = int(setting[0])
	var gold = int(setting[1])
	var cost = int(setting[2])
	if city.get_gold() < gold:
		return false
	var lord = ActorHelper.actor(city.get_lord_id())
	for actorId in city.get_actor_ids():
		var actor = ActorHelper.actor(actorId)
		if actor.get_loyalty() < loyalty:
			var val = min(int(lord.get_moral()/10)+int(cost/20),50)
			if val > 0:
				val = actor.add_loyalty(val)
				city.add_gold(-cost)
				DataManager.record_affair_log("  - 赏赐<r{0}>{1}金，城市金：{2}".format([
					actor.get_name(), cost, city.get_gold(),
				]), true)
				DataManager.record_affair_log("  - 忠诚度+<y{0}>，提升到<y{1}>".format([
					val, actor.get_loyalty(),
				]), true)
				return true
	return false

func auto_soldiers(city:clCity.CityInfo, setting:Array)->bool:
	var gold = int(setting[0])
	var pop = int(setting[1])
	var backup = int(setting[2])
	var recruit = int(setting[3])
	if city.get_gold() < gold:
		return false
	if city.get_pop() < pop:
		return false
	if city.get_backup_soldiers() >= backup:
		return false
	var cost = int(ceil(recruit / 100.0)) * 20
	city.add_city_property("后备兵", recruit)
	city.add_city_property("人口", -recruit)
	city.add_gold(-cost)
	DataManager.record_affair_log("  - 征兵<y{0}>，花费<y{1}>，城市金：<y{2}>".format([
		recruit, cost, city.get_gold(),
	]), true)
	DataManager.record_affair_log("  - 城市人口：<y{0}>，后备兵：<y{1}>".format([
		city.get_pop(), city.get_backup_soldiers(),
	]), true)
	var assigned = false
	for actorId in city.get_actor_ids():
		var actor = ActorHelper.actor(actorId)
		var gap = DataManager.get_actor_max_soldiers(actorId) - actor.get_soldiers()
		gap = min(gap, city.get_backup_soldiers())
		if gap <= 0:
			continue
		city.add_city_property("后备兵", -gap)
		actor.set_soldiers(actor.get_soldiers() + gap)
		assigned = true
	if assigned:
		DataManager.record_affair_log("  - 已自动分配士兵，剩余后备兵：<y{0}>".format([
			city.get_backup_soldiers(),
		]), true)
	return true

func auto_search(city:clCity.CityInfo, setting:Array)->bool:
	var rate = int(setting[0])
	if not Global.get_rate_result(rate):
		return false
	var actorId = city.get_leader_id()
	var cmd = SearchCommand.new(city.ID, actorId)
	for i in 5:
		cmd.decide_result()
		if cmd.result in [1,2,3,4,8]:
			break
	if not cmd.result in [1,2,3,4]:
		cmd.result = 8
	cmd.execute()
	cmd.affair_report()
	return true

func auto_supply(city:clCity.CityInfo, setting:Array)->bool:
	var vstateId = city.get_vstate_id()
	var excludedCityIds = []
	# 优先遍历邻接前线城市
	for id in city.get_transfer_city_ids():
		var targetCity = clCity.city(id)
		if targetCity.is_delegated():
			continue
		if _auto_supply_to(city, setting, targetCity):
			return true
		excludedCityIds.append(id)
	# 邻接前线城市均无须运输补充，考虑邻接委任城市
	# 计算与首都的距离
	var capital = clCity.get_capital_city(vstateId)
	var distance = clCity.get_city_distance(city.ID, capital.ID, true)
	if distance <= 1:
		return false
	for id in city.get_connected_city_ids([vstateId]):
		var targetCity = clCity.city(id)
		if targetCity.is_delegated():
			continue
		if clCity.get_city_distance(targetCity.ID, capital.ID, true) >= distance:
			continue
		if _auto_supply_to(city, setting, targetCity):
			return true
	return false

func _auto_supply_to(city:clCity.CityInfo, setting:Array, targetCity:clCity.CityInfo)->bool:
	var resource = int(setting[0])
	var soldiers = int(setting[1])
	var treasures = int(setting[2])
	var transfer = [0, 0, 0, 0]
	transfer[0] = min(resource - targetCity.get_gold(), city.get_gold() - 1000)
	transfer[1] = min(resource - targetCity.get_rice(), city.get_rice() - 1000)
	transfer[2] = min(soldiers - targetCity.get_backup_soldiers(), city.get_backup_soldiers())
	transfer[3] = min(treasures - targetCity.get_treasures(), city.get_treasures())
	var action = false
	var limits = [1000, 1000, 5000, 10]
	for i in transfer.size():
		if transfer[i] <= 0:
			transfer[i] = 0
		if transfer[i] >= limits[i]:
			action = true
	if not action:
		return false
	DataManager.record_affair_log(" - <y{0}>向<y{1}>运输物资".format([
		city.get_name(), targetCity.get_name(),
	]), true)
	var attrs = ["金", "米", "后备兵", "宝"]
	for i in transfer.size():
		if transfer[i] <= 0:
			continue
		city.add_city_property(attrs[i], -transfer[i])
		targetCity.add_city_property(attrs[i], transfer[i])
		DataManager.record_affair_log(" - 运出<r{0}><y{1}>，<y{2}>：<y{3}>，<y{4}>：<y{5}>".format([
			attrs[i], transfer[i],
			city.get_name(), int(city.get_property(attrs[i])),
			targetCity.get_name(), int(targetCity.get_property(attrs[i])),
		]), true)
	return true

# 观海模式，玩家加入游戏
func player_join():
	FlowManager.force_change_controlNo(0)

	var candidates = []
	for vs in clVState.all_vstates():
		if vs.is_perished():
			continue
		candidates.append(vs)

	var page = DataManager.get_env_int("内政.中途加入.翻页")
	var maxPage = int((candidates.size() - 1) / 14)
	if page < 0:
		page = maxPage
	if page > maxPage:
		page = 0
	DataManager.set_env("内政.中途加入.翻页", page)
	candidates = candidates.slice(page * 14, min(candidates.size() - 1, page * 14 + 13))

	var items = []
	var values = []
	for vs in candidates:
		items.append("{0}（{1}城）".format([vs.get_lord_name(), clCity.all_cities([vs.id]).size()]))
		values.append(vs.get_lord_id())
	for i in range(items.size(), 14):
		items.append("")
		values.append("")
	if maxPage > 0:
		items.append("下一页")
		values.append(-1)
		items.append("上一页")
		values.append(-2)

	var msg = "请选择中途加入的势力\n「B」键继续观海"
	SceneManager.show_unconfirm_dialog(msg, -5)
	bind_top_menu(items, values)
	set_view_model(800)
	return

# 归隐山林，开始观海
func player_leave():
	var vstateControlNo = DataManager.get_current_control_sort()
	var player:Player = DataManager.players[vstateControlNo]
	var msg = "{0}大人厌倦了乱世吗？\n刀枪入库，马放南山\n观看 AI 演绎，可否？\n".format([
		ActorHelper.actor(player.actorId).get_name(),
	])
	SceneManager.show_yn_dialog(msg, -5)
	SceneManager.actor_dialog.lsc.cursor_index = 1
	set_view_model(703)
	return

# 确认归隐
func player_leave_confirmed():
	set_view_model(-1)
	var vstateControlNo = DataManager.get_current_control_sort()
	if vstateControlNo >= 0 and vstateControlNo < DataManager.players.size():
		DataManager.players[vstateControlNo].actorId = -1
	DataManager.orderbook = 0
	FlowManager.add_flow("player_ready")
	return
