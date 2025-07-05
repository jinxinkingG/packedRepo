extends "effect_30000.gd"

#胆锋小战场效果
#【胆锋】小战场，锁定技。你的胆＞对手时，你的武+8。

const POWER_BUFF = 8

func on_trigger_30005() -> bool:
	if me == null or enemy == null:
		return false
	if me.battle_courage <= enemy.battle_courage:
		return false

	ske.battle_change_power(POWER_BUFF)
	ske.battle_report()
	var msg = "狭路相逢，勇者恒强！\n（【{0}】武力 +{1}".format([
		ske.skill_name, POWER_BUFF,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
