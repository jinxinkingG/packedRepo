extends "effect_20000.gd"

#奇策主动技
#【奇策】大战场，主动技。若你的机动力不为0，你可以用剩余的全部机动力施展任一计策（全计策列表无限制）。每回合限1次。

const EFFECT_ID = 20021
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 默认限制一次，如果同时有谋主，则升级为3
func get_times_limit()->int:
	if SkillHelper.actor_has_skills(actorId, ["谋主"]):
		return 3
	return 1

func on_view_model_121():
	#选择用计目标
	# 这个地方实际上介入了计策主流程
	# 会与主流程的 121 抢响应
	# 不太好，但暂时没办法干掉
	# TODO
	if not Global.is_action_pressed_BY():
		return
	if not SceneManager.dialog_msg_complete(false):
		return
	LoadControl.set_view_model(-1)
	goto_step("2")
	return

func check_AI_perform_20000()->bool:
	if me.action_point > 6:
		return false
	if me.action_point <= 0:
		return false
	return true

func effect_20021_AI_start()->void:
	if me.action_point <= 0:
		skill_end_clear()
		LoadControl.add_flow("AI_before_ready")
		return
	var was = Global.load_script("war/AI/War_AI_Strategy.gd")
	# 先尝试发动劫火
	var se = DataManager.new_stratagem_execution(actorId, "劫火", ske.skill_name)
	var targetId = -1
	var targetWisdom = 99
	for id in se.get_available_targets()[0]:
		var a = ActorHelper.actor(id)
		if a.get_wisdom() < targetWisdom:
			targetId = a.actorId
			targetWisdom = a.get_wisdom()
	if targetId < 0:
		var checked = was.best_use_strategy(actorId)
		if checked.empty():
			ske.cost_war_cd(1)
			FlowManager.add_flow("AI_before_ready")
			return
		targetId = int(checked["目标"])
		if targetId < 0:
			ske.cost_war_cd(1)
			FlowManager.add_flow("AI_before_ready")
			return
		var scheme = str(checked["计策名"])
		se = DataManager.new_stratagem_execution(actorId, scheme, ske.skill_name)
	se.set_target(targetId)
	var msg = se.get_message() + "\n（{0}发动【{1}】".format([
		actor.get_name(), ske.skill_name,
	])
	SceneManager.play_war_animation(se.get_animation(), targetId, "", msg, actorId, 2)
	LoadControl.set_view_model(3000)
	return

func on_view_model_3000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_2")
	return

func effect_20021_AI_2()->void:
	var se = DataManager.get_current_stratagem_execution()
	se.perform_to_targets([se.targetId])
	# 模拟消耗
	on_trigger_20018()
	goto_step("AI_3")
	return

func effect_20021_AI_3()->void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 3001)
	return

func on_view_model_3001()->void:
	wait_for_pending_message(FLOW_BASE + "_AI_2")
	return

func effect_20021_start():
	if not assert_action_point(me.actorId, 1):
		return
	var msg = "消耗全部机动力\n发动任意计策\n可否？"
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

#展示计策列表
func effect_20021_2():
	var ap = me.action_point
	var items = []
	var values = []
	for scheme in me.get_stratagems(99, 8):
		items.append("{0}({1})".format([
			scheme.name, ap
		]))
		values.append(scheme.name)

	SceneManager.hide_all_tool()
	var msg = "使用何种计策？\n(当前机动力:{0})\n【{1}】解锁全部计策".format([
		ap, ske.skill_name
	])
	set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	bind_menu_items(items, values, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	#计策列表
	wait_for_choose_item(FLOW_BASE + "_3")
	return

func effect_20021_3():
	var stratagem = get_env_str("目标项")
	start_scheme(stratagem)
	return

# 20018 时回调，如果计策由奇策发起，则扣除所有机动力
func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.skill != ske.skill_name:
		# 不是由奇策发起的计策，忽略
		return false
	me.action_point += se.cost
	se.cost = me.action_point
	ske.cost_ap(me.action_point)
	ske.cost_war_limited_times(get_times_limit())
	return false
