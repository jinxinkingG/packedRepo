extends "effect_20000.gd"

#援护主动技部分
#【援护】大战场，诱发技。你所指定守护的队友(默认为主将)被攻击的场合，你可消耗2点机动力发动：你替代之被攻击。同时，你可以通过主动发动本技能，更改守护的目标。

const EFFECT_ID = 20040
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const PASSIVE_EFFECT_ID = 20036

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return

func effect_20040_start():
	var targets = get_teammate_targets(me)
	var targetId = _get_marked_actor_id()
	var msg = "选定【{0}】目标".format([ske.skill_name])
	if targetId >= 0:
		targets.erase(targetId)
		targets.insert(0, targetId)
		msg += "（当前：{0}".format([
			ActorHelper.actor(targetId).get_name()
		])
	if not wait_choose_actors(targets, msg):
		return
	if targetId >= 0:
		var targetWA = DataManager.get_war_actor(targetId)
		map.show_color_block_by_position([targetWA.position])
	LoadControl.set_view_model(2000)
	return

func effect_20040_2():
	var targetId = get_env_int("目标")
	ske.set_war_skill_val(targetId, 99999, PASSIVE_EFFECT_ID)
	var msg = "已将【{0}】目标设定为{1}".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	map.show_color_block_by_position([])
	play_dialog(me.actorId, msg, 2, 2001)
	return

func _get_marked_actor_id()->int:
	var targetId = ske.get_war_skill_val_int(PASSIVE_EFFECT_ID, -1, -1)
	if targetId < 0:
		targetId = me.get_main_actor_id()
	var wa = DataManager.get_war_actor(targetId)
	if wa == null or wa.disabled or not wa.has_position():
		return me.get_main_actor_id()
	if not me.is_teammate(wa):
		return me.get_main_actor_id()
	return targetId
