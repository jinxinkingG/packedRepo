extends "effect_20000.gd"

#完复主动技
#【完复】大战场,主动技。消耗15点机动力+100金，指定一个己方武将，令其回复全部体力，每2回合限1次。

const EFFECT_ID = 20559
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 15
const COST_GOLD = 100

func effect_20559_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var wv = me.war_vstate()
	if wv.money < COST_GOLD:
		var msg = "金不足，需 >= {0}".format([COST_GOLD])
		play_dialog(actorId, msg, 3, 2999)
		return
	var targets = []
	for targetId in get_teammate_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		if not targetActor.is_injured():
			continue
		targets.append(targetId)
	if actor.is_injured():
		targets.append(actorId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20559_2() -> void:
	var targetId = DataManager.get_env_int("目标")
	
	var msg = "消耗 {0} 机动力和 {1} 金\n对{3}发动【{2}】\n可否？".format([
		COST_AP, COST_GOLD, ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20559_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var hp = int(targetActor.get_hp())
	targetActor.set_hp(hp)
	var maxHP = targetActor.get_max_hp()

	ske.cost_ap(COST_AP, true)
	ske.cost_wv_gold(COST_GOLD)
	ske.cost_war_cd(2)
	ske.change_actor_hp(targetId, maxHP - hp)
	ske.war_report()
	var msg = "息甲养锐，九脉回春\n（{0}体力完全恢复".format([
		targetActor.get_name(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return
