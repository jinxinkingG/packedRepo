extends "effect_30000.gd"

# 兵乱效果
#【兵乱】小战场，锁定技。若你战术为0，你方士气+15，但士兵行动混乱，且攻击不再区分敌我。

const MORALE_BUFF = 15

func on_trigger_30009() -> bool:
	if me.battle_tactic_point > 0:
		return false
	var bf = DataManager.get_current_battle_fight()
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() in ["将", "城门"]:
			continue
		ske.battle_buff_unit(bu, {"乱兵": 1})
	ske.set_battle_buff(actorId, "混乱", 999)
	var moraleUp = ske.battle_change_morale(MORALE_BUFF)
	ske.battle_cd(99999)
	ske.battle_report()

	var msg = "将令不明，杀出条血路！！\n（【{0}】效果，士气 +{1}\n（士兵不分敌我".format([
		ske.skill_name, moraleUp
	])
	me.attach_free_dialog(msg, 0, 30000, -1, true)
	return false
