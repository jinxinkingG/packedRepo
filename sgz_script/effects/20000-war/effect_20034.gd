extends "effect_20000.gd"

#武守诱发技 #替代防御
#【武守】大战场，诱发技。你的队友被攻击时，你可以消耗5机动力发动。你替代之进入白刃战。每回合限制3次。

const EFFECT_ID = 20034
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId == me.actorId:
		# 自己没必要触发
		return false
	# 机动力不足，无法发动
	if me.action_point < COST_AP:
		return false
	return true

func effect_20034_AI_start():
	var bf = DataManager.get_current_battle_fight()
	if me.get_soldiers() <= bf.get_defender().get_soldiers() \
		and me.get_soldiers() < 1500:
		LoadControl.end_script()
		return
	goto_step("2")
	return

func effect_20034_start():
	if me.get_controlNo() < 0:
		# 托管时
		goto_step("AI_start")
		return
	var bf = DataManager.get_current_battle_fight()
	map.cursor.hide()
	var msg = "发动{0}\n需{1}点机动力\n可否？".format([ske.skill_name, COST_AP])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20034_2():
	var bf = DataManager.get_current_battle_fight()

	ske.cost_war_limited_times(3)
	ske.cost_ap(COST_AP)
	ske.replace_battle_defender(ske.actorId)
	ske.war_report()

	var msg = "{0}！我已等你多时！\n（{1}代替被攻击".format([
		DataManager.get_actor_naughty_title(bf.get_attacker_id(), me.actorId),
		me.get_name(),
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return
