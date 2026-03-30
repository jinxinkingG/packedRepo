extends "effect_30000.gd"

# 神威主动技
#【神威】小战场，主动技。发动后，持续X回合，对方所有士兵单位行动次数-1。每个大战场回合限1次。\nX = 2 + [本次战争你已经击杀/俘虏敌将的次数]\nX 最大为 4。

const EFFECT_ID = 30314
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const BUFF_NAME = "神威"
const BASIC_DURATION = 2

func check_AI_perform() -> bool:
	return bf.turns >= 3

func effect_30314_start() -> void:
	var msg = "发动【{0}】\n暂时压制敌方士兵行动\n可否？".format([ske.skill_name])
	SceneManager.show_yn_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", FLOW_BASE + "_end")
	return

func effect_30314_confirmed() -> void:
	var duration = BASIC_DURATION + ske.get_war_skill_val_int()
	duration = min(4, duration)
	duration = ske.set_battle_buff(actorId, BUFF_NAME, duration)
	# 立刻生效
	for bu in bf.battle_units(enemy.actorId):
		if not bu.is_soldier():
			continue
		bu.set_action_suppressed()
		bu.check_action_suppressed(true)
	ske.battle_cd(99999)
	ske.cost_war_cd(1)
	ske.battle_report()

	var msg = "插标卖首，也敢舞刀！\n（获得{0}回合[{1}]".format([
		duration, BUFF_NAME,
	])
	me.attach_free_dialog(msg, 0, 30000)
	goto_step("end")
	return

func effect_30314_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_30314_end() -> void:
	tactic_end()
	return
