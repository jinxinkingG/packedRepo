extends "effect_20000.gd"

#清俭主动技
#【清俭】大战场,主动技。每次你恢复机动力发生溢出，溢出的机动力转为等量的“俭”标记（至多X个，X=你的等级+2）。主动技，你可指定1名友军，获得你“俭”标记数量的机动力，之后你的“俭”清零。

const EFFECT_ID = 20209
const FLAG_NAME = "俭"
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation()
	return

func effect_20209_start():
	if not assert_flag_count(me.actorId, 20000, EFFECT_ID, FLAG_NAME, 1):
		return
	var targets = get_teammate_targets(me)
	var msg = "选择队友发动【{0}】".format([
		ske.skill_name,
	])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20209_2():
	var targetId = get_env_int("目标")
	var flag = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, me.actorId, FLAG_NAME)
	var msg = "将 {1}个[{0}]\n转化为{2}的机动力\n可否？".format([
		FLAG_NAME, flag, ActorHelper.actor(targetId).get_name()
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20209_3():
	var targetId = get_env_int("目标")
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, me.actorId, FLAG_NAME)
	ske.cost_skill_flags(20000, EFFECT_ID, FLAG_NAME, flags)
	ske.change_actor_ap(targetId, flags)
	ske.war_report()
	var msg = "把握战机，只在点滴之间\n（{0}机动力增加{1}".format([
		ActorHelper.actor(targetId).get_name(), flags,
	])
	play_dialog(me.actorId, msg, 2, 2002)
	return

# 锁定技部分
func on_trigger_20013() -> bool:
	var exceededKey = "战争.机动力溢出.{0}".format([me.actorId])
	var apOverflow = get_env_int(exceededKey)
	if apOverflow <= 0:
		return false
	var flag = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, me.actorId, FLAG_NAME)
	flag = min(actor.get_level() + 2, flag + apOverflow)
	SkillHelper.set_skill_flags(20000, EFFECT_ID, me.actorId, FLAG_NAME, flag)
	return false
