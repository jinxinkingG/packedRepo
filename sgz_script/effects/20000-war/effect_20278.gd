extends "effect_20000.gd"

#激励主动技
#【激励】大战场，主动技。若队友的战场技能处于冷却中（非限定技），你可以对其发动，消耗10点机动力，重置其技能冷却时间。每4日限一次。

const EFFECT_ID = 20278
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 10
const COST_CD = 4
const CD_REDUCE = 5

func effect_20278_start():
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = []
	var teammates = get_teammate_targets(me)
	for key in DataManager.skill_cd.keys():
		# 忽略限定技或永久禁用的技能
		if DataManager.skill_cd[key] >= 90000:
			continue
		var pieces = str(key).split("/")
		var sceneId = int(pieces[0])
		#var effectId = int(pieces[1])
		var targetId = int(pieces[2])
		if not targetId in teammates:
			continue
		if sceneId < 20000:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20278_2():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗{0}机动力\n对{1}发动【{2}】，减少其战场技能冷却，可否？".format([
		COST_AP, targetActor.get_name(), ske.skill_name
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20278_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(COST_CD)
	ske.cost_ap(COST_AP, true)
	var ret = ske.reduce_actor_skill_cd(targetId, CD_REDUCE, [20000, 30000, 40000])
	ske.war_report()
	
	var msg = "我助{0}一臂之力\n定能摧破敌胆！".format([
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	me.attach_free_dialog(msg, 2)
	var cleared = []
	for skillName in ret:
		if ret[skillName] > 0:
			msg = "【{0}】的冷却减为 {1}".format([skillName, ret[skillName]])
			me.attach_free_dialog(msg, 1, 20000, targetId)
		else:
			cleared.append("【" + skillName + "】")
	if cleared.size() > 0:
		if cleared.size() > 3:
			cleared[2] += "等{0}个技能".format([cleared.size()])
			cleared = cleared.slice(0, 2)
		msg = "".join(cleared) + "的冷却被清除"
		me.attach_free_dialog(msg, 1, 20000, targetId)
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
