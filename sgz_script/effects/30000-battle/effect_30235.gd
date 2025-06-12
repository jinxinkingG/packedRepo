extends "effect_30000.gd"

#潜击效果
#【潜击】小战场，锁定技。若此次白刃战之前，对方将领从未攻击/被攻击，你的士气至少为X（X=对方的士气值-你的等级）。

func on_trigger_30005()->bool:
	if enemy == null:
		return false
	if enemy.get_war_attacked_actors().size() > 1:
		return false
	if enemy.get_war_defended_actors().size() > 1:
		return false
	var targetMorale = enemy.battle_morale - me.actor().get_level()
	if targetMorale <= me.battle_morale:
		return false
	ske.battle_change_morale(targetMorale - me.battle_morale, me)
	ske.battle_report()
	var msg = "{0}未知我军虚实\n当可尽力一战！\n（【{1}】士气提升至{2}".format([
		enemy.get_name(), ske.skill_name, targetMorale
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
