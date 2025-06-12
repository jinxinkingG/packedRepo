extends "effect_30000.gd"

#怯守技能实现
#【怯守】小战场,锁定技。对方武＞你时，你的胆临时-x，统临时+x/2，x＝对方武-你的武

func on_trigger_30006():
	var enemy = me.get_battle_enemy_war_actor()
	if enemy == null:
		return false

	var x = enemy.actor().get_power() - actor.get_power()
	if x <= 0:
		return false

	x = min(20, x)

	var sbp = ske.get_battle_skill_property()
	sbp.courage -= x
	sbp.leader += int(ceil(x / 2))
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()

	var msg = "{0}劲敌也，小心为上…\n（【{1}】胆降低，统提升".format([
		enemy.get_name(), ske.skill_name,
	])
	me.attach_free_dialog(msg, 2, 30000)
	return false
