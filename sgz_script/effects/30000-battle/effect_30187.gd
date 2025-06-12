extends "effect_30000.gd"

#迎袭效果
#【迎袭】大战场，主将锁定技。你方其他武将为白刃战攻方，你消耗6点机动力，使该武将本次白刃战初始战术值+10

const COST_AP = 6

func on_trigger_30005()->bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_attacker_id():
		# 触发队友不是攻方
		return false
	if actorId == bf.get_attacker_id():
		# 自己不触发
		return false
	if me.action_point < COST_AP:
		# 机动力不足
		return false

	var attacker = bf.get_attacker()

	ske.cost_ap(COST_AP)
	ske.battle_change_tactic_point(10, attacker)
	ske.battle_report()

	var msg = "胆敢犯我境界！"
	var wv = me.war_vstate()
	if wv.side == "攻击方":
		msg = "安能抗我大军！"
	msg = "兵机足备\n{0}{1}\n（{2}发动【{3}】\n（{4}战术值 +10".format([
		bf.get_defender().get_name(),
		msg, me.get_name(), ske.skill_name,
		attacker.get_name(),
	])
	attacker.attach_free_dialog(msg, 0, 30000, actorId)
	return false
