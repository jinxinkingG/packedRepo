extends "effect_30000.gd"

#断发主动技
#【断发】小战场，主动技。消耗3点战术值发动。令双方所有士兵的兵种变回白刃战准备阶段时的兵种。每有一个敌方单位的兵种以此法发生了改变，对方士气-2。白刃战限1次。

const EFFECT_ID = 30237
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform() -> bool:
	me = DataManager.get_war_actor(actorId)
	enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	# 检查对方是否有变身兵种
	for bu in bf.battle_units(enemy.actorId):
		if bu.initial_type_changed():
			return true
	return false

func effect_30237_AI_start():
	goto_step("start")
	return

func effect_30237_start():
	# 检查对方是否有变身兵种
	SceneManager.current_scene().battle_tactic.hide_description()
	var changed = 0
	for bu in bf.battle_units(enemy.actorId):
		if bu.reset_initial_type():
			changed += 1

	ske.battle_cd(99999)
	if changed <= 0:
		# 对，白发动也 CD
		var msg = "空断发，未知机\n敌方兵种没有变化"
		SceneManager.show_confirm_dialog(msg, actorId, 3)
		LoadControl.set_view_model(2000)
		return
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
	tactic_end()
	return
