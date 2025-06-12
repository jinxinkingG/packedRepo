extends "effect_20000.gd"

#综赋效果实现
#【综赋】大战场，锁定技。你使用伤兵计时，以X代替“知”计算命中率和伤害(X=你当前主属性值)。

func on_trigger_20017()->bool:
	wisdom_buff()
	return false

func on_trigger_20029()->bool:
	wisdom_buff()
	return false

func wisdom_buff()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	var wisdom = actor.get_wisdom()
	var x = actor.get_power() - wisdom
	x = max(x, actor.get_leadership() - wisdom)
	x = max(x, actor.get_politics() - wisdom)
	if x > 0:
		change_scheme_chance(actorId, ske.skill_name, x)
	return false
