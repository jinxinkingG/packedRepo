extends "effect_30000.gd"

# 逸统效果
#【逸统】小战场，锁定技。你方回合内，你以<跋涉>增加的经验每有1点，你的统临时+1（至多加10）。

const BASHE_EFFECT_ID = 20577

func on_trigger_30006() -> bool:
	var daily = ske.get_war_skill_val_int(BASHE_EFFECT_ID)
	if daily <= 0:
		return false
	daily = min(10, daily)
	var sbp = ske.get_battle_skill_property()
	sbp.leader += daily
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false
