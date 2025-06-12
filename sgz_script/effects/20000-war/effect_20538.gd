extends "effect_20000.gd"

#让马主动技 #解锁技能
#【让马】大战场，限定技。你可以指定一个己方其他武将。使其获得<备马>。同时禁用你的坐骑栏。

const EFFECT_ID = 20538
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "备马"

# 发动主动技
func effect_20538_start() -> void:
	var msg = "选择队友发动【{0}】"
	if not wait_choose_actors(get_teammate_targets(me), msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定队友
func effect_20538_2() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	var msg = "发动限定技【{0}】\n令{1}获得【{2}】\n可否？".format([
		ske.skill_name, targetActor.get_name(), TARGET_SKILL,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20538_3() -> void:
	var targetId = DataManager.get_env_int("目标")

	ske.cost_war_cd(99999)
	ske.add_war_skill(targetId, TARGET_SKILL, 99999, true)
	DataManager.disable_actor_equip_type(20000, actorId, "坐骑")
	var msg = "{0}的坐骑被禁用".format([actor.get_name()])
	ske.append_message(msg)
	ske.war_report()

	msg = "得{0}之助，当倍道而进！".format([
		DataManager.get_actor_honored_title(actorId, targetId),
	])
	report_skill_result_message(ske, 2002, msg, 0, targetId, false)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20538_4():
	report_skill_result_message(ske, 2002)
	return
