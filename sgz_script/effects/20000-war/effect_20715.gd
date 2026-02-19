extends "effect_20000.gd"

# 见谮效果
#【见谮】大战场，锁定技。你被敌将攻击/用计的场合，那名敌将无法对你方其他武将攻击/用计，直到回合结束。

func on_trigger_20012() -> bool:
	ske.set_war_skill_val(actorId, 1, -1, ske.actorId)
	return false

func on_trigger_20015() -> bool:
	ske.set_war_skill_val(actorId, 1, -1, ske.actorId)
	return false

func on_trigger_20030() -> bool:
	if ske.get_war_skill_val_int(-1, ske.actorId, -1) != actorId:
		return false
	var excluded = DataManager.get_env_dict("战争.攻击目标排除")
	for wa in me.get_teammates(false, true):
		excluded[wa.actorId] = [actorId, ske.skill_name]
	DataManager.set_env("战争.攻击目标排除", excluded)
	return false
