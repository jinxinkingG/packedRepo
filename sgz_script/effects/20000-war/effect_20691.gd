extends "effect_20000.gd"

# 崇义主动技
#【崇义】大战场，主动技。你方存在带“义”字技能的队友时，你可选择下列效果中的一个发动：①使其点数变为9；②使其获得1回合 {激励}，同时，若其战场技能处于冷却中（非限定技），技能冷却回合-5。每2回合限1次。

const EFFECT_ID = 20691
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const CD_REDUCE = 5

func effect_20691_start() -> void:
	var targetIds = []
	for targetId in get_teammate_targets(me, 999, true):
		var wa = DataManager.get_war_actor(targetId)
		for skillName in SkillHelper.get_actor_skill_names(targetId):
			if "义" in skillName:
				targetIds.append(targetId)
				break
	if targetIds.empty():
		var msg = "没有可以发动的目标"
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择【{0}】目标"
	wait_choose_actors(targetIds, msg, true)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20691_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var msg = "{0}当前点数为{1}\n选择【{2}】效果：".format([
		wa.get_name(), wa.poker_point, ske.skill_name,
	])
	var options = ["点数", "激励"]
	play_dialog(actorId, msg, 2, 2001, true, options)
	return

func on_view_model_2001() -> void:
	match wait_for_skill_option(FLOW_BASE + "_start"):
		0:
			goto_step("point")
		1:
			goto_step("encourage")
	return

func effect_20691_point() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	ske.change_actor_five_phases(targetId, wa.five_phases, 9)
	ske.cost_war_cd(2)
	ske.war_report()

	var msg = "义之所在，天可为鉴\n（{0}点数变为 {1}".format([
		wa.get_name(), wa.poker_point,
	])
	play_dialog(actorId, msg, 2, 2999)
	return

func effect_20691_encourage() -> void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)

	ske.set_war_buff(targetId, "激励", 1)
	ske.cost_war_cd(2)
	var ret = ske.reduce_actor_skill_cd(targetId, CD_REDUCE, [20000, 30000, 40000])
	ske.war_report()

	var cleared = []
	for skillName in ret:
		if ret[skillName] > 0:
			var clearedMsg = "【{0}】的冷却减为 {1}".format([skillName, ret[skillName]])
			me.attach_free_dialog(clearedMsg, 1, 20000, targetId)
		else:
			cleared.append("【" + skillName + "】")
	if cleared.size() > 0:
		if cleared.size() > 3:
			cleared[2] += "等{0}个技能".format([cleared.size()])
			cleared = cleared.slice(0, 2)
		var clearedMsg = "".join(cleared) + "的冷却被清除"
		me.attach_free_dialog(clearedMsg, 1, 20000, targetId)

	var msg = "义之所往，无所不利\n（{0}获得1回合 [激励]".format([
		wa.get_name(),
	])
	play_dialog(actorId, msg, 2, 2999)
	return
