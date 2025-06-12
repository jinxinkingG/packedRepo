extends "effect_20000.gd"

#破伏效果 #减伤
#【破伏】大战场，锁定技。你不会受到“要击”，“十面埋伏”的计策伤害。

func on_trigger_20002()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.name in ["要击", "十面埋伏"]:
		return false
	
	change_scheme_damage_rate(-100)
	return false
