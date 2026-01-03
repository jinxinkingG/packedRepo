extends "effect_20000.gd"

#同心锁定技 #胜利触发
#【同心】大战场，锁定技。你方其他武将白刃战获胜时，本回合你下一次使用的[火计]只消耗3点机动力。

func on_trigger_20008() -> bool:
	if ske.actorId == actorId:
		# 自己不触发
		return false
	var winner = bf.get_winner()
	if winner == null or winner.actorId != ske.actorId:
		# 不是胜利方
		return false
	# 为自己设定同心标记
	ske.set_war_skill_val(1, 1)
	return false

func on_trigger_20004() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		return false

	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")

	for scheme in schemes:
		var name = str(scheme[0])
		if name == "火计":
			scheme[2] = "同心"
	change_stratagem_list(actorId, schemes)
	return false

func on_trigger_20005() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		return false
	reduce_scheme_ap_cost("火计", 3)
	return false

func on_trigger_20006() -> bool:
	# 确认发动时，直接清空标记
	var se = DataManager.get_current_stratagem_execution()
	if se.name == "火计" and se.skill == "":
		ske.set_war_skill_val(0, 0)
	return false
