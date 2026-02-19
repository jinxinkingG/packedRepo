extends "effect_30000.gd"

#豹骑锁定技 #骑兵强化
#【豹骑】小战场，锁定技。非城战，你拥有豹骑兵。豹骑兵：默认每轮可以行动3次，基础减伤倍率-0.15。

const HUBAO_EFFECT_ID = 30115
const ENHANCEMENT = {
	"额外免伤": -0.15,
	"行动次数": 3,
}

func on_trigger_30024()->bool:
	var enhanced = ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	if enhanced == null:
		return false
	if enhanced.dic_combat.has("虎骑"):
		enhanced.mark_buffed()
	else:
		enhanced.mark_buffed(-1)
	if ske.get_battle_skill_val_int(HUBAO_EFFECT_ID) > 0:
		return false
	if ske.get_battle_skill_val_int() > 0:
		return false
	ske.set_battle_skill_val(1)
	var msg = "虎豹天下骁骑\n孰能遁其锋？\n（【豹骑】发动"
	me.attach_free_dialog(msg, 0, 30000)
	return false
