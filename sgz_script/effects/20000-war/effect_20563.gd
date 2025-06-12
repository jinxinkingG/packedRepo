extends "effect_20000.gd"

# 稳健锁定技
#【稳健】大战场，锁定技。你免疫计策陷阱和落石。

func on_trigger_20002()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.name in ["陷阱", "落石"]:
		return false
	change_scheme_damage_rate(-100)
	return false

func on_trigger_20025()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.name in ["陷阱", "落石"]:
		return false
	change_scheme_hp_damage_rate(actorId, ske.skill_name, -100)
	return false
