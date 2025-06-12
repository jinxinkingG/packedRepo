extends "effect_30000.gd"

#化身主动技
#【化身】小战场，主动技。发动后场上所有单位变为“你”，不可触发单挑，所有单位被击杀后败退。战斗结束后，兵力为剩余单位体力总和。

const EFFECT_ID = 30181
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func check_AI_perform()->bool:
	# 有一定兵力就发动
	return actor.get_soldiers() > 0

func effect_30181_AI_start():
	goto_step("start")
	return

func effect_30181_start():
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != me.actorId:
			continue
		var originalType = bu.Type
		if bu.get_unit_type() == "将":
			bu.init_combat_info("骑(化身)")
			bu.set_hp(0, true)
			bu.disabled = true
			bu.dic_combat["原兵种"] = originalType
			continue
		bu.init_combat_info("骑(化身)")
		bu.dic_combat["原兵种"] = originalType
	ske.set_battle_buff(me.actorId, "战术禁用", 99999)
	ske.battle_cd(99999)
	ske.battle_report()
	var msg = "化身五五，形神之妙\n岂凡愚可知？"
	SceneManager.show_confirm_dialog(msg, me.actorId, 2)
	LoadControl.set_view_model(2000)
	return

func effect_30181_2():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
