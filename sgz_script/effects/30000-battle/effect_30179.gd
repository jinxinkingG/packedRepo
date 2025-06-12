extends "effect_30000.gd"

#疾冲主动技
#【疾冲】小战场，主动技。使用后，本回合你方所有士兵单位行动结束后，该单位额外行动1次。白刃战限1次。

const EFFECT_ID = 30179
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func check_AI_perform()->bool:
	var bf = DataManager.get_current_battle_fight()
	# 第三回合后随机
	if bf == null or bf.turns() <= 3:
		return false
	if actor.get_soldiers() < 200:
		return false
	return Global.get_rate_result(70)

func effect_30179_AI_start():
	goto_step("start")
	return

func effect_30179_start():
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId != self.actorId:
			continue
		if bu.get_unit_type() == "将":
			continue
		bu.wait_action_times += 1
	ske.battle_cd(99999)
	ske.battle_report()
	var msg = "放手一搏，冲锋！"
	if me.get_controlNo() < 0:
		msg += "\n（{0}发动【疾冲】\n士兵获得额外行动机会".format([
			me.get_name(),
		])
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func effect_30179_2():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
