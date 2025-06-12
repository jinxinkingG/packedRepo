extends "effect_20000.gd"

#冢虎主动技
#【冢虎】大战场，主动技。你可以在<策书>、<完复>、<击免>中，选择一个，直到回合结束前，附加给自己，每回合限一次。选过的技能，不可再选，直到三个技能都被选过后，重置。

const EFFECT_ID = 20561
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const OPTIONAL_SKILLS = ["策书", "完复", "击免"]

# 发动主动技
func effect_20561_start() -> void:
	var msg = "选择【{0}】附加技能".format([
		ske.skill_name
	])
	var options = OPTIONAL_SKILLS.duplicate()
	for history in ske.get_war_skill_val_array():
		options.erase(history)
	if options.empty():
		ske.set_war_skill_val([])
		options = OPTIONAL_SKILLS.duplicate()
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.bind_top_menu(options, options, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_skill(FLOW_BASE + "_2")
	return

func effect_20561_2() -> void:
	var history = ske.get_war_skill_val_array()
	var skill = DataManager.get_env_str("目标项")
	ske.add_war_skill(actorId, skill, 1, true)
	history.append(skill)
	ske.cost_war_cd(1)
	ske.set_war_skill_val(history)
	ske.war_report()

	var msg = "临机制变，伏虎出渊！\n（解锁【{0}】".format([skill])
	if skill == "策书":
		# 获取策书附加
		var attached = me.get_tmp_variable("策书", "")
		if attached != "":
			msg += "\n（【策书】解锁【{0}】".format([attached])
	play_dialog(actorId, msg, 0, 2999)
	return
