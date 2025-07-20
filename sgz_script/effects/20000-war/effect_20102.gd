extends "effect_20000.gd"

#邀斗主将主动技
#【邀斗】大战场，主将主动技。选择敌我双方各1名武系或者统系且不在太守府的武将，消耗8机动力发动：视为敌方目标与我方目标进入白刃战。每个回合限1次。（“武，统，知，政”四属性，按顺序判断，武最高者属武系，统最高者为统系）

const EFFECT_ID = 20102
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 10

func effect_20102_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return

	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		var actor = ActorHelper.actor(wa.actorId)
		if not actor.is_male():
			#仅限男性
			continue
		var blockCN = map.get_blockCN_by_position(wa.position)
		if blockCN == "太守府":
			#不允许勾引敌军攻打太守府
			continue
		# 要求统武
		var maxAttr = max(actor.get_power(), actor.get_leadership())
		if max(actor.get_wisdom(), actor.get_politics()) > maxAttr:
			continue
		targets.append(wa.actorId)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_teammate_selected")
	return

func effect_20102_teammate_selected() -> void:
	DataManager.set_env("邀斗.队友", DataManager.get_env_int("目标"))
	var targets = []
	for targetId in get_enemy_targets(me, true):
		var wa = DataManager.get_war_actor(targetId)
		var actor = ActorHelper.actor(wa.actorId)
		if not actor.is_male():
			#仅限男性
			continue
		var blockCN = map.get_blockCN_by_position(wa.position)
		if blockCN == "太守府":
			#不允许勾引太守府敌军
			continue
		# 要求统武
		var maxAttr = max(actor.get_power(), actor.get_leadership())
		if max(actor.get_wisdom(), actor.get_politics()) > maxAttr:
			continue
		targets.append(wa.actorId)
	if not wait_choose_actors(targets, "选择对手发动【{0}】"):
		return
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_actor(FLOW_BASE + "_enemy_selected")
	return

func effect_20102_enemy_selected() -> void:
	DataManager.set_env("邀斗.对手", DataManager.get_env_int("目标"))
	var teammateId = DataManager.get_env_int("邀斗.队友")
	var enemyId = DataManager.get_env_int("邀斗.对手")

	var msg = "花费{0}机动力\n令{1}【{2}】{3}\n可否？".format([
		COST_AP, ActorHelper.actor(teammateId).get_name(),
		ske.skill_name, ActorHelper.actor(enemyId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2002, true)
	map.next_shrink_actors = [teammateId, enemyId]
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20102_confirmed() -> void:
	var teammateId = DataManager.get_env_int("邀斗.队友")
	var enemyId = DataManager.get_env_int("邀斗.对手")

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.war_report()

	map.cursor.hide()

	var msg = "{0}虽勇...\n恐非{1}敌手啊".format([
		DataManager.get_actor_honored_title(enemyId, actorId),
		DataManager.get_actor_honored_title(teammateId, actorId),
	])
	ske.play_war_animation("Strategy_Talking", 2003, enemyId, msg, 2)
	return

func on_view_model_2003() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_respond")
	return

func effect_20102_respond() -> void:
	var teammateId = DataManager.get_env_int("邀斗.队友")
	var enemyId = DataManager.get_env_int("邀斗.对手")

	var msg = "岂有此理，{0}拿命来！".format([
		DataManager.get_actor_naughty_title(teammateId, enemyId),
	])
	play_dialog(enemyId, msg, 0, 2004)
	return

func on_view_model_2004() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20102_fight() -> void:
	var teammateId = DataManager.get_env_int("邀斗.队友")
	var enemyId = DataManager.get_env_int("邀斗.对手")
	DataManager.clear_common_variable(["邀斗"])
	start_battle_and_finish(enemyId, teammateId)
	return
