extends "effect_30000.gd"

#掩杀技能实现
#【掩杀】小战场，主动技。对方士气-4，且你获得2回合“士气向上”战术。每个大战场回合限1次。

const EFFECT_ID = 30261
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.turns() < 2:
		return false
	for buff in StaticManager.CONTINUOUS_TACTICS:
		if me.get_buff(buff)["回合数"] > 0:
			return false
	return true

func effect_30261_AI_start():
	goto_step("start")
	return

func effect_30261_start():
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	ske.battle_change_morale(-4, enemy)
	var turns = ske.set_battle_buff(actorId, "士气向上", 2)
	ske.battle_report()
	
	var msg = "认得{0}否？\n（获得士气向上 {1}回合\n（{2}士气 -4".format([
		DataManager.get_actor_self_title(actorId),
		turns, enemy.get_name(),
	])
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func effect_30261_2():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
