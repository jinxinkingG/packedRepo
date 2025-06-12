extends "effect_30000.gd"

#抬棺主动技实现
#【抬棺】小战场,主动技。非城战，你可以使用：你的全体士兵强制前进，你与士兵的基础伤害倍率+0.2，你的战术只剩“咒缚”和“挑衅”。对方兵力＞200时，你无法撤出小战场。一日限一次。

const EFFECT_ID = 30100
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_skill_result_confirmation("tactic_end", false)
	return

func on_view_model_3000():
	wait_for_skill_result_confirmation("unit_action")
	return

func check_AI_perform()->bool:
	# 无条件发动
	return true

func effect_30100_AI_start():
	goto_step("start")
	return

func effect_30100_start():
	ske.cost_war_cd(1)
	ske.battle_cd(99999)

	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != self.actorId:
			continue
		if bu.dic_combat.has(ske.skill_name):
			continue
		bu.append_combat_val("额外伤害", 0.2)
		bu.mark_buffed()

	ske.set_battle_buff(me.actorId, "全军死战", 99999)
	ske.battle_report()

	
	var msg = "此棺当置{0}首级\n死战不休！".format([enemy.get_name()])
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	if me.get_controlNo() < 0:
		LoadControl.set_view_model(3000)
	else:
		LoadControl.set_view_model(2000)
	return
