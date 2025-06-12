extends "effect_30000.gd"

#恃体锁定技
#【恃体】小战场,锁定技。若你的体力＞40，则你的防御上升为原来的150%

func on_trigger_30009()->bool:
	var unit = me.battle_actor_unit()
	if unit == null or unit.disabled:
		return false
	var buff = unit.actor().get_hp() > 40.0
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
