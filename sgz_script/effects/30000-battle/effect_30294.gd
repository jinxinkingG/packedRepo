extends "effect_30000.gd"

# 刺骑主动技 #持续性战术
#【刺骑】小战场，主动技。非城战可发动：你的骑兵可以攻击斜角，持续3回合。白刃战限1次。


const EFFECT_ID = 30294
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const BUFF = "刺骑"
const TURNS = 3

func effect_30294_start() -> void:
	ske.battle_cd(99999)
	ske.set_battle_buff(actorId, BUFF, TURNS)
	ske.battle_report()
	var msg = "策马如飞，枪出游龙！"
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30294_end()->void:
	tactic_end()
	return
