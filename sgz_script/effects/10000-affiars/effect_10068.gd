extends "effect_10000.gd"

#逆士锁定效果
#【逆士】内政&大战场,主将主动技。内政：每月你[死士]+300，上限3000；大战场：你可以指定任意你方武将，将任意数量的[死士]交给该武将（不超过其兵力上限）。

const FLAG_NAME = "士"

func on_trigger_10001():
	collect_sacrificer()
	return false
	
func on_trigger_20034():
	collect_sacrificer()
	return false

func collect_sacrificer()->void:
	ske.affair_cd(1)
	ske.add_skill_flags(10000, ske.effect_Id, FLAG_NAME, 300, 3000)
	return
