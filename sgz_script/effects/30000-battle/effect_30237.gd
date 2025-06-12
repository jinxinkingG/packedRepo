extends "effect_30000.gd"

#断发主动技
#【断发】小战场，主动技。消耗3点战术值发动。令双方所有士兵的兵种变回白刃战准备阶段时的兵种。每有一个敌方单位的兵种以此法发生了改变，对方士气-2。白刃战限一次。

const EFFECT_ID = 30237
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform()->bool:
	me = DataManager.get_war_actor(actorId)
	enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	# 检查对方是否有变身兵种
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != enemy.actorId:
			continue
		if not bu.dic_combat.has("原兵种"):
			continue
		if bu.dic_combat["原兵种"] != bu.Type:
			return true
	return false

func effect_30237_AI_start():
	goto_step("start")
	return

func effect_30237_start():
	# 检查对方是否有变身兵种
	SceneManager.current_scene().battle_tactic.hide_description()
	var toChange = {}
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != enemy.actorId:
			continue
		if not bu.dic_combat.has("原兵种"):
			continue
		var originalType = str(bu.dic_combat["原兵种"])
		if originalType == bu.Type:
			continue
		if not originalType in toChange:
			toChange[originalType] = []
		if not bu.unitId in toChange[originalType]:
			toChange[originalType].append(bu)

	ske.battle_cd(99999)
	if toChange.empty():
		# 对，白发动也 CD
		var msg = "空断发，未知机\n敌方兵种没有变化"
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
	var changed = 0
	for type in toChange:
		changed += toChange[type].size()
		ske.battle_change_units_type(enemy.actorId, toChange[type], type)
	var moraleDown = ske.battle_change_morale(changed * -2, enemy)

	ske.battle_report()

	var msg = "断发为信，{0}中计矣\n（{1}军变为初始兵种"
	if moraleDown < 0:
		msg += "\n（{1}士气降低{2}"
	msg = msg.format([
		DataManager.get_actor_naughty_title(enemy.actorId),
		enemy.get_name(), abs(moraleDown),
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_end", false)
	return

func effect_30237_end():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
