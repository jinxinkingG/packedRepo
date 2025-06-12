extends "effect_20000.gd"

#涉险被动效果
#【涉险】大战场，主动技。6格范围内你没有其他队友且存在至少2个敌方武将的场合，你可选择1名敌将为目标，并消耗5机动力发动。你与之进入白刃战；仅在此次白刃战中，你兵力受到的损失只有一半计入实际兵力。每个回合限1次。

func on_trigger_20020()->bool:
	var prevSoldiers = ske.get_war_skill_val_int()
	var recover = int((prevSoldiers - actor.get_soldiers()) / 2)
	if recover <= 0:
		return false
	ske.change_actor_soldiers(actorId, recover)
	ske.war_report()
	return false
