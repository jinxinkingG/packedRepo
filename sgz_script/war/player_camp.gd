extends "war_base.gd"

const COST_AP = 10

#营帐
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤";
	FlowManager.bind_signal_method("player_camp_start", self)
	FlowManager.bind_signal_method("player_camp_start_list", self)
	FlowManager.bind_signal_method("player_camp_2", self)
	FlowManager.bind_signal_method("player_camp_in_start", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_war:Control = SceneManager.current_scene();
	var war_map = scene_war.war_map;
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var view_model = LoadControl.get_view_model();
	var msg = "";
	match view_model:
		161:#选择武将
			if(Input.is_action_just_pressed("ANALOG_UP")):
				top.lsc.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				top.lsc.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				top.lsc.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				top.lsc.move_right();
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var wa = DataManager.get_war_actor(DataManager.player_choose_actor);
				var wv = wa.war_vstate()
				var actor_num = wv.get_actors_count();
				var value_array = DataManager.get_env_array("列表值")
				var choose_actorId = int(value_array[top.lsc.cursor_index]);
				var new_actor_nums = top.lsc.get_selected_list().size();
				if(choose_actorId >= 0):
					msg = wv.check_camp_out(choose_actorId);
					if msg != "":
						return;
					top.lsc.set_selected_change(max(0,10-actor_num-new_actor_nums));
					new_actor_nums = top.lsc.get_selected_list().size();
					SceneManager.show_unconfirm_dialog("请选择出战武将\n（已出战{0}/10）".format([new_actor_nums+actor_num]), DataManager.player_choose_actor);
					SceneManager.dialog_msg_complete(true);
					SceneManager.lsc_menu_top.show();
				else:#结束
					var select_indexs = top.lsc.get_selected_list();
					for index in select_indexs:
						var actorId = int(value_array[index]);
						wv.camp_out(actorId);
					FlowManager.add_flow("player_camp_2");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("player_ready");
		162:#确认出击
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				FlowManager.add_flow("player_ready");
		163:#列表选择
			if not wait_for_choose_list_actor("player_ready"):
				return
			var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
			var wv = wa.war_vstate()
			var targetId = int(SceneManager.actorlist.get_select_actor())
			var selected = SceneManager.actorlist.get_picked_actors()
			if targetId >= 0:
				var camped = wv.get_actors_count()
				if not SceneManager.actorlist.is_actor_picked(targetId):
					if camped + selected.size() >= 10:
						return
				msg = wv.check_camp_out(targetId);
				if msg != "":
					msg = msg+"（已出战{0}/10）".format([camped + selected.size()])
					SceneManager.actorlist.update_message(msg)
					return
				SceneManager.actorlist.set_actor_picked(targetId)
				selected = SceneManager.actorlist.get_picked_actors()
				msg = "请选择出营武将（已出战{0}/10）".format([camped + selected.size()])
				SceneManager.actorlist.update_message(msg)
				return
			elif targetId != -1:
				return
			if selected.empty():
				FlowManager.add_flow("player_ready")
				return
			for actorId in selected:
				wv.camp_out(actorId)
			FlowManager.add_flow("player_camp_2")
		171:
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actor_dialog.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actor_dialog.move_right()
			if Input.is_action_just_pressed("ANALOG_UP"):
				SceneManager.actor_dialog.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				SceneManager.actor_dialog.move_down()
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				match SceneManager.actor_dialog.lsc.cursor_index:
					0:
						var wa = DataManager.get_war_actor(DataManager.player_choose_actor);
						wa.camp_in()
						FlowManager.add_flow("draw_actors");
						LoadControl._error("{0}已撤回营帐".format([wa.get_name()]))
					1:
						FlowManager.add_flow("player_ready")
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("player_ready");
	return

func player_camp_start():
	LoadControl.set_view_model(161);
	var scene_war = SceneManager.current_scene();
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor);
	var wv = wa.war_vstate()
	SceneManager.hide_all_tool()
	var page = DataManager.get_env_int("列表页码")
	var page_nums = 23;#每页数量
	var menu_array = [];
	var value_array = [];
	for actorId in wv.camp_actors:
		if menu_array.size() >= page_nums:
			break;
		var actor_name = ActorHelper.actor(actorId).get_name();
		value_array.append(actorId);
		menu_array.append(actor_name);
	
	menu_array.append("结束");
	value_array.append(-1);
	
	#已出战
	var actor_num = wv.get_actors_count()
	DataManager.common_variable["列表值"]=value_array;
	SceneManager.lsc_menu_top.set_lsc(Vector2(20, 0),Vector2(160, 42))
	SceneManager.lsc_menu_top.lsc.columns = 3;
	SceneManager.lsc_menu_top.lsc.items = menu_array;
	
	SceneManager.lsc_menu_top.lsc._set_data();
	SceneManager.show_unconfirm_dialog("请选择出战武将\n（已出战{0}/10）".format([actor_num]), DataManager.player_choose_actor);
	SceneManager.lsc_menu_top.show();

func player_camp_start_list():
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
	var wv = wa.war_vstate()
	#已出战
	var actor_num = wv.get_actors_count();
	if actor_num >= 10:
		SceneManager.show_confirm_dialog("出阵已满10人\n营帐内武将不可出战", wa.actorId)
		LoadControl.set_view_model(162)
		return
	var msg = "请选择出营武将（已出战{0}/10）".format([actor_num])
	SceneManager.show_actorlist_army(wv.camp_actors, true, msg, false)
	LoadControl.set_view_model(163)
	return

func player_camp_2():
	LoadControl.set_view_model(162);
	SceneManager.show_confirm_dialog("营帐武将准备出击",DataManager.player_choose_actor,0);
	

func player_camp_in_start():
	var scene_war = SceneManager.current_scene()
	var wa = DataManager.get_war_actor(DataManager.player_choose_actor);
	var wv = wa.war_vstate()
	if wa.actorId == wv.main_actorId:
		LoadControl._error("吾乃主将!", wa.actorId)
		return
	if wa.get_buff_label_turn(["围困"]) > 0:
		LoadControl._error("处于围困状态\n无法撤回营帐", wa.actorId)
		return
	var leader = DataManager.get_war_actor(wv.main_actorId)
	var distance = max(abs(leader.position.x-wa.position.x),abs(leader.position.y-wa.position.y))
	if distance > 4:
		LoadControl._error("相距主将太远\n无法撤回营帐",wa.actorId,3);
		return
	var cost = COST_AP
	var msg = "确定消耗{0}点机动力\n回到营帐吗？"
	var srb = SkillRangeBuff.max_for_actor("回营机动力消耗比例", wa.actorId)
	if srb != null and srb.effectTagVal > 0:
		cost = int(cost * (100 - srb.effectTagVal) / 100)
		msg += "\n（【{0}】减少所需机动力".format([srb.skillName])
	msg = msg.format([cost])
	if wa.action_point < cost:
		LoadControl._error("至少{0}点机动力\n才能回营".format([cost]),wa.actorId,3);
		return
	SceneManager.show_yn_dialog(msg, wa.actorId)
	LoadControl.set_view_model(171)
	return
