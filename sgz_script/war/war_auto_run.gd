extends "war_base.gd"

var player_control = null;
var AI_control = null;

const CURRENT_STEP_NAME = "战争-当前步骤"
const NEXT_STEP_NAME = "战争-下个步骤"

var war_map
var istory

func _init() -> void:
	var wf = DataManager.get_current_war_fight()
	if wf == null or wf.status != 1:
		return
	FlowManager.clear_pre_history.clear()
	LoadControl.end_script()
	FlowManager.clear_bind_method()

	FlowManager.bind_import_flow("war_map_nav_start", self)
	FlowManager.bind_import_flow("war_map_nav_finish", self)

	FlowManager.bind_import_flow("war_run_start", self)
	FlowManager.bind_import_flow("war_step_0", self)
	FlowManager.bind_import_flow("war_vstate_settlement", self)
	FlowManager.bind_import_flow("war_vstate_settlement_report", self)
	FlowManager.bind_import_flow("war_over_start", self)
	FlowManager.bind_import_flow("war_over_end", self)
	FlowManager.bind_import_flow("turn_control_end_trigger", self)
	FlowManager.bind_import_flow("turn_control_end", self)
	FlowManager.bind_import_flow("vstate_end", self)
	FlowManager.bind_import_flow("check_embattle", self)
	FlowManager.bind_import_flow("check_embattle_trigger", self)
	FlowManager.bind_import_flow("back_to_war", self)
	FlowManager.bind_import_flow("back_to_war_induce_skill", self)
	FlowManager.bind_import_flow("back_to_war_clear", self)
	FlowManager.bind_import_flow("back_to_war_clear_trigger", self)

	FlowManager.bind_import_flow("prepare_turn_skill_trigger", self)
	FlowManager.bind_import_flow("before_turn_skill_trigger", self)
	FlowManager.bind_import_flow("turn_ready_skill_trigger", self)

	war_map = SceneManager.current_scene().war_map
	istory = Global.load_script(DataManager.mod_path+"sgz_script/story/IStory.gd")
	FlowManager.bind_signal_method("draw_actors", war_map)

	player_control = Global.load_script(DataManager.mod_path+"sgz_script/war/player_control.gd")
	AI_control = Global.load_script(DataManager.mod_path+"sgz_script/war/AI_control.gd")
	return

func war_map_nav_start() -> void:
	SoundManager.stop()
	SoundManager.play_bgm()
	DataManager.player_choose_actor = -1
	SceneManager.hide_all_tool()
	war_step_999()
	return

func war_map_nav_finish() -> void:
	LoadControl.end_script()
	FlowManager.add_flow("go_to_scene|res://scene/scene_affiars/scene_affiars.tscn")
	FlowManager.add_flow("load_script|affiars/barrack_inspect.gd")
	FlowManager.add_flow("inspect_more")
	return

func war_run_start():
	# 关闭技能缓存
	SkillHelper.reset_skills_list_cache(false)

	SoundManager.stop()
	SoundManager.play_bgm()

	var wf = DataManager.get_current_war_fight()
	wf.init_war()

	# 无尽模式，触发模拟内政技能
	if DataManager.endless_mode:
		# 清空内政技能CD，无尽模式各关均可触发月度内政技能
		SkillHelper.decrease_skill_cd(10000)
		SkillHelper.decrease_skill_variable(10000)
		for wv in wf.war_vstates():
			for actorId in wv.init_actors:
				# 不支持 flow
				SkillHelper.auto_trigger_skill(actorId, 20034)

	DataManager.player_choose_actor = -1
	SceneManager.hide_all_tool()

	# 显示战争介绍画面
	if is_instance_valid(SceneManager.war_intro):
		SceneManager.war_intro.show_war_intro(wf, "war_step_0")
	else:
		war_step_0()
	return

#读取当前步骤
func get_current_step() -> int:
	return DataManager.get_env_int(CURRENT_STEP_NAME)

#设置当前步骤
func set_current_step(step:int) -> void:
	DataManager.set_env(CURRENT_STEP_NAME, step)
	return

#读取下个步骤
func get_next_step() -> int:
	return DataManager.get_env_int(NEXT_STEP_NAME)

#设置下个步骤
func set_next_step(step:int, memo:String="") -> void:
	var current = get_next_step()
	if current == step:
		return
	var msg = "[WAR] NEXT STEP: {0}, {1}".format([
		step, memo
	])
	DataManager.game_trace(msg)
	DataManager.set_env(NEXT_STEP_NAME, step)
	return

func _process(delta: float) -> void:
	SoundManager.play_bgm()
	var wf = DataManager.get_current_war_fight()
	if wf == null or wf.status != 1:
		return
	if FlowManager.has_task():
		return
	if war_map.is_animating():
		return
	if is_instance_valid(player_control):
		player_control._process(delta)
	if is_instance_valid(AI_control):
		AI_control._process(delta)
	#只需要服务器去处理顺序数据
	if AutoLoad.get_local_id() != 1:
		return
	if get_next_step() == get_current_step():
		return
	set_current_step(get_next_step())

	var currentStep = get_current_step()
	#DataManager.game_trace("== WAR STEP " + str(current_step) + "。")
	var stepMethod = "war_step_{0}".format([currentStep])
	if has_method(stepMethod):
		call(stepMethod)
	return

# 地图浏览
func war_step_999() -> void:
	set_current_step(999)
	set_next_step(999)
	FlowManager.add_flow("player_map_nav_start")
	return

# 每日初始化
func war_step_0() -> void:
	set_current_step(0)
	var wf = DataManager.get_current_war_fight()
	var msg = "战争下一日: #{0}".format([wf.date])
	set_next_step(0, msg)
	wf.next_date()
	war_step_1()
	return

# 每日技能触发
func war_step_1() -> void:
	set_current_step(1)
	var wf = DataManager.get_current_war_fight()
	var msg = "战争{0}日初始化".format([wf.date])
	set_next_step(1, msg)
	var wv = wf.current_war_vstate()
	var actorIds = []
	for wa in wv.get_war_actors(false):
		actorIds.append(wa.actorId)
	wf.set_env("回合开始触发", actorIds)
	prepare_turn_skill_trigger()
	return

# 势力初始化
func war_step_2() -> void:
	set_current_step(2)
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var msg = wv.get_leader_name() + " 军势初始化"
	set_next_step(2, msg)
	# 重置额外回合信息
	wf.clear_extra_round()
	if not wv.ready():
		# 援军未到达战场的情况
		switch_side()
		return
	# 玩家援军到达日的初始化
	if wv.is_reinforcement() and wv.warActors.empty():
		wv.prepare_war_actors(true)
	if wv.lost():
		war_step_21()
		return
	# 初始化本军势控制器
	wv.prepare_controller()
	wv.turn_begin_event()
	# 所有武将的单独机动力在这里恢复
	for wa in wv.get_war_actors(false):
		# 恢复机动力前先刷新点花
		wa.refresh_poker_random(true)
		wa.recharge_action_point()
	war_step_3()
	return

# 势力回合初始事件（开始阶段+布阵）
func war_step_3() -> void:
	set_current_step(3)
	set_next_step(3, "军势布阵")
	check_embattle()
	return

# 控制者-回合初始化
func war_step_4() -> void:
	set_current_step(4)
	set_next_step(4, "回合初始化")
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var type = "玩家"
	if wv.get_main_controlNo() < 0:
		type = "AI"
	var msg = "==== {0}<y{1}>行动开始 (Day#{2}) ====".format([
		type, wv.get_lord_name(), wf.date,
	])
	DataManager.record_war_log(msg)
	FlowManager.add_flow("draw_actors")
	war_step_5()
	return

# 控制者-准备阶段(技能事件)
func war_step_5() -> void:
	set_current_step(5)
	set_next_step(5, "回合前置阶段")
	before_turn_skill_trigger()
	return

# 控制者-主要阶段前（判断是否结束战争）
func war_step_6() -> void:
	set_current_step(6)
	set_next_step(6, "回合准备阶段")
	turn_ready_skill_trigger()
	return

# 控制者-主要阶段
func war_step_7() -> void:
	set_current_step(7)
	set_next_step(7, "回合主控阶段")
	SkillHelper.update_all_skill_buff("WAR_READY")
	var controlNo = DataManager.war_control_sort[DataManager.war_control_sort_no]
	if controlNo >= 0:
		FlowManager.set_current_control_playerNo(controlNo)
		FlowManager.add_flow("player_before_ready")
	else:
		FlowManager.set_current_control_playerNo(0)
		FlowManager.add_flow("AI_turn_start")
	return

# 控制者 - 结束阶段
func war_step_8() -> void:
	set_current_step(8)
	set_next_step(8, "军势行动结束")
	turn_control_end()
	return

# 整个势力结束(势力下所有控制器都结束了)
func war_step_9() -> void:
	set_current_step(9)
	set_next_step(9, "军势回合结束")
	vstate_end()
	return

# 当日结束
func war_step_10() -> void:
	set_current_step(10)
	var wf = DataManager.get_current_war_fight()
	var msg = "战争第{0}日结束".format([wf.date])
	set_next_step(10, msg)
	# 如果天数超过30，攻方失败
	if wf.date >= 30:
		wf.attackerWV.set_lost_reason(War_Vstate.Lose_ReasonEnum.OverDay)
		# 不直接控制流程，交给检查阶段处理
		FlowManager.add_flow("war_vstate_settlement")
		return
	# 进行当天结束的正常结算
	wf.date_finished()
	for wv in wf.war_vstates():
		if wv.lost():
			continue
		# 判断任意一方的粮草不足，则失败
		if wv.rice > 0:
			continue
		wv.set_lost_reason(War_Vstate.Lose_ReasonEnum.FoodExhaustion)
		if wv.is_reinforcement():
			continue
		# 不直接控制流程，交给检查阶段处理
		FlowManager.add_flow("war_vstate_settlement")
		return
	# 一切正常，可以继续
	war_step_0()
	return

# 检查是否有额外回合
func war_step_21() -> void:
	set_current_step(21)
	set_next_step(21, "检查额外回合")

	# 初始化额外回合
	var wf = DataManager.get_current_war_fight()
	if not wf.start_extra_round():
		switch_side()
		return
	FlowManager.add_flow("draw_actors")
	war_step_5()
	return

# AI 布阵
func war_step_30(wv:War_Vstate) -> void:
	if wv == null or wv.embattled > 0 or wv.get_main_controlNo() >= 0:
		war_step_3()
		return
	if not wv.ready():
		wv.embattled = 1
		war_step_3()
		return

	set_current_step(30)
	var msg = wv.get_leader_name() + " AI 布阵"
	set_next_step(30, msg)
	DataManager.set_env("布阵方", wv.id)
	FlowManager.add_flow("AI_auto_embattle")
	return

# 战争探报，在布阵完毕后执行
func war_step_31() -> void:
	set_current_step(31)
	set_next_step(31)
	var AIWVs = []
	var wf = DataManager.get_current_war_fight()
	if wf.auto_play_mode():
		for wv in wf.war_vstates():
			wv.embattleReported = 1
		war_step_3()
		return

	for wv in wf.war_vstates():
		if wv.get_main_controlNo() < 0:
			if wv.embattleReported > 0:
				# 已报过，跳过
				continue
			if wv.get_war_actors(false, true).empty():
				# 无人出阵，跳过
				continue
			AIWVs.append(wv)

	# 逐个探报
	for wv in AIWVs:
		FlowManager.add_flow("draw_actors")
		var leader = wv.get_leader()
		war_map.set_cursor_location(leader.position, true)
		war_map.cursor.hide()
		var reporter = wf.defenderWV.main_actorId
		var warType = "来犯"
		if wv.is_defender():
			warType = "据守"
			if wv.is_reinforcement():
				warType = "增援"
			reporter = wf.attackerWV.main_actorId
		DataManager.set_env("战争.探报方", wv.id)
		var msg = "探报：{0}军{1}人{2}\n共{3}兵\n主将为{4}".format([
			wv.get_lord_name(), wv.get_actors_count(true), warType,
			wv.get_all_soldiers(true), leader.get_name()
		])
		SceneManager.show_confirm_dialog(msg, reporter)
		war_step_32()
		return

	war_step_33()
	return

# 等待情报确认
func war_step_32() -> void:
	# 这里设置 step -1 是为了反复调用等待
	set_current_step(-1)
	set_next_step(32)
	war_map.cursor.show()
	if Global.is_action_pressed_Up():
		war_map.cursor_move_up()
	if Global.is_action_pressed_Down():
		war_map.cursor_move_down()
	if Global.is_action_pressed_Left():
		war_map.cursor_move_left()
	if Global.is_action_pressed_Right():
		war_map.cursor_move_right()
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	var wvId = DataManager.get_env_int("战争.探报方")
	var wf = DataManager.get_current_war_fight()
	var wv = wf.get_war_vstate(wvId)
	if wv != null:
		wv.embattleReported = 1
	war_step_31()
	return

# 检查是否有附加情报
func war_step_33() -> void:
	set_current_step(33)
	set_next_step(33)
	if not DataManager.endless_mode:
		war_step_3()
		return
	if DataManager.get_env_int("战争.探报.野外装备") <= 0:
		var buyings = []
		var wf = DataManager.get_current_war_fight()
		for equip in wf.target_city().get_special_equips()["外"]:
			if equip.remaining() > 0:
				buyings.append(equip)
		DataManager.set_env("战争.探报.野外装备", 1)
		if not buyings.empty():
			var names = []
			for equip in buyings:
				names.append(equip.name())
			if names.size() > 1:
				names[names.size() - 1] += "等稀有装备"
			var msg = "据传：\n{0}野外，有{1}的线索".format([
				wf.target_city().get_full_name(), "、".join(names)
			])
			SceneManager.show_confirm_dialog(msg, EndlessGame.player_actors[0])
			# 这里 trick 一下，如果有野外装备，先报，并退回上一步
			war_step_32()
			return
	var valuables = []
	var dangerous = []
	for actorId in EndlessGame.AI_actors:
		var actor = ActorHelper.actor(actorId)
		var highAttr = 0
		for attr in ["武", "统", "知"]:
			if actor._get_attr_int(attr) >= 80:
				highAttr += 1
		if highAttr >= 2:
			dangerous.append(actor.get_name())
		for type in StaticManager.EQUIPMENT_TYPES:
			var equip = actor.get_equip(type)
			if equip.level() == "S":
				valuables.append(actor.get_name())
				break
	if valuables.size() > 0:
		if valuables.size() > 3:
			valuables[2] += "等{0}人".format([valuables.size()])
			valuables = valuables.slice(0, 2)
		var msg = "据传：\n敌军阵中{0}持有稀有装备，不可轻易错过".format([
			"、".join(valuables)
		])
		SceneManager.show_confirm_dialog(msg, EndlessGame.player_actors[0])
		war_step_34()
		return
	if dangerous.size() > 0:
		if dangerous.size() > 3:
			dangerous[2] += "等{0}人".format([dangerous.size()])
			dangerous = dangerous.slice(0, 2)
		var msg = "据悉：\n敌军阵中{0}战力不俗，须得小心对付".format([
			"、".join(dangerous)
		])
		SceneManager.show_confirm_dialog(msg, EndlessGame.player_actors[0])
		war_step_34()
		return
	war_step_3()
	return

# 等待附加情报确认，目前仅限无尽模式
func war_step_34() -> void:
	set_current_step(-1)
	set_next_step(34)
	war_map.cursor.show()
	if Global.is_action_pressed_Up():
		war_map.cursor_move_up()
	if Global.is_action_pressed_Down():
		war_map.cursor_move_down()
	if Global.is_action_pressed_Left():
		war_map.cursor_move_left()
	if Global.is_action_pressed_Right():
		war_map.cursor_move_right()
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	war_step_3()
	return

# 触发回合结束事件
func war_step_81() -> void:
	set_current_step(81)
	set_next_step(81, "军势行动结束触发")
	turn_control_end_trigger()
	return

# 实际执行回合结束
func war_step_82() -> void:
	set_current_step(82)
	set_next_step(82, "军势行动结束完成")
	var wf = DataManager.get_current_war_fight()
	if wf.is_extra_round():
		DataManager.game_trace("== 额外回合结束")
		var actorIds = wf.get_extra_round_actors()
		var wv = wf.current_war_vstate()
		wv.turn_end_event(actorIds)
		SkillHelper.update_all_skill_buff("EXTRA_ROUND_FINISH")
		SceneManager.hide_all_tool()
		FlowManager.force_change_controlNo(0)
		wf.clear_extra_round()
		switch_side()
		return

	SceneManager.hide_all_tool()
	FlowManager.force_change_controlNo(0)
	DataManager.war_control_sort_no += 1
	if DataManager.war_control_sort_no >= DataManager.war_control_sort.size():
		FlowManager.add_flow("vstate_end")
		return
	war_step_4()
	return

# 检查势力败退结算
# 这里需要考虑各种情况，并且可重入
func war_vstate_settlement() -> void:
	var wf = DataManager.get_current_war_fight()
	# 各势力结算
	for wv in wf.war_vstates():
		if not wv.lost():
			# 未战败，忽略
			continue
		if wv.requires_lost_settlement():
			# 已战败但未撤人
			if not wv.settle_generals_after_war():
				# 需要玩家主动撤人
				FlowManager.set_current_control_playerNo(wv.get_main_controlNo())
				wf.set_env("败退结算", wv.id)
				FlowManager.add_flow("player_retreat_plan")
				return
			# 自动撤离了，直接汇报结果
			wf.set_env("败退结算", wv.id)
			FlowManager.add_flow("war_vstate_settlement_report")
			return
	# 所有军势都已经处理完了，检查是否主攻方或主守方失败
	for wv in [wf.defenderWV, wf.attackerWV]:
		if wv.lost():
			# 判断是否剧情模式
			if DataManager.game_mode2 > 0:
				var dialogCondition = "失败" if wv.get_main_controlNo() >= 0 else "胜利"
				if not istory.get_story_dialog(dialogCondition, false).empty():
					SoundManager.play_bgm("res://resource/sounds/bgm/War_End.ogg")
					DataManager.set_env("剧情.对白类型", dialogCondition)
					FlowManager.add_flow("story_dialogs")
					return
			FlowManager.add_flow("draw_actors")
			FlowManager.add_flow("war_over_start")
			return
	# 战争继续
	FlowManager.add_flow("draw_actors")
	FlowManager.add_flow("player_ready")
	return

func war_vstate_settlement_report() -> void:
	var wf = DataManager.get_current_war_fight()
	var wvId = wf.get_env_int("败退结算")
	var wv = wf.get_war_vstate(wvId)
	if wv == null:
		FlowManager.add_flow("draw_actors")
		FlowManager.add_flow("player_ready")
		return

	var msg = "{0}军"
	if wv.is_reinforcement():
		msg = "{0}的援军"
	msg = msg.format([wv.get_lord_name()])
	msg += wv.get_lost_message()
	msg += "\n已撤离战场"

	# 结算资源
	wv.settle_resources_after_war()
	var money = 0
	var rice = 0
	var settleInfo = wf.get_env_dict("资源结算")
	var wvKey = "wv." + str(wv.id)
	if wvKey in settleInfo:
		if "money" in settleInfo[wvKey]:
			money = Global.intval(settleInfo[wvKey]["money"])
		if "rice" in settleInfo[wvKey]:
			rice = Global.intval(settleInfo[wvKey]["rice"])
	if money + rice > 0:
		msg += "\n截获敌军辎重\n获得"
		if money >= 0:
			msg += "金 {0}、".format([money])
		if rice >= 0:
			msg += "米 {0}".format([rice])
	var enemyWV = wv.get_enemy_vstate()
	if enemyWV != null:
		enemyWV.get_leader().attach_free_dialog(msg, 1)

	FlowManager.add_flow("draw_actors")
	FlowManager.add_flow("player_ready")
	return

#战争结束,进入结算界面（开始）
func war_over_start():
	var wf = DataManager.get_current_war_fight()
	# 全解除托管
	for wv in wf.war_vstates():
		wv.delegate(false)
	wf.set_env("战争结算", 1)

	LoadControl.end_script()

	if DataManager.endless_mode:
		# 无尽模式不进行
		DataManager.set_env("战争.结算方", EndlessGame.PLAYER_VSTATEID)
		FlowManager.add_flow("load_script|war/player_over_settle.gd")
		FlowManager.add_flow("settle_start")
		return

	# 从主军势中找到胜方
	var winner = null
	for wv in [wf.attackerWV, wf.defenderWV]:
		if wv.lost():
			continue
		winner = wv
		break

	var warCity = wf.target_city()
	# 城池归属
	warCity.change_vstate(winner.vstateId)
	# 胜方所有武将直接入城
	winner.send_all_actors_to_city(warCity)

	# 所有非胜方军势自动撤人
	for wv in wf.war_vstates():
		if winner != null and wv.id == winner.id:
			continue
		# 这里不需要判断是否需要玩家处理
		# 因为玩家军势若战败，是走不到这一步的
		# 之前在战场上就已经处理了
		# 若玩家军势未战败，但属于援军，也会自动处理的
		wv.settle_generals_after_war()
		# 结算资源
		wv.settle_resources_after_war()

	# 最终胜方结算资源，确保资源落城
	winner.settle_resources_after_war()

	FlowManager.set_current_control_playerNo(winner.get_main_controlNo())
	DataManager.set_env("战争.结算方", winner.id)
	FlowManager.add_flow("load_script|war/player_over_settle.gd")
	FlowManager.add_flow("settle_start")
	return

func war_over_end():
	var wf = DataManager.get_current_war_fight()
	wf.done()
	if DataManager.endless_mode:#无尽模式
		#玩家方，注意这里要遵循固定顺序约定，FIXME later
		var wv = wf.get_war_vstate(EndlessGame.PLAYER_VSTATEID)
		if wv.lost():
			#玩家方失败，直接返回标题
			SceneManager.restart()
			return
		# 挑战赛过关基础分 +100
		if DataManager.is_challange_game():
			DataManager.add_challange_game_score(100)
		DataManager.clear_common_variable(["战争","大战场","白兵","单挑","诱发"])
		EndlessGame.go_to_pass(EndlessGame.pass_no + 1)
		return

	#如果攻方胜利，城内数值扣减
	if wf.result == 2:
		_decrease("人口", Global.get_random(1,2))
		var dates = [21, 16, 11, 6]
		var losses = [6, 4, 3, 2]
		var loss = 1
		for i in dates.size():
			if wf.date >= dates[i]:
				loss = losses[i]
				break
		_decrease("土地", loss)
		_decrease("产业", loss)
		_decrease("统治度", loss)
	DataManager.unset_env("战争.结算进行")
	wf.cleanup()
	DataManager.war_control_sort = []
	DataManager.common_variable.erase("大限检查")
	LoadControl.end_script()
	DataManager.clear_common_variable(["战争","大战场","白兵","单挑","诱发"])

	FlowManager.add_flow("go_to_scene|res://scene/scene_affiars/scene_affiars.tscn")
	FlowManager.add_flow("back_from_war")
	return

func turn_control_end():
	set_current_step(8)
	# 初始化回合结束事件的触发者
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var msg = wv.get_leader_name() + " 军势行动结束"
	set_next_step(8, msg)
	var currentCtrl = -1
	if DataManager.war_control_sort_no >= 0 \
		and DataManager.war_control_sort_no < DataManager.war_control_sort.size():
		currentCtrl = DataManager.war_control_sort[DataManager.war_control_sort_no]
	if currentCtrl >= 0:
		# 玩家回合结束，清空战场日志
		# TODO, 确认为什么回合结束事件的日志会被清除？
		# turn_control_end 为什么被调用两次？
		DataManager.reset_war_log()
	var actorIds = []
	for wa in wv.get_war_actors(false):
		actorIds.append(wa.actorId)
	wf.set_env("回合结束触发", actorIds)
	war_step_81()
	return

func turn_control_end_trigger():
	set_current_step(81)
	set_next_step(81)
	# 触发回合结束技能
	var wf = DataManager.get_current_war_fight()
	var actorIds = wf.get_env_int_array("回合结束触发")
	while not actorIds.empty():
		var actorId = actorIds.pop_front()
		wf.set_env("回合结束触发", actorIds)
		# 支持流程
		if SkillHelper.auto_trigger_skill(actorId, 20016, "turn_control_end_trigger"):
			return
	wf.unset_env("回合结束触发")
	war_step_82()
	return

func vstate_end():
	set_current_step(9)
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var msg = wv.get_leader_name() + " 军势行动结束"
	set_next_step(9, msg)
	SkillHelper.update_all_skill_buff("VSTATE_END")
	#势力回合结束事件
	wv.turn_end_event()
	war_step_21()
	return

func check_embattle():
	set_current_step(3)
	set_next_step(3, "军势布阵")
	# 总是优先 AI 布阵
	var wf = DataManager.get_current_war_fight()
	for wv in wf.war_vstates():
		if wv.embattled > 0:
			continue
		if wv.get_main_controlNo() < 0:
			war_step_30(wv)
			return
	# 检查是否发出探报
	if DataManager.game_mode2 == 0:
		for wv in wf.war_vstates():
			if wv.get_main_controlNo() >= 0:
				continue
			if wv.get_war_actors(false, true).empty():
				continue
			if wv.embattleReported == 0:
				war_step_31()
				return

	# 接下来是玩家布阵
	for wv in wf.war_vstates():
		if wv.embattled > 0:
			continue
		DataManager.set_env("布阵方", wv.id)
		#如果是剧情模式，玩家也是自动布阵
		if DataManager.game_mode2 != 0:
			FlowManager.add_flow("AI_auto_embattle")
			return
		#寻找未布阵的武将
		for wa in wv.get_war_actors(false, false):
			if wa.has_position() or wa.get_ext_variable("跳过布阵", 0) == 1:
				continue
			FlowManager.set_current_control_playerNo(wv.get_main_controlNo())
			FlowManager.add_flow("player_start")
			return

	# 双方布阵完毕，战争开始
	check_embattle_trigger()
	return

func check_embattle_trigger():
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false, true):
		if check_yijing(wa):
			return
	SkillHelper.update_all_skill_buff("EMBATTLED")
	# 仅第一次触发各方主将
	var leaderEmbattleTriggered = wf.get_env_int_array("布阵触发")
	for wv in wf.war_vstates():
		var leader = wv.get_leader()
		if leader == null or leader.disabled:
			continue
		if leader.actorId in leaderEmbattleTriggered:
			continue
		leaderEmbattleTriggered.append(leader.actorId)
		wf.set_env("布阵触发", leaderEmbattleTriggered)
		if SkillHelper.auto_trigger_skill(leader.actorId, 20019, "check_embattle_trigger"):
			return
	wf.unset_env("布阵触发")
	war_step_4()
	return

func back_to_war():
	var bf = DataManager.get_current_battle_fight()
	bf.done()
	# 如果是白刃试炼，直接回去
	# 这里用了特殊的 war_day，tricky
	# FIXME later
	var wf = DataManager.get_current_war_fight()
	if wf.date == 9527:
		LoadControl.end_script()
		FlowManager.add_flow("enable_add")
		FlowManager.add_flow("go_to_scene|res://scene/scene_demo/scene_demo_battle.tscn")
		return
	LoadControl.view_model_name = "战争-玩家-步骤"
	set_current_step(-1)
	set_next_step(-1)

	for id in [bf.get_attacker_id(), bf.get_defender_id()]:
		SkillHelper.auto_trigger_skill(id, 20008)
	
	var loser = bf.get_loser()
	var winner = null
	if loser != null:
		var loserActor = loser.actor()
		winner = loser.get_battle_enemy_war_actor()
		var winnerActor = winner.actor()
		var goldLine = winnerActor.get_equip_feature_max("低德搜刮")
		var gold = goldLine - winnerActor.get_moral()
		if gold > 0:
			var history = wf.get_env_array("低德搜刮")
			var key = "{0}|{1}".format([winner.actorId, loser.actorId])
			if not key in history:
				history.append(key)
				wf.set_env("低德搜刮", history)
				winner.war_vstate().change_gold(gold)
				var msg = "{0}趁势搜刮\n获得 {1} 两金".format([winner.get_name(), gold])
				winner.attach_free_dialog(msg, 2, 20000, -2)

		#防止0体结束白兵
		if not loserActor.is_status_dead():
			loserActor.set_hp(max(1, loserActor.get_hp()))

		set_env("战争.战败位置", {"x":loser.position.x,"y":loser.position.y})
		var posDic = DataManager.get_env_dict("后退位置")
		if not posDic.empty():
			#本身不在城门、太守府中才会后退(修改：城墙可以被击退)
			var blockCN = war_map.get_blockCN_by_position(loser.position);
			if not blockCN in ["太守府","城门"]:
				var position = Vector2(posDic["x"], posDic["y"])
				loser.move(position, false)
				#的卢效果处理
				if loserActor.get_equip_feature_max("战场跃马") > 0:
					#(德/2)%的概率触发跃马效果
					var rate = int(loserActor.get_moral() / 2)
					if loser.actorId == StaticManager.ACTOR_ID_LIUBEI:
						rate = max(80, rate)
					elif loser.actorId == StaticManager.ACTOR_ID_PANGTONG:
						rate = min(20, rate)
					if Global.get_rate_result(rate):
						DataManager.set_env("战争.跃马武将", loser.actorId)
			DataManager.unset_env("后退位置")

		for wa in [loser, winner]:
			if wa == null or wa.disabled:
				continue
			# 先检查装备
			var equipTriggered = false
			for item in wa.actor().get_equip_feature_all("战斗获得机动力"):
				var ap = int(item[1])
				if ap <= 0:
					continue
				wa.action_point += ap
				var msg = "因形用权，应变无穷\n（<{0}>效果\n（机动力 +{1}".format([
					item[0].name(), ap,
				])
				wa.attach_free_dialog(msg, 2)
				equipTriggered = true
				break
			if equipTriggered:
				continue
			# 再检查技能
			for srb in SkillRangeBuff.find_for_actor("战斗获得机动力", wa.actorId):
				if srb.effectTagVal <= 0:
					continue
				var ap = wa.battle_tactic_point
				if ap <= 0 or wa.action_point > 0:
					continue
				# 目前每日一次，光环不能用 CD，暂时用环境变量
				var key = "光环CD.{0}.{1}.{2}".format([
					srb.skillName, wa.actorId, wf.date
				])
				if wf.get_env_int(key) > 0:
					continue
				# 标记光环 CD
				wf.set_env(key, 1)
				wa.action_point += ap
				var msg = "因形用权，应变无穷\n（【{0}】效果\n（机动力 +{1}".format([
					srb.skillName, ap,
				])
				wa.attach_free_dialog(msg, 2)
				break

	if DataManager.endless_mode \
		and DataManager.is_challange_game() \
		and loser != null \
		and loser.initWvId == EndlessGame.PLAYER_VSTATEID:
		# 挑战赛判分
		# 判断是否阵亡
		if loser.wvId == EndlessGame.PLAYER_VSTATEID \
			and loser.actor().is_status_dead():
			DataManager.add_challange_game_score(-11)
		# 判断是否投降
		if loser.wvId != EndlessGame.PLAYER_VSTATEID \
			and winner != null \
			and winner.wvId != EndlessGame.PLAYER_VSTATEID:
			DataManager.add_challange_game_score(-50)

	wf.update_war_process()
	# 解除黑幕
	FlowManager.add_flow("enable_add")
	FlowManager.add_flow("back_to_war_induce_skill")
	return

func back_to_war_induce_skill():
	var wf = DataManager.get_current_war_fight()
	var key = "技能触发武将.20020"
	var bf = DataManager.get_current_battle_fight()
	var triggered = wf.get_env_int_array(key)
	for actorId in [bf.get_attacker_id(), bf.get_defender_id()]:
		if actorId in triggered:
			continue
		triggered.append(actorId)
		wf.set_env(key, triggered)
		if SkillHelper.auto_trigger_skill(actorId, 20020, "back_to_war_induce_skill"):
			return
	# 等待诱发技结束
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.wait:
		return
	wf.unset_env(key)
	FlowManager.add_flow("back_to_war_clear")
	FlowManager.add_flow("draw_actors")
	return

func back_to_war_clear():
	DataManager.unset_env("技能触发武将.20020")
	DataManager.clear_common_variable(["白兵"])
	DataManager.battle_units = []
	DataManager.battle_actors = []
	set_next_step(7)
	#防止连锁技能未执行完毕
	var st = SkillHelper.get_current_skill_trigger();
	if st != null:
		if st.next_flow == "":
			st.next_flow = "back_to_war_clear"
		set_current_step(7)
		return

	# 更新异常状态武将的士兵数
	var bf = DataManager.get_current_battle_fight()
	bf.war_report()

	var loser = bf.get_loser()
	if loser != null:
		var loserActor = loser.actor()
		if loserActor.is_status_captured() or loserActor.is_status_dead():
			loserActor.set_soldiers(0)
			# 检查豁免
			if try_release_loser(bf, loser):
				set_current_step(7)
				return
	FlowManager.add_flow("back_to_war_clear_trigger")
	set_current_step(7)
	return

func back_to_war_clear_trigger() -> void:
	if DataManager.war_control_sort.size() > DataManager.war_control_sort_no:
		var controlNo = DataManager.war_control_sort[DataManager.war_control_sort_no]
		if controlNo >= 0:
			FlowManager.set_current_control_playerNo(controlNo)
	var wf = DataManager.get_current_war_fight()
	var key = "技能触发武将.20050"
	var triggered = wf.get_env_int_array(key)
	var bf = DataManager.get_current_battle_fight()
	for actorId in [bf.get_attacker_id(), bf.get_defender_id()]:
		if actorId in triggered:
			continue
		triggered.append(actorId)
		wf.set_env(key, triggered)
		if SkillHelper.auto_trigger_skill(actorId, 20050, "back_to_war_clear_trigger"):
			return
	# 等待诱发技结束
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.wait:
		return
	wf.unset_env(key)
	FlowManager.add_flow("draw_actors")
	if bf.will_auto_finish_turn():
		FlowManager.add_flow("player_end")
		return
	FlowManager.add_flow("player_ready")
	return

func _decrease(proname:String, lossRate:int):
	var wf = DataManager.get_current_war_fight()
	var warCity = wf.target_city()
	var current = warCity.get_property(proname)
	var loss = int(current * lossRate / 10)
	warCity.add_city_property(proname, -loss)
	return

#等待准备阶段的技能
func before_turn_skill_trigger():
	set_current_step(5)
	set_next_step(5)
	var wf = DataManager.get_current_war_fight()
	var key = "技能触发武将.20013"
	var triggered = wf.get_env_int_array(key)
	var wv = wf.current_war_vstate()
	for wa in wv.get_war_actors(false):
		if wa.actorId in triggered:
			continue
		triggered.append(wa.actorId)
		wf.set_env(key, triggered)
		# 道术、神策附加暂时放在这里处理，摆脱技能依赖
		check_daoshu_appended(wa)
		check_shence_appended(wa)
		check_feijian_damage(wa)
		check_special_equipments(wa)
		if SkillHelper.auto_trigger_skill(wa.actorId, 20013, "before_turn_skill_trigger"):
			return
	wf.unset_env(key)
	war_step_6()
	return

# 等待准备阶段结束后的技能
# 注意：所有可能引发战斗的技能都应该在这一段触发
# 如【叫阵】等
# 以免打断正常的回合准备阶段技能
# 触发战斗会打断 turn_ready_skill_trigger 和其之后 step 7 的执行
# 但战斗结束回到 player_ready 的效果与 step 7 是一样的
# 所以放在这个阶段（step == 6）影响最小
func turn_ready_skill_trigger():
	set_current_step(6)
	set_next_step(6)
	var wf = DataManager.get_current_war_fight()
	var key = "技能触发武将.20028"
	var triggered = wf.get_env_int_array(key)
	var wv = wf.current_war_vstate()
	for wa in wv.get_war_actors():
		if wa.actorId in triggered:
			continue
		triggered.append(wa.actorId)
		wf.set_env(key, triggered)
		if SkillHelper.auto_trigger_skill(wa.actorId, 20028, "turn_ready_skill_trigger"):
			return
	wf.unset_env(key)
	war_step_7()
	return

# 切换行动方
func switch_side():
	var wf = DataManager.get_current_war_fight()
	if wf.switch_war_vstate():
		war_step_10()
		return
	war_step_1()
	return

func check_daoshu_appended(wa:War_Actor)->void:
	for found in wa.actor().get_equip_feature_all("道术附加"):
		if found[1] <= 0:
			continue
		var source = found[0].name()
		var otherDaoshuSkills = []
		var learnedNames = []
		for skill in SkillHelper.get_actor_skill_names(wa.actorId):
			learnedNames.append(skill)
		var defaults = SkillHelper.get_actor_default_skill_names(wa.actorId)
		for skillName in StaticManager.DAOSHU_SKILLS:
			if skillName in learnedNames:
				continue
			if skillName in defaults.values():
				if SkillHelper.add_actor_scene_skill(20000, wa.actorId, skillName, 1, -1, source):
					wa.attach_free_dialog("研读{0}\n对道术【{1}】有所领悟".format([source, skillName]), 1)
				return
			otherDaoshuSkills.append(skillName)
		if otherDaoshuSkills.empty():
			return
		otherDaoshuSkills.shuffle()
		var skillName = otherDaoshuSkills[0]
		if SkillHelper.add_actor_scene_skill(20000, wa.actorId, skillName, 1, -1, source):
			wa.attach_free_dialog("研读{0}\n对道术【{1}】有所领悟".format([source, skillName]), 1)
		return
	return

func check_shence_appended(wa:War_Actor)->void:
	if wa.actor().get_equip_feature_max("神策附加") <= 0:
		return
	# 简单实现，目前都以道具为准
	var source = wa.actor().get_jewelry().name()
	var skills = StaticManager.SHENCE_SKILLS.duplicate()
	skills.shuffle()
	var skillName = skills[0]
	if SkillHelper.add_actor_scene_skill(20000, wa.actorId, skillName, 1, -1, source, true):
		wa.attach_free_dialog("研读{0}\n领会上古神策【{1}】".format([source, skillName]), 1)
	return

func check_feijian_damage(wa:War_Actor)->void:
	var source = ""
	if wa.actor().get_equip_feature_max("飞剑伤害") <= 0:
		return
	var targets = wa.get_enemy_war_actors(true)
	if targets.empty():
		return
	targets.shuffle()
	var map = SceneManager.current_scene().war_map
	var target = null
	for enemy in targets:
		if enemy.get_soldiers() <= 0:
			continue
		var terrian = map.get_blockCN_by_position(enemy.position)
		if terrian in StaticManager.CITY_BLOCKS_CN:
			continue
		target = enemy
		break
	if target == null:
		return
	for equip in wa.actor().all_equips():
		for setting in equip.features():
			if not "飞剑伤害" in setting:
				continue
			var damage = Global.count_formula_number(setting["伤害"], wa.actorId, target.actorId)
			if damage <= 0:
				continue
			damage = min(target.get_soldiers(), damage)
			DataManager.damage_sodiers(wa.actorId, target.actorId, damage)
			var msg = "天师威能，剑出如意！\n（祭出飞剑，令{0}损兵 {1}".format([
				target.get_name(), damage
			])
			wa.attach_free_dialog(msg, 0)
			return
	return

func check_yijing(wa:War_Actor)->bool:
	var actor = wa.actor()
	if actor.get_side() == "道":
		# 已经激活了易经效果，判断装备
		if actor.get_equip_feature_max("阴阳归道") <= 0:
			# 卸下了易经？
			wa.set_war_side("")
			for info in SkillHelper.get_actor_scene_skills(wa.actorId, 20000):
				if Global.dic_val(info, "source", "") == "易经":
					SkillHelper.remove_scene_actor_skill(20000, wa.actorId, info["skill_name"])
		return false
	if actor.get_equip_feature_max("阴阳归道") <= 0:
		return false
	if wa.get_controlNo() < 0:
		return false
	if wa.get_ext_variable("阴阳归道", 0) > 0:
		return false
	if not actor.has_side():
		return false
	if not actor.get_side() in ["阴", "阳"]:
		return false
	DataManager.player_choose_actor = wa.actorId
	FlowManager.add_flow("player_yijing")
	return true

# 战争准备阶段，检查特殊装备的解锁，及特殊装备效果的触发
# 目前有掩心镜、游子弓
func check_special_equipments(wa:War_Actor) -> void:
	if wa.actorId == StaticManager.ACTOR_ID_LIUSHAN:
		var yxj = clEquip.equip(StaticManager.SUIT_ID_YANXINJING, "防具")
		var current = wa.actor().get_suit()
		if yxj.remaining() > 0 and current.id != yxj.id:
			var teammates = wa.get_teammates(false, true)
			if teammates.size() == 1 and teammates[0].actorId == StaticManager.ACTOR_ID_ZHAOYUN:
				var zy = teammates[0]
				var msg = "{0}，此战凶险\n此物予你，倍加小心\n看吾杀敌！".format([
					DataManager.get_actor_honored_title(wa.actorId, zy.actorId),
				])
				wa.attach_free_dialog(msg, 2, 20000, zy.actorId)
				msg = "{0}关爱，{1}铭记于心\n（{2}获得「{3}」".format([
					DataManager.get_actor_honored_title(zy.actorId, wa.actorId),
					DataManager.get_actor_self_title(wa.actorId),
					wa.get_name(), yxj.name(),
				])
				wa.attach_free_dialog(msg, 2)
				yxj.dec_count(1)
				wa.actor().set_equip(yxj)
				wa.vstate().add_stored_equipment(current)
	var wf = DataManager.get_current_war_fight()
	var key = "恢复禁用技能.{0}".format([wa.actorId])
	if wf.get_env_int(key) <= 0:
		for found in wa.actor().get_equip_feature_all("恢复禁用技能"):
			if int(found[1]) <= 0:
				continue
			var banned = SkillHelper.get_actor_banned_skill_names(20000, wa.actorId)
			if banned.empty():
				break
			var recovered = banned[randi() % banned.size()]
			if SkillHelper.recover_banned_actor_skill(wa.actorId, recovered):
				var msg = "浮云落日，归期何期 ……\n（「{0}」效果\n（恢复被禁用的技能【{1}】".format([
					found[0].name(), recovered
				])
				wa.attach_free_dialog(msg, 2)
			wf.set_env(key, 1)
			break
	return

func prepare_turn_skill_trigger()->void:
	set_current_step(1)
	set_next_step(1)
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	var actorIds = wf.get_env_int_array("回合开始触发")
	wv.turn_begin_event(actorIds)
	while not actorIds.empty():
		var actorId = actorIds.pop_front()
		wf.set_env("回合开始触发", actorIds)
		var wa = wv.get_war_actor(actorId)
		if wa == null:
			continue
		if SkillHelper.auto_trigger_skill(wa.actorId, 20001, "prepare_turn_skill_trigger"):
			return
	wf.unset_env("回合开始触发")
	war_step_2()
	return

func try_release_loser(bf:BattleFight, loser:War_Actor) -> bool:
	var winner = bf.get_winner()
	if winner == null:
		return false
	var leader = winner.get_leader()
	if leader == null:
		return false
	# 主将不豁免
	if loser.actorId == loser.get_main_actor_id():
		return false
	var releaser = null
	if leader.actor().get_equip_feature_max("豁免敌将") > 0:
		releaser = leader
	else:
		for wa in leader.get_teammates(false, true):
			if wa.actor().get_equip_feature_max("豁免敌将") <= 0:
				continue
			if wa.actor().get_equip_feature_max("二爷春秋") > 0:
				releaser = wa
				break
	if releaser == null:
		return false
	if releaser.get_controlNo() < 0:
		# AI 看心情
		if not Global.get_rate_result(30):
			return false
		var wf = DataManager.get_current_war_fight()
		wf.mercy_release(releaser, loser)
		return false
	# 玩家需要询问
	DataManager.set_env("战争.放归.主将", releaser.actorId)
	DataManager.set_env("战争.放归.目标", loser.actorId)
	FlowManager.add_flow("player_mercy")
	return true
