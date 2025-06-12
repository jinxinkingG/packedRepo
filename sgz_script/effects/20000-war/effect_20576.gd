extends "effect_20000.gd"

# 叛离效果
#【叛离】大战场，锁定技。若你转移过阵营，且当前所在阵营不是你的战争初始阵营，则你的白刃战士气+20，伤兵计命中率 +15%。

func on_trigger_20017() -> bool:
	if me.vstateId == me.init_vstateId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	change_scheme_chance(actorId, ske.skill_name, 15)
	return false
