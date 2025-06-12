extends "effect_30000.gd"

#冒矢锁定技 #减伤
#【冒矢】小战场，锁定技。非城战对方弓兵对你造成的伤害减半。

func check_trigger_correct():
	var ske = SkillHelper.read_skill_effectinfo()
	ske.battle_reduce_damage_rate(0.5, ["将"], ["弓"], ["ALL"])
	return false
