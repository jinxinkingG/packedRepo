extends "effect_30000.gd"

#广射主动技
#【广射】小战场，主动技。消耗 5 战术值发动，此后的三回合，回合结束时，你弯弓射日，对全场随机1名敌方单位造成射箭伤害。小战场限1次。

const TP_COST = 5

func effect_30269_start()->void:
	var bu = me.battle_actor_unit()
	if bu == null:
		tactic_end()
		return
	if me.battle_tactic_point < TP_COST:
		var msg = "战术值不足，需 >= {0}".format([TP_COST])
		me.attach_free_dialog(msg, 3, 30000)
		tactic_end()
		return

	bu.dic_combat[ske.skill_name] = {"BUFF": 1}
	bu.requires_update = 1
	ske.battle_set_skill_val(1, 3)
	ske.battle_cd(99999)
	ske.battle_change_tactic_point(-TP_COST)
	ske.battle_report()

	tactic_end()

	me.attach_free_dialog("引弦广视，八方可及！", 0, 30000)
	return
