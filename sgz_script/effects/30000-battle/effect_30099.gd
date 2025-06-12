extends "effect_30000.gd"

#三杰技能实现
#【三杰】小战场,锁定技。每过一回合，你的战术+1，你每使用一次“强弩”、“士气向上”或“火矢”，你的士气+2

func on_trigger_30009():
	var bf = DataManager.get_current_battle_fight()
	if bf == null or bf.turns() <= 1:
		return false
	ske.battle_change_tactic_point(1)
	ske.battle_report()
	return false

func on_trigger_30010():
	for k in ["强弩", "士气向上", "火矢"]:
		if me.get_buff(k)["回合数"] > 0:
			ske.battle_change_morale(2)
			ske.battle_report()
			break
	return false
