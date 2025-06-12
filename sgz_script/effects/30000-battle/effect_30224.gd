extends "effect_30000.gd"

#鼓锐主动技
#【鼓锐】小战场，主动技。你可以消耗至多15点战术值发动。本轮次中，你方所有单位对敌兵造成的伤害值+X点（X=发动该效果消耗的战术值）。每个大战场回合限1次。

const EFFECT_ID = 30224
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 30225
const TP_LIMIT = 15

func effect_30224_start():
	if me.battle_tactic_point <= 0:
		SceneManager.show_confirm_dialog("战术值不足", actorId, 3)
		LoadControl.set_view_model(2000)
		return
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	var x = min(15, me.battle_tactic_point)
	ske.set_battle_skill_val(x, 1, PASSIVE_EFFECT_ID)
	ske.battle_change_tactic_point(-x, me)
	ske.battle_report()

	var msg = "擂鼓！与我兵士壮军威！\n（本回合对敌兵伤害+{0}".format([x])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30224_end()->void:
	skill_end_clear(true)
	LoadControl.load_script("battle/player_tactic.gd")
	FlowManager.add_flow("tactic_end")
	return
