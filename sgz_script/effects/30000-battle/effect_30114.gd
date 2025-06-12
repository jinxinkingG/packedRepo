extends "effect_30000.gd"

#豹骑锁定技 #骑兵强化
#【豹骑】小战场,锁定技。非城战，你的骑兵每轮可以行动3次，但基础减伤倍率-0.15。

const HUBAO_EFFECT_ID = 30115
const ENHANCEMENT = {
	"额外免伤": -0.15,
	"行动次数": 3,
}

func on_trigger_30009()->bool:
	if DataManager.battle_unit_type_hp(me.actorId, "骑") <= 0:
		return false
	if ske.get_battle_skill_val_int(HUBAO_EFFECT_ID) > 0:
		return false
	if ske.get_battle_skill_val_int() > 0:
		return false
	ske.set_battle_skill_val(1)
	var d = War_Character.DialogInfo.new()
	d.text = "虎豹天下骁骑\n孰能遁其锋？\n（【豹骑】发动"
	d.actorId = me.actorId
	d.mood = 0
	d.sceneId = 30000
	me.add_dialog_info(d)
	return false

func on_trigger_30024()->bool:
	var bu = ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	if bu == null:
		return false
	if bu.dic_combat.has("虎骑"):
		bu.mark_buffed()
	else:
		bu.mark_buffed(-1)
	return false
