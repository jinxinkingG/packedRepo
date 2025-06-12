extends "effect_20000.gd"

#先识主动技
#【先识】大战场，主动技。选择1名敌将，之后指定其计策列表的1个伤兵计策为目标，消耗你10点机动力才能发动。下次对方回合内，若你的队友被目标敌将使用目标计策，那名队友受到的兵力伤害减少一半。每回合限指定1次。

const EFFECT_ID = 20470
const PASSIVE_EFFECT_ID = 20471
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 10

func effect_20470_start():
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = get_enemy_targets(me)
	var msg = "选择敌方发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20470_2():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var schemes = targetWA.get_stratagems()
	if schemes.empty():
		var msg = "{0}并无可用计策".format([targetWA.get_name()])
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "选择哪个计策？"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	var items = []
	for scheme in schemes:
		items.append(scheme.name)
	bind_menu_items(items, items, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_item(FLOW_BASE + "_3")
	return

func effect_20470_3():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var schemeName = DataManager.get_env_str("目标项")
	var msg = "消耗{0}机动力发动【{1}】\n预防{2}的{3}\n可否？".format([
		COST_AP, ske.skill_name, targetWA.get_name(), schemeName,
	])
	play_dialog(me.actorId, msg, 2, 2002, true)
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func effect_20470_4():
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var schemeName = DataManager.get_env_str("目标项")

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	var turns = 1
	if me.side() == "防守方":
		turns = 2
	ske.set_war_skill_val(schemeName, turns, PASSIVE_EFFECT_ID, targetId)

	var msg = "{0}惯用{1}\n吾岂不知，只须稍作防备".format([
		targetWA.get_name(), schemeName,
	])
	ske.war_report()
	play_dialog(me.actorId, msg, 2, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
