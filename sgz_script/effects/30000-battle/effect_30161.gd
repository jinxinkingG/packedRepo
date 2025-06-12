extends "effect_30000.gd"

#胆莽主动技及被动效果
#【胆莽】小战场，主动技。发动后，你的胆增加你的当前战术值，且最多增加15，然后清空你的战术值。

const EFFECT_ID = 30161
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform()->bool:
	# 无条件发动
	return true

func effect_30161_AI_start():
	goto_step("start")
	return

func effect_30161_start():
	var tp = me.battle_tactic_point
	var courage = min(15, tp)
	var msg = "将为军胆，随我冲锋！\n（{0}胆增加{1}，战术值清零".format([
		me.get_name(), courage
	])
	ske.battle_cd(99999)
	ske.battle_change_courage(courage)
	ske.battle_change_tactic_point(-tp, me)
	ske.battle_report()
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	Global.wait_for_confirmation(FLOW_BASE + "_2")
	return

func effect_30161_2():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
