extends "effect_30000.gd"

#巧守技能实现
#【巧守】小战场,锁定技。若你为守方，用你的“（武+智）/2”代替你的“武”，用你的“（统+智）/2”代替你的“统”，计算你方士气及士兵防御。

func on_trigger_30005():
	var power = int((actor.get_power() + actor.get_wisdom())/2)
	power = max(power, actor.get_power())
	var lead = int((actor.get_leadership() + actor.get_wisdom())/2)
	lead = max(lead, actor.get_leadership())
	var baseMorale = me.calculate_battle_morale(me.get_battle_power(), me.battle_lead)
	var enhancedMorale = max(baseMorale + 5, me.calculate_battle_morale(power, lead))
	var x = enhancedMorale - baseMorale
	x = ske.battle_change_morale(x)
	ske.battle_report()
	var msg = "战阵之妙非蛮勇而已\n看我以巧破力\n（【{0}】士气+{1}".format([
		ske.skill_name, x,
	])
	append_free_dialog(me, msg, 2)
	return false
