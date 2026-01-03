extends "effect_20000.gd"

# 赠药主动技
#【赠药】主动技。消耗50金。指定对方一个对方体力未满的武将（无城地形限制），你令其回满体力。并对其附加一回合 {围困} 。每回合限2次。

const EFFECT_ID = 20700
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_GOLD = 50
const BUFF_NAME = "围困"

func effect_20700_start() -> void:
	if not assert_wv_gold(COST_GOLD):
		return
	var targetIds = []
	for targetId in get_enemy_targets(me, true):
		if ActorHelper.actor(targetId).is_injured():
			targetIds.append(targetId)
	if not wait_choose_actors(targetIds):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20700_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗{0}金\n对{1}发动【{2}】\n可否？".format([
		COST_GOLD, targetActor.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20700_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	ske.cost_war_limited_times(2)
	ske.cost_wv_gold(COST_GOLD)
	ske.change_actor_hp(targetId, targetActor.get_max_hp() - targetActor.get_hp())
	ske.set_war_buff(targetId, BUFF_NAME, 2)
	ske.war_report()

	var msg = "闻君有疾，良药相赠\n（消耗{0}金 -> {1}\n（{2}体力回满".format([
		COST_GOLD, me.war_vstate().money,
		targetActor.get_name(), BUFF_NAME,
	])
	play_dialog(actorId, msg, 2, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_response")
	return

func effect_20700_response() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var msg = "古君子之风，不过如是\n奈何为敌？\n（附加两回合 [{0}]".format([
		BUFF_NAME,
	])
	play_dialog(targetId, msg, 2, 2999)
	return
