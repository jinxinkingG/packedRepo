extends Resource

const view_model_name = "白兵战-玩家-步骤";

var temp_actorId:int = -1;

var iTactic;

func get_view_model():
	return DataManager.get_env_int(view_model_name)

func set_view_model(view_model:int):
	DataManager.set_env(view_model_name, view_model)
	return

func _init() -> void:
	FlowManager.bind_import_flow("battle_set_formation", self)
	FlowManager.bind_import_flow("player_formation_decide", self)
	FlowManager.bind_import_flow("player_formation_decided", self)
	FlowManager.bind_import_flow("battle_before_state", self)
	FlowManager.bind_import_flow("battle_init_set_state", self)
	FlowManager.bind_import_flow("battle_set_state", self)
	FlowManager.bind_import_flow("player_surrend", self)
	FlowManager.bind_import_flow("before_AI_tactic", self)
	FlowManager.bind_import_flow("confirm_AI_tactic", self)
	FlowManager.bind_import_flow("confirm_AI_tactic_1", self)
	FlowManager.bind_import_flow("confirm_AI_tactic_1yn", self)
	FlowManager.bind_import_flow("wait_AI_active_skill", self)
	FlowManager.bind_import_flow("battle_free_talk", self)
	iTactic = Global.load_script(DataManager.mod_path+"sgz_script/battle/ITactic.gd")
	return
	
func _process(delta: float) -> void:
	if AutoLoad.playerNo != FlowManager.controlNo:
		return
	_input_key(delta)
	return

func _input_key(delta: float):
	var scene_battle:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var bf = DataManager.get_current_battle_fight()
	match get_view_model():
		0:#选择阵型
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				SceneManager.image_menu.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				SceneManager.image_menu.move_right();
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.image_menu.is_msg_complete():
				SceneManager.image_menu.show_all_msg()
				return
			set_view_model(-1)
			var idx = SceneManager.image_menu.cursor_index
			var formations = DataManager.get_env_int_array("阵型列表")
			var formation = -1
			if idx < 0 or idx >= formations.size():
				formation = idx
			else:
				formation = formations[idx]
			var actorId = DataManager.get_env_int("当前武将")
			bf.set_formation(actorId, formation)
			FlowManager.add_flow("battle_before_state")
		1:#对话确认：初始状态前
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			set_view_model(-1)
			FlowManager.add_flow("battle_init_set_state")
		2:#选择初始兵种状态
			var battle_state = scene_battle.battle_state
			battle_state.keyin()
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			set_view_model(-1)
			var actorId = DataManager.get_env_int("当前武将")
			bf.set_unit_state(actorId, battle_state.get_dict())
			FlowManager.add_flow("check_formation_ready");
		4:#暂停选择兵种状态
			scene_battle.show_units_hp(true, false)
			var battle_state = scene_battle.battle_state
			battle_state.keyin()
			if Global.is_action_pressed_BY():
				set_view_model(41)
				return
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			var actorId = DataManager.get_env_int("当前武将")
			var actor = ActorHelper.actor(actorId)
			var wa = DataManager.get_war_actor(actorId)
			var states = battle_state.get_dict()
			if states["将"] == "战术":
				states.erase("将")
				bf.set_unit_state(actorId, states)
				if not wa.can_use_tactic() and iTactic.get_actor_tactic(actorId).empty():
					var msg = DataManager.get_env_str("战斗.战术禁用原因")
					if msg != "":
						SceneManager.show_confirm_dialog(msg, actorId, 3)
						set_view_model(11)
					return
				FlowManager.add_flow("load_script|battle/player_tactic.gd")
				FlowManager.add_flow("player_tactic")
				return
			if states["将"] == "状态":
				set_view_model(12)
				battle_state.switch_actor_info()
				return
			if states["将"] == "投降":
				#进入投降逻辑
				if actor.get_loyalty() == 100:
					#非君主才能投降
					set_view_model(-1)
					FlowManager.add_flow("unit_action")
					return
				FlowManager.add_flow("player_surrend")
				return
			#其他：继续主行动逻辑
			set_view_model(-1)
			FlowManager.add_flow("check_battle_need_over")
			bf.set_unit_state(actorId, states)
			battle_state.hide()
		41:
			scene_battle.show_units_hp(true, false)
			var currentUnitId = bf.get_env_int("当前状态单位")
			if currentUnitId < 0:
				currentUnitId = DataManager.get_env_int("白兵.行动单位")
			if currentUnitId < 0:
				currentUnitId = 0
			scene_battle.highlight_unit(currentUnitId)
			scene_battle.battle_unit_status.keyin()
			if Global.is_action_pressed_BY() \
				or Global.is_action_pressed_AX():
				scene_battle.highlight_unit(-1)
				set_view_model(4)
				return
		5:#主动投降
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
					0:#是
						var actorId = int(DataManager.common_variable["当前武将"]);
						for unit in DataManager.battle_units:
							if(unit.get_unit_type()!="将" || unit.leaderId!=actorId):
								continue;
							unit.is_surrend = true;
							break;
						var actor = ActorHelper.actor(actorId)
						actor.set_loyalty(max(10,79-actor.get_loyalty()));#投降忠赋值
						FlowManager.add_flow("check_battle_need_over")
					1:#否
						set_view_model(-1);
						FlowManager.add_flow("unit_action");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				set_view_model(-1);
				FlowManager.add_flow("unit_action");
		6:#确认AI战术
			Global.wait_for_confirmation("wait_for_AI_tactic", view_model_name)
		7:#确认AI战术（是/否），目前只有挑衅
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actor_dialog.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actor_dialog.move_right()
			if Input.is_action_just_pressed("ANALOG_UP"):
				SceneManager.actor_dialog.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				SceneManager.actor_dialog.move_down()
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			set_view_model(-1)
			var actorId = DataManager.get_env_int("当前武将")
			match SceneManager.actor_dialog.lsc.cursor_index:
				0:#是
					FlowManager.add_flow("go_to_solo")
					return
				1:
					var wa = DataManager.get_war_actor(actorId)
					var enemy = wa.get_battle_enemy_war_actor()
					if bf.reject_solo_request(enemy.actorId, ""):
						set_view_model(6)
						return
					FlowManager.add_flow("wait_for_AI_tactic")
			return
		9: # 等待 AI 主动技完成
			if Global.is_action_pressed_AX():
				if LoadControl.no_effect_script_objects():
					FlowManager.add_flow("unit_action")
		10: # 等待闲时对话完成
			if Global.wait_for_confirmation("unit_action", view_model_name):
				Input.action_release("EMU_A")
				SceneManager.actor_dialog.hide()
				DataManager.unset_env("白兵.闲时对话")
		11: # 等待战术提示完成
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			set_view_model(4)
			SceneManager.actor_dialog.hide()
		12: # 显示武将信息
			var actorId = DataManager.get_env_int("当前武将")
			var battle_state = scene_battle.battle_state
			if Global.is_action_pressed_AX():
				battle_state.switch_actor_info(1)
				return
			if Input.is_action_just_pressed("ANALOG_UP"):
				battle_state.switch_actor_info(1)
				return
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				battle_state.switch_actor_info(-1)
				return
			if Global.is_action_pressed_BY():
				battle_state.switch_actor_info(0)
				set_view_model(4)
		20:
			if Global.wait_for_confirmation("go_to_solo", view_model_name):
				SceneManager.actor_dialog.hide()
		21:
			if not Global.wait_for_confirmation("", view_model_name):
				return
			var actorId = DataManager.get_env_int("当前武将")
			var wa = DataManager.get_war_actor(actorId)
			var me = wa.get_battle_enemy_war_actor()
			if bf.reject_solo_request(me.actorId):
				set_view_model(6)
				return
			SceneManager.actor_dialog.hide()
			FlowManager.add_flow("wait_for_AI_tactic")
		30:
			if not Global.wait_for_choose_option("player_formation_decided", view_model_name):
				return
		_: #随时等待玩家按A暂停和B切换血量
			if Global.is_action_pressed_AX():
				scene_battle.player_call_pause(AutoLoad.playerNo)
			if Global.is_action_pressed_BY():
				scene_battle.toggle_units_hp()
	return

func battle_set_formation():
	var bf = DataManager.get_current_battle_fight()
	var actorId = DataManager.get_env_int("当前武将")
	var units = 22
	var soldiers = ActorHelper.actor(actorId).get_soldiers()
	if soldiers < 1000:
		units = int(soldiers / 100) * 2
		if soldiers % 100 != 0:
			units += 1
	var inverted = false
	if actorId == bf.get_defender_id():
		inverted = true
	var formation = DataManager.get_env_int("预设阵型")

	#图片数组
	var items = []
	var separation = 90
	var msg = "请排兵布阵："
	var formations = [0, 1, 2, 3]
	if formation >= 0:
		msg = "已锁定阵型："
		formations = [formation]

	#显示阵型图片选项
	for f in formations:
		items.append([f, inverted, units])

	DataManager.set_env("阵型列表", formations)
	SceneManager.hide_all_tool()
	SceneManager.image_menu.items = items
	SceneManager.image_menu.set_lsc(separation + (4 - items.size()) * 30)
	SceneManager.image_menu._set_data(0.8)
	SceneManager.image_menu.show_msg(msg, actorId)
	SceneManager.image_menu.show_orderbook(false)
	SceneManager.image_menu.show()
	set_view_model(0)
	return

func player_formation_decide() -> void:
	var bf = DataManager.get_current_battle_fight()
	var actorId = bf.get_env_int("阵型选择玩家")
	var actor = ActorHelper.actor(actorId)
	var settings = bf.get_env_array("玩家阵型选择")

	var options = []
	var prefered = actor._get_attr_str("阵型选择")
	var preferedIndex = -1
	for setting in settings:
		if prefered == setting["source"]:
			preferedIndex = options.size()
		options.append(setting["source"])
	SceneManager.hide_all_tool()
	var msg = "请选择列阵技能："
	
	SceneManager.bind_bottom_menu(msg, options, 2)
	SceneManager.show_cityInfo(false)
	SceneManager.lsc_menu.show_orderbook(false)
	SceneManager.lsc_menu.nprFace.set_actor(actorId)
	SceneManager.lsc_menu.conActor.show()
	if preferedIndex >= 0:
		SceneManager.lsc_menu.lsc.cursor_index = preferedIndex
	set_view_model(30)
	return

func player_formation_decided() -> void:
	var bf = DataManager.get_current_battle_fight()
	var actorId = bf.get_env_int("阵型选择玩家")
	var actor = ActorHelper.actor(actorId)
	var settings = bf.get_env_array("玩家阵型选择")
	var decided = DataManager.get_env_str("目标项")
	for setting in settings:
		if setting["source"] == decided:
			actor._set_attr_str("阵型选择", decided)
			bf.apply_extra_formation_setting(actorId, setting)
			FlowManager.add_flow("battle_decide_formation")
			return
	set_view_model(30)
	return

func battle_before_state():
	set_view_model(1)
	var p:Player = DataManager.players[int(FlowManager.controlNo)];
	var p_actor = ActorHelper.actor(p.actorId)
	SceneManager.show_confirm_dialog("{0}大人\n请向各兵种下达命令".format([p_actor.get_name()]))
	return
	
#初始兵种状态设置
func battle_init_set_state():
	set_view_model(2);
	var bf = DataManager.get_current_battle_fight()
	var scene_battle = SceneManager.current_scene();
	var battle_state = scene_battle.battle_state;
	var actorId = int(DataManager.common_variable["当前武将"]);
	var sodiers_type_array = bf.get_defender_unit_types()
	if actorId == bf.get_attacker_id():
		sodiers_type_array = bf.get_attacker_unit_types()

	battle_state.init_data(actorId, true);
	battle_state.show();

#禁止呼出暂停
func not_wait_for_player_call():
	set_view_model(-1);

func wait_for_player_call():
	set_view_model(3);

#战斗过程中A键暂停弹出状态
func battle_set_state():
	set_view_model(4)
	Input.action_release("EMU_A")
	var bf = DataManager.get_current_battle_fight()
	var scene_battle = SceneManager.current_scene()
	var battle_state = scene_battle.battle_state
	var actorId = DataManager.get_env_int("当前武将")
	battle_state.init_data(actorId)
	battle_state.show();
	scene_battle.battle_tactic.hide()
	Input.action_release("EMU_A")
	return

func player_surrend():
	set_view_model(5);
	var actorId = int(DataManager.common_variable["当前武将"]);
	SceneManager.show_yn_dialog("确认要投降吗？",actorId,3);
	SceneManager.actor_dialog.lsc.cursor_index = 1;

func before_AI_tactic():
	set_view_model(-1);
	var actorId = int(DataManager.common_variable["当前武将"]);
	var war_actor = DataManager.get_war_actor(actorId);
	var war_enemy:War_Actor = war_actor.get_battle_enemy_war_actor();
	var nextFlow = "confirm_AI_tactic"
	var tactic_name = DataManager.get_env_str("值")
	var cost = iTactic.get_tactic_cost(war_actor, tactic_name);
	DataManager.set_env("战术消耗", cost)
	#战术值消耗和判断
	if not war_actor.consume_tactic_point(cost):
		return;

	# 触发我方发动战术事件，支持 flow，可以改变结果
	if SkillHelper.auto_trigger_skill(actorId, 30008, nextFlow):
		return
	if DataManager.get_env_int("战斗.战术接管") > 0:
		nextFlow = "wait_for_AI_tactic"
		DataManager.unset_env("战斗.战术接管")
	# 触发敌方发动战术事件，支持 flow，可以改变结果
	if SkillHelper.auto_trigger_skill(war_enemy.actorId, 30018, nextFlow):
		return
	if DataManager.get_env_int("战斗.战术接管") > 0:
		nextFlow = "wait_for_AI_tactic"
		DataManager.unset_env("战斗.战术接管")
	FlowManager.add_flow(nextFlow)
	return

func confirm_AI_tactic():
	set_view_model(-1)
	var bf = DataManager.get_current_battle_fight()
	var actorId = DataManager.get_env_int("当前武将")
	var wa = DataManager.get_war_actor(actorId)
	var me = wa.get_battle_enemy_war_actor()
	#战术名
	var tactic_name = DataManager.get_env_str("值")

	#等待录入对话
	var msg = ""
	var is_yn = 0;
	match tactic_name:
		"咒缚":
			var stop_rate = iTactic.get_stop_tactic_rate(actorId)
			#AI释放咒缚，命中率-10%
			if Global.get_rate_result(stop_rate-10):
				msg = "暂时无法移动";
				bf.set_buff(actorId, "咒缚", 3)
			else:
				msg = "对方咒缚失败";
		"挑衅":
			if me.get_controlNo() < 0:
				# 如果当前控制者也是 AI（观海模式），直接算概率
				var a = wa.actor()
				var b = me.actor()
				#原挑衅成功率=（a.等级-b.等级）*2+32-b.知/10
				var old_rate = max(0, a.get_level() - b.get_level()) * 2 + 32 - b.get_wisdom()/10
				#新挑衅成功率=体%武%胆%(100-知)%
				var new_rate = max(0, b.get_hp() * b.get_power() * wa.battle_courage * max(1, 100 - b.get_wisdom())/1000000)
				var rate = min(old_rate, new_rate)
				if Global.get_rate_result(rate):
					msg = wa.get_name() + "要求单挑\n正合吾心意！"
					SceneManager.show_confirm_dialog(msg, me.actorId, 0)
					set_view_model(20)
					return
				else:
					msg = wa.get_name() + "要求单挑\n岂能如彼所愿！"
					SceneManager.show_confirm_dialog(msg, me.actorId, 0)
					set_view_model(21)
					return
			else:
				msg = wa.get_name() + "要求单挑\n是否同意?"
				is_yn = 1
		"强弩":
			bf.set_buff(actorId, "强弩", 3)
		"士气向上":
			bf.set_buff(actorId, "士气向上", 4)
		"火矢":
			bf.set_buff(actorId, "火矢", 4)
	SceneManager.current_scene().notice_tactic(wa, tactic_name)
	if msg == "":
		FlowManager.add_flow("wait_for_AI_tactic")
		return
	DataManager.set_env("对话", msg)
	DataManager.set_env("是否询问", is_yn)
	if is_yn:
		FlowManager.add_flow("confirm_AI_tactic_1yn")
	else:
		FlowManager.add_flow("confirm_AI_tactic_1")
	return

#确认战术发动
func confirm_AI_tactic_1():
	var actorId = DataManager.get_env_int("当前武将")
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()
	var msg = DataManager.get_env_str("对话")
	SceneManager.show_confirm_dialog(msg, enemy.actorId, 0)
	set_view_model(6)
	return

#确认战术发动(是/否)
func confirm_AI_tactic_1yn():
	var actorId = DataManager.get_env_int("当前武将")
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()
	var msg = DataManager.get_env_str("对话")
	SceneManager.show_yn_dialog(msg, enemy.actorId, 0)
	# 默认在「否」
	SceneManager.actor_dialog.lsc.cursor_index = 1
	set_view_model(7)
	return

# 等待 AI 主动技发动完成
func wait_AI_active_skill():
	set_view_model(9)
	return

# 播放闲时对话
func battle_free_talk():
	if not DataManager.common_variable.has("白兵.闲时对话"):
		set_view_model(-1)
		return
	var d = War_Character.DialogInfo.new()
	d.input(DataManager.common_variable["白兵.闲时对话"])
	if d.se != "":
		SoundManager.play_anim_bgm(d.se)
	if d.callback_script != "" and d.callback_method != "":
		var scpath = "res://resource/sgz_script/"+d.callback_script;
		var sc = Global.load_script(scpath)
		sc.actorId = d.actorId
		if sc.call(d.callback_method):
			return
	SceneManager.show_confirm_dialog(d.text, d.actorId, d.mood, d.actorId < 0)
	set_view_model(10)
	return

# 避免被 LoadControl 调用
func skip_load_control()->bool:
	return true
