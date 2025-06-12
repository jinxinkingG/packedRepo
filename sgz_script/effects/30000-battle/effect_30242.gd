extends "effect_30000.gd"

#扎布主动技
#【扎布】小战场，主动技。使用后，你的体力+5，护甲值+8。每个大战场回合限1次

const EFFECT_ID = 30242
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_RECOVER = 5
const ARMOR_RECOVER = 8

func check_AI_perform()->bool:
	# 体力小于 60 即发动
	me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return false
	var bu = me.battle_actor_unit()
	if bu == null or bu.disabled:
		return false
	var maxHP = me.actor().get_max_hp()
	var current = bu.get_hp()
	return current <= maxHP - 10

func effect_30242_AI_start():
	goto_step("start")
	return

func effect_30242_start():
	var bu = me.battle_actor_unit()
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	var hp = ske.battle_change_unit_hp(bu, HP_RECOVER)
	var armor = ske.battle_change_unit_armor(bu, ARMOR_RECOVER)
	var msg = "癣疥小创，何足挂齿！"
	if hp > 0:
		msg += "\n（体力回复{0}".format([hp])
	if armor > 0:
		msg += "\n（获得{0}点护甲".format([armor])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30242_end():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
