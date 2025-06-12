extends "effect_20000.gd"

#逆士主动技 #消耗标记 #回复兵力
#【逆士】内政&大战场,主将主动技。内政：每月你[死士]+300，上限3000；大战场：你可以指定任意你方武将，将任意数量的[死士]交给该武将（不超过其兵力上限）。

const EFFECT_ID = 20342
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const FLAG_SCENE_ID = 10000
const FLAG_ID = 10068
const FLAG_NAME = "士"

func effect_20342_start():
	if not assert_flag_count(me.actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, 1):
		return
	var targets = []
	var candidates = get_teammate_targets(me)
	candidates.append(me.actorId)
	for targetId in candidates:
		var targetActor = ActorHelper.actor(targetId)
		if DataManager.get_actor_max_soldiers(targetId) <= targetActor.get_soldiers():
			continue
		targets.append(targetId)
	
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20342_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, me.actorId, FLAG_NAME)
	var limit = DataManager.get_actor_max_soldiers(targetId) - targetActor.get_soldiers()
	var msg = "交予{0}多少死士？".format([ActorHelper.actor(targetId).get_name()])
	SceneManager.show_input_numbers(msg, ["死士"], [min(limit, flags)])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_number_input(FLOW_BASE + "_3")
	return

func effect_20342_3():
	var targetId = get_env_int("目标")
	var soldiers = get_env_int("数值")
	var targetActor = ActorHelper.actor(targetId)
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, me.actorId, FLAG_NAME)
	var limit = DataManager.get_actor_max_soldiers(targetId) - targetActor.get_soldiers()
	soldiers = min(flags, soldiers)
	soldiers = min(limit, soldiers)
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, soldiers)
	soldiers = ske.change_actor_soldiers(targetId, soldiers)
	set_env("数值", soldiers)
	
	var msg = "今其时也，夫何疑！\n{0}当速进".format([
		DataManager.get_actor_honored_title(targetId, ske.skill_actorId)
	])
	play_dialog(me.actorId, msg, 0, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20342_4():
	var targetId = get_env_int("目标")
	var soldiers = get_env_int("数值")
	var msg = "养士千日，当杀身以报！"
	report_skill_result_message(ske, 2003, msg, 0, targetId)
	return

func on_view_model_2003():
	wait_for_pending_message(FLOW_BASE + "_5")
	return

func effect_20342_5():
	report_skill_result_message(ske, 2003)
	return
