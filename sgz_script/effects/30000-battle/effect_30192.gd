extends "effect_30000.gd"

#山骑锁定技 #骑兵强化 #战术值
#【山骑】小战场，锁定技。若你在山地形，骑兵基础伤害倍率+0.20，回合结束时，若你方有骑兵存活，你的战术值+1。

const ENHANCEMENT = {
	"额外伤害": 0.2,
	"BUFF": 1,
}

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	match ske.trigger_Id:
		30024:
			ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
		30059:
			if DataManager.battle_unit_type_hp(ske.skill_actorId, "骑") <= 0:
				return false
			ske.battle_change_tactic_point(1)
	return false
