extends "effect_20000.gd"

#养士主动技部分 #消耗标记 #回复兵力
#【养士】内政&大战场，锁定技。你执行「市集开发」时，获得X个[士]标记（X=提升人口数/10），[士]标记上限为3000。战争中你可通过主动发动此技能，消耗指定数量的[士]，获得对应数量的兵力，但不能超过兵力上限。

const EFFECT_ID = 20400
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const FLAG_SCENE_ID = 10000
const FLAG_ID = 10068
const FLAG_NAME = "士"

func effect_20400_start():
	if not assert_flag_count(me.actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, 1):
		return
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, me.actorId, FLAG_NAME)
	var limit = DataManager.get_actor_max_soldiers(me.actorId) - actor.get_soldiers()
	var msg = "使用多少「{0}」补充兵力？".format([FLAG_NAME])
	SceneManager.show_input_numbers(msg, [FLAG_NAME], [min(limit, flags)])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_number_input(FLOW_BASE + "_2")
	return

func effect_20400_2():
	var soldiers = get_env_int("数值")
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, me.actorId, FLAG_NAME)
	var limit = DataManager.get_actor_max_soldiers(me.actorId) - actor.get_soldiers()
	soldiers = min(flags, soldiers)
	soldiers = min(limit, soldiers)
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, soldiers)
	soldiers = ske.change_actor_soldiers(me.actorId, soldiers)
	set_env("数值", soldiers)
	
	var msg = "吾家勇士何在！"
	report_skill_result_message(ske, 2001, msg, 0, me.actorId)
	return

func on_view_model_2001():
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func effect_20400_3():
	report_skill_result_message(ske, 2001)
	return
