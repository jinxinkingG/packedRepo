extends "effect_30000.gd"

#千驹主动技及被动效果
#【千驹】小战场，主动技。非城战才能发动。你的步兵和弓兵全部上马成为骑兵，但每回合你的战术值-1，效果持续至你的战术值为0。

const EFFECT_ID = 30157
const PASSIVE_EFFECT_ID = 30158
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func check_AI_perform()->bool:
	# 步兵或弓兵>0时发动
	if DataManager.battle_unit_type_hp(me.actorId, "步") > 0:
		return true
	if DataManager.battle_unit_type_hp(me.actorId, "弓") > 0:
		return true
	return false

func effect_30157_AI_start():
	goto_step("start")
	return

func effect_30157_start():
	var msg = "全体上马，速战速决！"
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func effect_30157_2():
	ske.battle_cd(99999)
	ske.set_battle_skill_val(1, 99999, PASSIVE_EFFECT_ID)
	var units = []
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != me.actorId:
			continue
		if not bu.get_unit_type() in ["弓", "步"]:
			continue
		units.append(bu)
	ske.battle_change_units_type(me.actorId, units, "骑")
	ske.battle_report()
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
