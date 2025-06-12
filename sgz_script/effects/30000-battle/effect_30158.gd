extends "effect_30000.gd"

#千驹被动效果 #骑兵强化
#【千驹】小战场，主动技。非城战才能发动。你的步兵和弓兵全部上马成为骑兵，但每回合你的战术值-1，效果持续至你的战术值为0。

const EFFECT_ID = 30158
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	if ske.get_battle_skill_val_int() <= 0:
		return false
	var me = ske.get_war_actor()
	me.battle_tactic_point = max(0, me.battle_tactic_point - 1)
	if me.battle_tactic_point > 0:
		return false
	ske.set_battle_skill_val(0)
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId != self.actorId or bu.get_unit_type() != "骑":
			continue
		if not bu.dic_combat.has("原兵种"):
			continue
		var originalType = str(bu.dic_combat["原兵种"])
		bu.dic_combat.erase("原兵种")
		bu.init_combat_info(originalType)
		bu.requires_update = true
	return false
