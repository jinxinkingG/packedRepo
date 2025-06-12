extends "effect_20000.gd"

# 破卷效果
#【破卷】大战场，锁定技。回合内，你以<跋涉>增加的经验每有1点，你使用计策时，计策命中率临时+1%（至多加10%）。

const BASHE_EFFECT_ID = 20577

func on_trigger_20017() -> bool:
	var daily = ske.get_war_skill_val_int(BASHE_EFFECT_ID)
	if daily <= 0:
		return false
	daily = min(10, daily)
	change_scheme_chance(actorId, ske.skill_name, daily)
	return false
