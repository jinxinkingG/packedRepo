extends "effect_20000.gd"

# 承诏限定技 #TODO 未完成
#【承诏】大战场，限定技。由你方开始，所有势力依次选择麾下一名可被沉默的武将，沉默其2回合，之后重复此步骤，直到「其中一方不存在可选目标」或「该效果沉默人数达到X」为止(X=你的点数)。

const EFFECT_ID = 20606
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20606_start() -> void:
	if me.poker_point == 0:
		var msg = "点数为 0\n不可发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "发动限定技【{0}】\n敌我将依次沉默共{1}人\n可否？".format([
		ske.skill_name, me.poker_point,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20606_confirmed() -> void:
	var msg = "衣带诏在此\n诸公师出无名\n何以兴汉！"
	ske.cost_war_cd(99999)
	ske.set_war_skill_val(me.poker_point)
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_me")
	return

func effect_20606_me() -> void:
	var times = ske.get_war_skill_val_int()
	if times <= 0:
		goto_step("end")
		return
	var targetIds = []
	for wa in me.get_teammates(false, true):
		if wa.get_buff_label_turn(["沉默"]) > 0:
			continue
		targetIds.append(wa.actorId)
	if targetIds.empty():
		goto_step("end")
		return
	var msg = "选择队友"
	wait_choose_actors(targetIds, msg, true)
	LoadControl.set_view_model(2002)
	return

func on_view_model_2002() -> void:
	wait_for_choose_actor(FLOW_BASE + "_me_selected", true, false)
	return

func effect_20606_me_selected() -> void:
	var times = ske.get_war_skill_val_int()
	ske.set_war_skill_val(times - 1)
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	ske.set_war_buff(wa.actorId, "沉默", 2)
	var msg = "… …\n（{0}不能答\n（沉默2回合".format([
		wa.get_name()
	])
	play_dialog(wa.actorId, msg, 3, 2003)
	return

func on_view_model_2003() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_enemy")
	return

func effect_20606_enemy() -> void:
	var times = ske.get_war_skill_val_int()
	if times <= 0:
		goto_step("end")
		return
	var targetIds = []
	for wa in me.get_enemy_war_actors(true):
		if wa.get_buff_label_turn(["沉默"]) > 0:
			continue
		targetIds.append(wa.actorId)
	if targetIds.empty():
		goto_step("end")
		return
	# 敌方（AI）随机选择
	targetIds.shuffle()
	var targetId = targetIds[0]
	ske.set_war_skill_val(times - 1)
	var wa = DataManager.get_war_actor(targetId)
	ske.set_war_buff(wa.actorId, "沉默", 2)
	var msg = "… …\n（{0}不能答\n（沉默2回合".format([
		wa.get_name()
	])
	play_dialog(wa.actorId, msg, 3, 2004)
	return

func on_view_model_2004() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_me")
	return

func effect_20606_end() -> void:
	ske.war_report()
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
