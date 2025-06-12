extends "effect_30000.gd"

#弃弓主动技
#【弃弓】小战场，主动技。使用后，你的战术值+6，你的弓兵转为步兵。

const EFFECT_ID = 30252
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TACTIC_ADDED = 6

# AI 暂不发动

func effect_30252_start():
	var added = ske.battle_change_tactic_point(TACTIC_ADDED)
	ske.battle_cd(99999)
	var affected = []
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() != "弓":
			continue
		affected.append(bu)
	var changed = ske.battle_change_units_type(actorId, affected, "步")
	ske.battle_report()
	var msg = "白刃突击！\n（战术值 +{0}"
	if changed > 0:
		msg = "枪为百兵王，白刃突击！\n（战术值 +{0}\n（{1}单位弃弓变为步兵"
	msg = msg.format([
		added, changed
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return false

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30252_end():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
