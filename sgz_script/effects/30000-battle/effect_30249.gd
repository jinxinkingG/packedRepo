extends "effect_30000.gd"

#巧转主动技
#【巧转】小战场，主动技。将你士气的附加值，转化为等量的战术值。每次白刃战限1次。

const EFFECT_ID = 30249
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# AI 暂不发动

func effect_30249_start():
	var extraMorale = me.battle_morale_patched
	if extraMorale <= 0:
		var msg = "士气不足\n无法发动【{0}】".format([
			ske.skill_name,
		])
		SceneManager.show_confirm_dialog(msg, actorId, 0)
		LoadControl.set_view_model(2000)
		return
	ske.battle_change_morale(-extraMorale)
	ske.battle_change_tactic_point(extraMorale)
	ske.battle_cd(99999)
	ske.battle_report()
	var msg = "听我号令，不可只凭血勇\n（士气降低 {0}\n（战术值增加 {0}".format([extraMorale])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30249_end():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
