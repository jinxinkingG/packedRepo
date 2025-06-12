extends "effect_30000.gd"

#狂搦主动技
#【狂搦】小战场，主动技。你每使用一次，战术值-3，视为使用一次“挑衅”，每次白刃战限3次

const EFFECT_ID = 30251
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# AI 暂不发动

func effect_30251_start():
	if me.battle_tactic_point < 3:
		var msg = "战术值不足\n无法发动【{0}】".format([
			ske.skill_name,
		])
		SceneManager.show_confirm_dialog(msg, actorId, 0)
		LoadControl.set_view_model(2000)
		return
	var times = ske.battle_get_skill_val_int() + 1
	if times >= 3:
		ske.battle_cd(99999)
	ske.battle_set_skill_val(times)
	ske.battle_change_tactic_point(-3)
	ske.battle_report()
	DataManager.set_env("结果", 1)
	var rate = me.get_battle_enemy_war_actor().get_solo_accept_rate(me)
	if not Global.get_rate_result(rate):
		DataManager.set_env("结果", 0)
	LoadControl.end_script()
	DataManager.set_env("当前武将", actorId)
	FlowManager.add_flow("load_script|battle/player_tactic.gd");
	FlowManager.add_flow("tactic_impact_1")
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30251_end():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
