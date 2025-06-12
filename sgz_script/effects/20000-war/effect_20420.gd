extends "effect_20000.gd"

#计袭主动技部分
#【计袭】大战场,主动技&诱发技。你使用伤兵类计策命中的场合，你可以发动：你方武力最高的将领与该受计者进入白刃战，且在此次白刃战中，那名敌将技能失效。每个回合限1次。若本次战争未触发过，你可以主动发动，修改计袭的发起武将。

const EFFECT_ID = 20420
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20141

func effect_20420_start():
	if ske.get_war_skill_val_int(PASSIVE_EFFECT_ID) > 0:
		var msg = "【{0}】已经发动过\n无法更改计袭武将".format([
			ske.skill_name
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var targets = get_teammate_targets(me)
	var current = ske.get_war_skill_val_int(-1, -1, -1)
	var msg = "选定【{0}】武将".format([ske.skill_name])
	if current in targets:
		targets.erase(current)
		targets.insert(0, current)
	if current >= 0:
		msg += "（当前：{0}）".format([
			ActorHelper.actor(current).get_name()
		])
	if not wait_choose_actors(targets, msg):
		return
	if current >= 0:
		var targetWA = DataManager.get_war_actor(current)
		map.show_color_block_by_position([targetWA.position])
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func effect_20420_2():
	var targetId = DataManager.get_env_int("目标")
	ske.set_war_skill_val(targetId, 99999)
	var msg = "已将【{0}】武将设定为{1}".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	map.show_color_block_by_position([])
	play_dialog(me.actorId, msg, 2, 2999)
	return
