extends "effect_20000.gd"

#涌谋主动技部分
#【涌谋】大战场，主动技。选择1名敌将为目标，消耗你20个[备]标记才能发动。直到回合结束前，目标“知”视为-10；若目标被用计，则其“知”在计策结束时恢复。每回合限3次。

const EFFECT_ID = 20473
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20474
const FLAG_SCENE_ID = 10000
const FLAG_ID = 10025
const FLAG_NAME = "备"
const COST_FLAGS = 20
const REDUCE_WISDOM = 10

# 发动主动技
func effect_20473_start():
	if not assert_flag_count(actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAGS):
		return
	var targets = get_enemy_targets(me)
	var marked = ske.get_war_skill_val_int_array(PASSIVE_EFFECT_ID)
	for targetId in marked:
		targets.erase(targetId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func effect_20473_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "消耗{0}「{1}」\n令{2}的知暂时 -{3}\n可否？".format([
		COST_FLAGS, FLAG_NAME, targetWA.get_name(), REDUCE_WISDOM,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20473_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	
	ske.cost_war_limited_times(3)
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAGS)
	var marked = ske.get_war_skill_val_int_array(PASSIVE_EFFECT_ID)
	marked.erase(targetId)
	marked.append(targetId)
	ske.set_war_skill_val(marked, 99999, PASSIVE_EFFECT_ID)
	ske.change_war_wisdom(targetId, -REDUCE_WISDOM)
	ske.war_report()
	var msg = "{0}心志不坚，可扰其知略\n（{1}知临时 -{2}".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		targetWA.get_name(), REDUCE_WISDOM,
	])
	play_dialog(actorId, msg, 2, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
