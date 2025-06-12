extends "effect_20000.gd"

#神速主动技实现
#【神速】大战场,主动技。你可以指定一个，以你为中心，十字6格内的对方武将，对该武将发起攻击宣言，每日限1次。

const EFFECT_ID = 20243
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20243_start():
	var targets = []
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		var disv = wa.position - me.position
		if disv.x * disv.y != 0:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20243_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "发动{0}，奇袭{1}\n可否？".format([
		ske.skill_name, targetWA.get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20243_3():
	var msg = "吾亦可……所向无前！"
	if actorId == StaticManager.ACTOR_ID_XIAHOUYUAN:
		msg = "虎步天下，所向无前！"
	elif actorId == StaticManager.ACTOR_ID_WUYI:
		msg = "车骑高劲，所向无前！"
	elif actorId == StaticManager.ACTOR_ID_CAOCHUN:
		msg = "千里趋敌，所向无前！"
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20243_4():
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(1)
	start_battle_and_finish(actorId, targetId)
	return
