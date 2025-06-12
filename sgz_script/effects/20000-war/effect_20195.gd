extends "effect_20000.gd"

#制衡主动技
#【制衡】大战场,主动技。你可选择己方你以外的两名武将，交换其机动力。每回合限1次。

const EFFECT_ID = 20195
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_choose_actor(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_yesno(FLOW_BASE + "_4")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

# 发动主动技
func effect_20195_start():
	var targets = get_teammate_targets(me)
	if targets.size() < 2:
		var msg = "没有合适的目标\n无法发动【{0}】".format([
			ske.skill_name
		])
		play_dialog(me.actorId, msg, 2, 2009)
		return

	var msg = "选择一名友军\n发动【{0}】".format([
		ske.skill_name
	])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20195_2():
	var selected = get_env_int("目标")
	set_env("战争.制衡目标一", selected)

	var targets = get_teammate_targets(me)
	targets.erase(selected)
	var msg = "选择第二名友军\n发动【{0}】".format([
		ske.skill_name
	])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2001)
	return

func effect_20195_3():
	var first = get_env_int("战争.制衡目标一")
	var second = get_env_int("目标")
	set_env("战争.制衡目标二", second)
	var firstWA = DataManager.get_war_actor(first)
	var secondWA = DataManager.get_war_actor(second)
	if firstWA.action_point == secondWA.action_point:
		var msg = "{1}与{2}机动力相同\n何须【{0}】？".format([
			ske.skill_name, firstWA.get_name(), secondWA.get_name(),
		])
		play_dialog(me.actorId, msg, 2, 2009)
		return
		
	var msg = "【{0}】{1}与{2}\n交换机动力（{3}<->{4}）\n可否？".format([
		ske.skill_name, firstWA.get_name(), secondWA.get_name(),
		firstWA.action_point, secondWA.action_point,
	])
	play_dialog(me.actorId, msg, 2, 2002, true)
	return

func effect_20195_4():
	var first = get_env_int("战争.制衡目标一")
	var second = get_env_int("战争.制衡目标二")
	var firstWA = DataManager.get_war_actor(first)
	var secondWA = DataManager.get_war_actor(second)

	ske.cost_war_cd(1)
	var ap1 = firstWA.action_point
	var ap2 = secondWA.action_point
	ske.change_actor_ap(first, -ap1)
	ske.change_actor_ap(first, ap2)
	ske.change_actor_ap(second, -ap2)
	ske.change_actor_ap(second, ap1)
	ske.war_report()

	var msg = "人主之道，静退以为宝"
	play_dialog(me.actorId, msg, 2, 2009)
	return
