extends "effect_20000.gd"

#蛮智效果
#【蛮智】大战场，限定技。发动后，三日内，你的智力临时提升X，X=当前兵力/160。

const EFFECT_ID = 20378
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20379

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return

func check_AI_perform_20000()->bool:
	# 第二天后随机发动
	var wf = DataManager.get_current_war_fight()
	if wf == null or wf.date <= 1:
		return false
	return Global.get_rate_result(50 + 10 * wf.date)

func effect_20378_AI_start():
	goto_step("2")
	return

func effect_20378_start():
	var msg = "发动【{0}】\n三日内「知」临时提升\n可否？".format([ske.skill_name])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20378_2():
	var wf = DataManager.get_current_war_fight()
	ske.cost_war_cd(99999)
	me.dic_other_variable["临知公式"] = "int(<WARDAY> < {0}) * <SOLDIERS> / 160".format([
		wf.date + 3
	])
	ske.append_message("<y{0}>的智力临时提升兵力/160".format([me.get_name()]))
	ske.war_report()
	var msg = "蛮神庇佑，众识为知！"
	if me.get_controlNo() < 0:
		msg += "\n（{0}发动【{1}】".format([me.get_name(), ske.skill_name])
	play_dialog(me.actorId, msg, 1, 2001)
	return
