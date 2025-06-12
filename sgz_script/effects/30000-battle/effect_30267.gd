extends "effect_30000.gd"

#勇退主动技
#【勇退】小战场，主动技。你向后跳2格，你的士气-5，护甲值+15。每个大战场回合限1次。 （类似骑突，不过是往后跳，后方第2格为空，才能发动，如果跳出版边，算己方退出了小战场，会损兵，会扣粮食） 大体思路是：急流勇退，看形势不妙，自己先跑，顺便给自己叠个甲，己方士兵看了，士气下降。

func effect_30267_start()->void:
	var bu = me.battle_actor_unit()
	var pos = bu.unit_position + bu.get_side() * 2
	if not bu.can_move_to_position(pos, true):
		tactic_end()
		var msg = "无法跳入【{0}】目标位置".format([ske.skill_name])
		me.attach_free_dialog(msg, 3, 30000)
		return

	bu.unit_position = pos
	bu.requires_update = true

	ske.cost_war_cd(1)
	ske.battle_cd(99999)
	ske.battle_change_morale(-5)
	ske.battle_change_unit_armor(bu, 15)
	ske.battle_report()

	tactic_end()

	me.attach_free_dialog("以退为进！", 0, 30000)
	return
