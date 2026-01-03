extends "effect_20000.gd"

# 巧袭效果
# 【巧袭】大战场，锁定技。你使用计策要击时，以“武+5”代替“知”计算命中率，以“知+5”代替“武”计算计策伤害。

func on_trigger_20017() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.name != "要击":
		return false
	var wisdom = actor.get_wisdom()
	var diff = actor.get_power() + 5 - wisdom
	change_scheme_chance(actorId, ske.skill_name, diff)
	return false

func on_trigger_20029() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.name != "要击":
		return false
	var dic = DataManager.get_env_dict("计策.ONCE.公式属性")
	dic["a.武"] = actor.get_wisdom() + 5 - actor.get_power()
	DataManager.set_env("计策.ONCE.公式属性", dic)
	return false
