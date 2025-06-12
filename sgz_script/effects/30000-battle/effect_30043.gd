extends "effect_30000.gd"

#水战锁定技 #弓兵强化 #战术值
#【水战】小战场,锁定技。若你在水地形，弓兵基础伤害倍率＋0.12，每回合战术值+1

const ENHANCEMENT = {
	"额外伤害": 0.12,
	"BUFF": 1,
}

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	match ske.trigger_Id:
		30024:
			ske.battle_enhance_current_unit(ENHANCEMENT, ["弓"])
		30059:
			ske.battle_change_tactic_point(1)
	return false
