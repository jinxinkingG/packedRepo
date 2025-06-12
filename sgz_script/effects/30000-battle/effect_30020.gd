extends "effect_30000.gd"

#酣战效果实现
#【酣战】小战场，锁定技。你进入白刃战时的初始战术值+X（X=本回合进入白刃战的次数+1）。

func on_trigger_30006():
	# 使用大战场标记计算本回合白兵战斗次数，目前是允许跨 scene 变量的
	var battleTimes = ske.get_war_skill_val_int()
	# 白兵战标记 +1
	battleTimes += 1
	ske.set_war_skill_val(battleTimes, 1)
	var x = battleTimes + 1
	
	var sbp = ske.get_battle_skill_property()
	sbp.tp += x
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	
	var msg = "{0}出阵，每阵愈强！\n（【{1}】增加{2}战术值".format([
		DataManager.get_actor_self_title(actorId),
		ske.skill_name, x,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
