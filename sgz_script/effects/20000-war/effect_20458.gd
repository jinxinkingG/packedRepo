extends "effect_20000.gd"

#补成主动技，参见明败
#【补成】大战场，主动技。以回合内触发过你<明败>的一名队友为目标才能发动。以1金1兵的价格在战争城征兵，为之补充兵力。同一次战争中，此效果为队友征兵的数量合计不超过5000，且不可指定同一目标多次。

const EFFECT_ID = 20458
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const LIMIT = 5000
const MINGBAI_EFFECT_ID = 20383

func effect_20458_start()->void:
	if me.war_vstate().money <= 0:
		var msg = "已无足够军资"
		play_dialog(actorId, msg, 3, 2999)
		return
	var marked = ske.get_war_skill_val_int_array(MINGBAI_EFFECT_ID)
	var triggered = ske.get_war_skill_val_dic()
	var targets = []
	for targetId in marked:
		if str(targetId) in triggered:
			continue
		var limit = DataManager.get_actor_max_soldiers(targetId)
		if ActorHelper.actor(targetId).get_soldiers() >= limit:
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "没有可发动【{0}】的目标".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	var total = 0
	for k in triggered:
		total += triggered[k]
	if total >= LIMIT:
		var msg = "【{0}】士兵数已达上限".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	if not wait_choose_actors(targets, "请选择【{0}】目标"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20458_2()->void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var triggered = ske.get_war_skill_val_dic()
	var total = 0
	for k in triggered:
		total += triggered[k]
	SceneManager.hide_all_tool()
	var msg = "为{0}补兵，1兵需1金".format([
		targetWA.get_name()
	])
	var limit = DataManager.get_actor_max_soldiers(targetId)
	limit -= targetWA.get_soldiers()
	limit = min(limit, LIMIT - total)
	limit = min(limit, me.war_vstate().money)
	SceneManager.show_input_numbers(msg, ["士兵"], [limit])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_number_input(FLOW_BASE + "_3")
	return

func effect_20458_3()->void:
	var targetId = DataManager.get_env_int("目标")
	var soldiers = DataManager.get_env_int("数值")

	ske.cost_wv_gold(soldiers)
	ske.change_actor_soldiers(targetId, soldiers)
	var triggered = ske.get_war_skill_val_dic()
	triggered[str(targetId)] = soldiers
	ske.war_report()
	var msg = "{0}勇略足备，尚有胜算\n募兵{1}，稍补遗缺".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		soldiers,
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
