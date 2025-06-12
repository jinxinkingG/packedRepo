extends "res://script/clEnvBase.gd"

#武将用计
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤"
	FlowManager.bind_signal_method("stratagem_anyway", self)
	FlowManager.bind_signal_method("stratagem_menu", self)
	FlowManager.clear_pre_history.append("stratagem_menu")
	return

#按键操控
func _input_key(delta: float):
	var bottom = SceneManager.lsc_menu;
	var top = SceneManager.lsc_menu_top;
	var view_model = LoadControl.get_view_model();
	var actorId = int(DataManager.player_choose_actor);
	match view_model:
		120:#计策列表
			var description_visible = top.get_TopMsg_visible();
			if not description_visible:
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
					var menu_array = DataManager.common_variable["列表值"];
					if top.lsc.cursor_index < 0:
						return
					if top.lsc.cursor_index >= menu_array.size():
						return
					var stratagem:String = str(menu_array[top.lsc.cursor_index]);
					if(stratagem==""):
						return;
					var stratagemInfo = StaticManager.get_stratagem(stratagem)
					if not stratagemInfo.performable(actorId):
						return;
					LoadControl.set_view_model(-1)
					DataManager.common_variable["值"]=stratagem;
					LoadControl.load_script(DataManager.mod_path+"sgz_script/war/player_stratagem.gd");
					FlowManager.add_flow("stratagem_start");
				if(Global.is_action_pressed_BY()):
					if(!SceneManager.dialog_msg_complete(false)):
						return;
					DataManager.clear_common_variable(["计策.ONCE"])
					FlowManager.add_flow("player_ready");
				if(Input.is_action_just_pressed("EMU_SELECT")):
					var menu_array = DataManager.common_variable["列表值"];
					var stratagem:String = str(menu_array[top.lsc.cursor_index]);
					if(stratagem==""):
						return;
					var schemeInfo = StaticManager.get_stratagem(stratagem)
					var top_msg = "[center][color=yellow]【{0}】[/color][/center]\n{1}".format([
						schemeInfo.name, schemeInfo.get_description().replacen("\\n","\n")
					])
					top.set_TopMsg_text(top_msg);
					top.set_TopMsg_visible(true);
			else:
				if(Input.is_action_just_pressed("EMU_SELECT") or Global.is_action_pressed_BY()):
					top.set_TopMsg_visible(false);

func stratagem_anyway() -> void:
	stratagem_menu(true)
	return

#展示计策列表
func stratagem_menu(evenDisabled:bool=false):
	DataManager.grouped_trace_reset()
	var actorId = DataManager.player_choose_actor
	var wa = DataManager.get_war_actor(actorId)
	if wa.get_buff_label_turn(["禁用计策"]) > 0 and not evenDisabled:
		var msg = "已被禁用计策"
		LoadControl._error(msg, actorId, 3)
		return

	var key = "战争.计策.允许.{0}".format([actorId])
	DataManager.set_env(key, 1)
	# 触发判断，是否可发动计策，不支持 flow，可以在 key 中返回错误信息
	SkillHelper.auto_trigger_skill(actorId, 20024, "")
	var msg = get_env_str(key)
	if msg != "1":
		if msg == "0" or msg.empty():
			msg = "不可"
		LoadControl._error(msg, actorId, 3)
		return

	SkillHelper.reset_skills_list_cache(true)

	DataManager.new_stratagem_execution(-1, "")
	var map = SceneManager.current_scene().war_map
	map.clear_can_choose_actors()
	map.next_shrink_actors = []
	var schemes = []
	for scheme in wa.get_stratagems():
		schemes.append([scheme.name, scheme.get_cost_ap(wa.actorId), ""])
	msg = "使用何种计策？\n(当前机动力:{0})".format([wa.action_point])

	# 计策菜单事件触发和数据处理
	set_env("战争.计策列表", schemes)
	set_env("战争.计策替换", {})
	set_env("战争.计策提示", msg)
	SkillHelper.auto_trigger_skill(actorId, 20004, "")
	schemes = get_env_array("战争.计策列表")
	msg = get_env_str("战争.计策提示")
	
	var items = []
	var values = []
	for scheme in schemes:
		var name = str(scheme[0])
		var schemeInfo = StaticManager.get_stratagem(name)
		if schemeInfo == null:
			continue
		var cost = int(scheme[1])
		cost = schemeInfo.perform_cost(actorId, true)
		var ext = ""
		if scheme.size() > 2:
			ext = str(scheme[2])
		var fmt = "{0}({1})"
		if ext != "":
			fmt = "{0}({1}-{2})"
		if cost <= 0:
			fmt = "{0}"
		items.append(fmt.format([name, cost, ext]))
		values.append(name)

	SkillHelper.reset_skills_list_cache(false)

	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, values, 2)
	SceneManager.lsc_menu_top.set_lsc(Vector2.ZERO, Vector2(270, 40))
	SceneManager.lsc_menu_top.lsc._set_data(30)
	SceneManager.lsc_menu_top.set_memo("查看计策说明")
	LoadControl.set_view_model(120)
	DataManager.grouped_trace_output(true, "SCHEME")
	return
