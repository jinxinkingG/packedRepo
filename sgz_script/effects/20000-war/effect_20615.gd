extends "effect_20000.gd"

# 知机大战场效果部分
#【知机】大战场，限定技。找出战场破局点，制定针对性的策略。你指定一个“知不高于你的敌方武将”发动，本场战争中对此目标武将：我方发动计策的成功率 +10%，主动攻击时白兵战士气 +8。被你指定的武将死亡或者脱离战场，重置本技能冷却。

const ACTIVE_EFFECT_ID = 20614

func on_trigger_20017() -> bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	var se = DataManager.get_current_stratagem_execution()
	if targetId != se.targetId:
		return false
	change_scheme_chance(actorId, ske.skill_name, 10)
	return false

func on_trigger_20027() -> bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if targetId != ske.actorId:
		return false
	ske.clear_actor_skill_cd(actorId, [20000], [ACTIVE_EFFECT_ID], -1, 99999)
	ske.set_war_skill_val(-1, 0, ACTIVE_EFFECT_ID)
	ske.war_report()
	return false

func on_trigger_20051() -> bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if targetId != ske.actorId:
		return false
	ske.clear_actor_skill_cd(actorId, [20000], [ACTIVE_EFFECT_ID], -1, 99999)
	ske.set_war_skill_val(-1, 0, ACTIVE_EFFECT_ID)
	ske.war_report()
	return false
