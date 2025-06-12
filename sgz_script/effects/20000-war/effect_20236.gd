extends "effect_20000.gd"

#刮骨主动技 #消耗标记 #解除状态 #施加状态
#【刮骨】大战场,主动技。你可以指定一个你方体力＞50的武将，消耗1个[药]和1点机动力，使其体力-20，并消除该武将所有负面状态，该武将获得4回合 {愈合} 效果。然后你的经验+100。

const EFFECT_ID = 20236
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_SCENE_ID = 10000
const FLAG_ID = 10003
const FLAG_NAME = "药"
const COST_FLAG = 1
const COST_AP = 1

const BASIC_HP = 50
const COST_HP = 20
const EXP_GAIN = 100

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func effect_20236_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	if not assert_flag_count(me.actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAG):
		return
	var targets = []
	for targetId in get_teammate_targets(me):
		if ActorHelper.actor(targetId).get_hp() <= BASIC_HP:
			continue
		var wa = DataManager.get_war_actor(targetId)
		if not wa.is_war_debuffed():
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20236_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "清除{0}的负面状态\n暂时扣减其{1}体\n可否？".format([
		targetWA.get_name(), COST_HP
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20236_3():
	var targetId = get_env_int("目标")

	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAG)
	ske.change_actor_hp(targetId, -COST_HP)
	ske.change_actor_exp(ske.skill_actorId, EXP_GAIN)
	var wa = DataManager.get_war_actor(targetId)
	for buff in wa.get_war_debuffs():
		ske.remove_war_buff(targetId, buff)
	ske.set_war_buff(targetId, "愈合", 4)
	var msg = "情非得已，刮骨疗毒\n{0}，且忍一忍".format([
		DataManager.get_actor_honored_title(targetId, ske.skill_actorId)
	])
	report_skill_result_message(ske, 2002, msg, 1)
	return

func effect_20236_4():
	report_skill_result_message(ske, 2002)
	return
