extends "effect_30000.gd"

#奋冲锁定技
#【奋冲】小战场，锁定技。你或对方处于[咒缚]状态时，你的防御变为原来的150%

func on_trigger_30009()->bool:
	check_buff()
	return false

func on_trigger_30010()->bool:
	check_buff()
	return false

func on_trigger_30020()->bool:
	check_buff()
	return false

func check_buff()->bool:
	var unit = me.battle_actor_unit()
	if unit == null or unit.disabled:
		return false
	var buff = false
	if me.get_buff("咒缚")["回合数"] > 0:
		buff = true
	if not buff and enemy != null and enemy.get_buff("咒缚")["回合数"] > 0:
		buff = true
	var buffed = ske.battle_get_skill_val_int() > 0
	if not buff and buffed:
		ske.battle_set_skill_val(0, 0)
		unit.dic_combat.erase("防御倍率")
		unit.mark_buffed(0)
		ske.append_message("因【{0}】失去防御加成".format([ske.skill_name]))
		ske.battle_report()
	if buff and not buffed:
		ske.battle_set_skill_val(1, 99999)
		unit.dic_combat["防御倍率"] = 1.5
		unit.mark_buffed()
		ske.append_message("因【{0}】获得防御加成".format([ske.skill_name]))
		ske.battle_report()
	return false
