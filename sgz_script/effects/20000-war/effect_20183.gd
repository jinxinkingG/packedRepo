extends "effect_20000.gd"

#龙吟主动技 #施加状态
#【龙吟】大战场,限定技。你体力＞50时，可以发动：你的体力减半，对方所有武将获得1回合“定止”状态。

const EFFECT_ID = 20183
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const MIN_HP = 51
const STOP_ROUND = 1

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation()
	return

# 发动主动技
func effect_20183_start():
	if not assert_min_hp(me.actorId, MIN_HP):
		return

	var msg = "体力减半，发动【龙吟】\n定止敌方全军\n可否？"
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20183_2():
	var ske = SkillHelper.read_skill_effectinfo()
	var msg = "幼龙之怒，群小静听！"
	play_dialog(me.actorId, msg, 0, 2001)
	return

func effect_20183_3():
	ske.cost_war_cd(99999)
	ske.change_actor_hp(me.actorId, -int(actor.get_hp() / 2))
	var targets = []
	var targetNames = ""
	for targetId in get_enemy_targets(me, true, 999):
		var wa = DataManager.get_war_actor(targetId)
		if wa.get_buff("定止")["回合数"] > 0:
			continue
		ske.set_war_buff(targetId, "定止", STOP_ROUND)
		if targets.empty():
			map.set_cursor_location(wa.position, true)
			targetNames = wa.get_name()
		targets.append(wa.actorId)
	# 仅记录日志
	ske.war_report()
	if targets.size() > 1:
		targetNames += "等人"
	map.show_can_choose_actors(targets)
	var msg = "{0}发动【{1}】\n{2}被定止".format([
		actor.get_name(), ske.skill_name, targetNames
	])
	play_dialog(-1, msg, 2, 2002)
	return
