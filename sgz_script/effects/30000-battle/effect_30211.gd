extends "effect_30000.gd"

#拦截锁定效果
#【拦截】小战场，主动技。消耗一半战术值才能发动。在敌方后退方向的最后一列，创建一排拒马，持续(所消耗战术值/2)回合。

func on_trigger_30009()->bool:
	var rnd = ske.get_battle_skill_val_int()
	if rnd <= 0:
		var bf = DataManager.get_current_battle_fight()
		bf.clear_abatis_line()
		return false
	ske.set_battle_skill_val(rnd - 1, rnd - 1)
	return false
