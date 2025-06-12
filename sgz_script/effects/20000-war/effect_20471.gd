extends "effect_20000.gd"

#先识被动效果触发
#【先识】大战场，主动技。选择1名敌将，之后指定其计策列表的1个伤兵计策为目标，消耗你10点机动力才能发动。下次对方回合内，若你的队友被目标敌将使用目标计策，那名队友受到的兵力伤害减少一半。每回合限指定1次。

func on_trigger_20002()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	if ske.get_war_skill_val_str(ske.effect_Id, fromId) != se.name:
		return false
	change_scheme_damage_rate(-50)
	return false
