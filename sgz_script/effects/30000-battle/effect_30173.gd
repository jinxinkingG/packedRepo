extends "effect_30000.gd"

#奋射主动技
#【奋射】小战场，主动技。你的士气+10，并获得2回合“强弩”战术。每个大战场回合限1次。

const EFFECT_ID = 30173
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const MORALE_RECOVER = 8
const TACTIC_NAME = "强弩"
const TACTIC_TURNS = 2

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func check_AI_perform()->bool:
	var bf = DataManager.get_current_battle_fight()
	# 第三回合开始发动
	if bf == null or bf.turns() <= 2:
		return false
	if DataManager.battle_unit_type_hp(actorId, "弓") <= 0:
		return false
	return true

func effect_30173_AI_start():
	goto_step("start")
	return

func effect_30173_start():
	var bf = DataManager.get_current_battle_fight()
	ske.cost_war_cd(1)
	ske.battle_cd(99999)
	ske.battle_change_morale(MORALE_RECOVER)
	var turns = ske.set_battle_buff(me.actorId, TACTIC_NAME, TACTIC_TURNS)
	ske.battle_report()
	var msg = "劲弩速发，灭此朝食！\n（{0}发动【{1}】，士气+{2}，获得{3}回合强弩".format([
		me.get_name(), ske.skill_name, MORALE_RECOVER, turns,
	])
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func effect_30173_2():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
