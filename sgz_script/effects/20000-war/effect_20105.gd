extends "effect_20000.gd"

#智迟效果实现
#【智迟】大战场,锁定技。你方武将被用计伤兵时，那次伤兵量下降X*50（X=同一回合你方武将所受伤兵计的次数-1）。

const DAMAGE_REDUCE = 50

func on_trigger_20002()->bool:
	var damage = DataManager.get_env_int("计策.ONCE.伤害")
	if damage <= 0:
		return false
	var x = ske.get_war_skill_val_int()
	var se = DataManager.get_current_stratagem_execution()
	if not se.results.has(ske.skill_name):
		# 每次计策只计一次数
		x += 1
		ske.set_war_skill_val(x, 1)
	# 最小为 1
	x = max(x, 1)

	var reduce = -1 * (x - 1) * DAMAGE_REDUCE
	change_scheme_damage_value(actorId, ske.skill_name, reduce)
	return false
