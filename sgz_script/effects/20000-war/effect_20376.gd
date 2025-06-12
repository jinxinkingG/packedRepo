extends "effect_20000.gd"

#让贤主动技部分
#【让贤】大战场，主将限定技。你为防守方的场合，指定1名队友为目标发动。直到战争结束前：每次己方回合结束时，自动消耗你的兵力，最大限度的为该武将补充兵力。（不超过其兵力上限）

const EFFECT_ID = 20376
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const PASSIVE_EFFECT_ID = 20377

func effect_20376_start():
	if not wait_choose_actors(get_teammate_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20376_2():
	var targetId = get_env_int("目标")
	ske.cost_war_cd(99999)
	ske.set_war_skill_val(targetId, 99999, PASSIVE_EFFECT_ID)
	var msg = "已将支援目标设定为{0}".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2999)
	map.next_shrink_actors = [targetId, me.actorId]
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
