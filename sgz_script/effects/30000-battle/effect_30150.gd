extends "effect_30000.gd"

#压胆效果实现
#【压胆】小战场,锁定技。你的武＞对手时，你的胆+8。

const GUTS_BUFF = 8

func on_trigger_30006():
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null or enemy.actor().get_power() >= actor.get_power():
		return false
	var sbp = ske.get_battle_skill_property()
	sbp.courage += GUTS_BUFF
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()

	var msg = "{0}小儿，非吾对手！\n（【{1}】胆增加{2}".format([
		enemy.get_name(), ske.skill_name, GUTS_BUFF,
	])
	me.attach_free_dialog(msg, 0, 30000)

	return false
