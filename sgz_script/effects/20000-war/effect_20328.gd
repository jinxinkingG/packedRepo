extends "effect_20000.gd"

#戡难：主动技；#主将 #对敌 #拼点
#【戡难】大战场，主将主动技。选择1名敌将才能发动：刷新双方五行并对比点数。若你的点数＞对方，本回合你方计策伤害变为150%；若你的点数＜对方，下回合对方计策伤害变为150%。每个回合限1次。可对城地形目标发动。

const EFFECT_ID = 20328
const PASSIVE_EFFECT_ID = 20329
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

func effect_20328_start():
	if not wait_choose_actors(get_enemy_targets(me, true)):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20328_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "是否对{2}使用{3}？\n({0}当前五行|点数:{1})".format([
		actor.get_name(), me.get_five_phases_str() + me.get_poker_point_str(),
		targetActor.get_name(), ske.skill_name
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20328_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	ske.cost_war_cd(1)
	me.refresh_poker_random()
	targetWA.refresh_poker_random()
	var mood = 2
	var msg = "扶危定倾，从来不易\n（{2}：{0}点={3}：{1}点\n无特殊效果"
	if me.poker_point < targetWA.poker_point:
		msg = "扶危定倾，从来不易\n（{2}：{0}点<{3}：{1}点\n{3}获得50%计策增伤"
		mood = 3
		ske.set_war_skill_val(targetId, 2, PASSIVE_EFFECT_ID)
	elif me.poker_point > targetWA.poker_point:
		msg = "扶危定倾，岂可无我\n（{2}：{0}点>{3}：{1}点\n{2}获得50%计策增伤"
		mood = 1
		ske.set_war_skill_val(me.actorId, 1, PASSIVE_EFFECT_ID)
	msg = msg.format([
		me.get_poker_point_str(),
		targetWA.get_poker_point_str(),
		me.get_name(), targetWA.get_name(),
	])
	play_dialog(me.actorId, msg, mood, 2009)
	return
