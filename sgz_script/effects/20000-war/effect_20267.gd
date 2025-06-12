extends "effect_20000.gd"

#盒酥主动技
#【盒酥】大战场，主动技。你的下一次计策消耗由你方主将承担，若不足，由你的机动力补齐，每回合1次

const EFFECT_ID = 20267
const PASSIVE_EFFECT_ID = 20268
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", true)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20267_start():
	var mainId = me.get_main_actor_id()
	var msg = "发动【盒酥】\n下次计策将由{0}\n协助提供机动力，可否？".format([
		ActorHelper.actor(mainId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20267_2():
	var mainId = me.get_main_actor_id()
	var msg = "{0}之意，吾已知之\n自有妙策".format([
		DataManager.get_actor_honored_title(mainId, me.actorId)
	])
	play_dialog(me.actorId, msg, 1, 2001)
	map.next_shrink_actors = [me.actorId, mainId]
	return

func effect_20267_3():
	var mainId = me.get_main_actor_id()
	ske.cost_war_cd(1)
	ske.set_war_skill_val(mainId, 1, PASSIVE_EFFECT_ID)
	map.next_shrink_actors = []
	FlowManager.add_flow("player_skill_end_trigger")
	return
