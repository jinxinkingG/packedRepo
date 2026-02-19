extends "effect_30000.gd"

#虎骑锁定技 #骑兵强化
#【虎骑】小战场，锁定技。非城战，你拥有虎骑兵。虎骑兵：基础减伤倍率+0.15，对敌兵造成伤害+10。

const HUBAO_EFFECT_ID = 30115
const EXTRA_DAMAGE = 10.0
const ENHANCEMENT = {
	"额外免伤": 0.15,
	"BUFF": 1,
}

func on_trigger_30021()->bool:
	var bu = ske.battle_extra_damage(EXTRA_DAMAGE, ["骑"], ["ALL"], UNIT_TYPE_SOLDIERS)
	if bu == null:
		return false
	bu.add_status_effect("虎骑 +{0}#FF0000".format([EXTRA_DAMAGE]))
	return false

func on_trigger_30024()->bool:
	var enhanced = ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	if enhanced == null:
		return false
	if ske.get_battle_skill_val_int(HUBAO_EFFECT_ID) > 0:
		return false
	if ske.get_battle_skill_val_int() > 0:
		return false
	ske.set_battle_skill_val(1)
	var msg = "虎豹天下骁骑\n孰能御其力？\n（【虎骑】发动"
	me.attach_free_dialog(msg, 0, 30000)
	return false
