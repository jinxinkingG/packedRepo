extends "effect_30000.gd"

#扬威主动技实现
#【扬威】小战场，主动技。非城战才能发动：你往对面方向，跳到直线6格内，离你最远的空位。☆制作组“凤婶”提醒：可以从敌我双方士兵的脑袋上跳过去呀~。

const RANGE = 6

func effect_30093_start():
	var bu = me.battle_actor_unit()
	if bu == null:
		FlowManager.add_flow("tactic_end")
		return false
	ske.battle_cd(99999)
	ske.battle_unit_jump_forward(6, bu, true)
	ske.battle_report()
	SceneManager.show_confirm_dialog("谁能当我！", actorId, 0)
	LoadControl.set_view_model(2000)
	return true

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation("tactic_end")
	return
