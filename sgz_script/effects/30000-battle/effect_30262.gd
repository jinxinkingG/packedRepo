extends "effect_30000.gd"

#先登效果
#【先登】小战场，锁定技。你为攻城方时，固定为特殊阵型，且你的士兵免伤倍率+0.15，白刃战前2轮，你的士兵行动次数+1

const ENHANCEMENT = {
	"额外免伤": 0.15,
	"BUFF": 1
}

func on_trigger_30003() -> bool:
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "特殊", {
			"攻方阵型": 9,
			"小战场标记ID": [30262],
		}
	)
	return false

func on_trigger_30005() -> bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	var msg = "搴旗拔垒，先登必我！"
	me.attach_free_dialog(msg, 0, 30000)
	return false

func on_trigger_30009() -> bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() in ["将", "城门"]:
			continue
		if bf.turns() > 2:
			bu.reset_action_times()
		elif bf.turns() == 1:
			bu.set_action_times(bu.get_action_times() + 1)
		bu.wait_action_times = bu.get_action_times()
	return false

func on_trigger_30024() -> bool:
	if ske.get_battle_skill_val_int() <= 0:
		return false
	ske.battle_enhance_current_unit(ENHANCEMENT, UNIT_TYPE_SOLDIERS)
	return false
