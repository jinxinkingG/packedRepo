extends "effect_30000.gd"

#胆锋小战场效果
#【胆锋】小战场，锁定技。你的胆＞对手时，你的武+8。

func on_trigger_30005()->bool:
	if me == null or enemy == null:
		return false
	if me.battle_courage <= enemy.battle_courage:
		return false

	var baseMorale = me.calculate_battle_morale(me.get_battle_power(), me.battle_lead, 0)
	ske.battle_change_power(8, me)
	var enhancedMorale = me.calculate_battle_morale(me.get_battle_power(), me.battle_lead, 0)
	var x = enhancedMorale - baseMorale
	if x > 0:
		ske.battle_change_morale(x)
	ske.battle_report()
	var msg = "狭路相逢，勇者恒强！\n（{0}【{1}】武力上升".format([
		me.get_name(), ske.skill_name,
	])
	append_free_dialog(me, msg, 0)
	return false
