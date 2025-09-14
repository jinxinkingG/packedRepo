extends "effect_20000.gd"

# 冒进主动技 #施加状态
#【冒进】大战场，主动技。你可以不消耗机动力，移动3步，并获得1回合 {围困} 状态，每2回合限1次。

const EFFECT_ID = 20643
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20644

func effect_20643_start() -> void:
	var msg = """发动【{0}】，进入围困状态\n可不消耗机动力移动3步\n可否？""".format([ske.skill_name])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20643_confirmed() -> void:
	var msg = "建功自当争先\n岂有后顾之理！"
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_go")

func effect_20643_go():

	ske.cost_war_cd(2)
	ske.set_war_buff(actorId, "围困", 1)
	# 仅记录日志
	ske.war_report()

	ske.set_war_skill_val([3, 0], 1, PASSIVE_EFFECT_ID)
	LoadControl.end_script()
	FlowManager.add_flow("load_script|war/player_move.gd")
	FlowManager.add_flow("actor_move_start")
	return
