extends "effect_20000.gd"

#识策效果 #计策免伤
#【识策】大战场，锁定技。你被伤兵类计策命中后，本回合结束前，你不会再受到相同计策的伤害
#【创止】大战场，锁定技。你视为拥有<识策>和<破发>

func on_trigger_20002()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var remembered = ske.get_war_skill_val_array()
	if se.name in remembered:
		change_scheme_damage_rate(-100)
	remembered.append(se.name)
	ske.set_war_skill_val(remembered, 1)
	return false
