extends "effect_30000.gd"

#临武锁定技
#【临武】小战场,锁定技。你的武临时+5

func on_trigger_30005():
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var currentPower = me.get_battle_power()
	var basicMorale = me.calculate_battle_morale(me.get_battle_power(), me.battle_lead, 0)
	ske.battle_change_power(5, me)
	var changedMorale = me.calculate_battle_morale(me.get_battle_power(), me.battle_lead, 0)
	if changedMorale > basicMorale:
		ske.battle_change_morale(changedMorale - basicMorale, me)
	ske.battle_report()
	return false
