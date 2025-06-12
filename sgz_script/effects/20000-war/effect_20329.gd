extends "effect_20000.gd"

#戡难被动效果
#【戡难】大战场，主将主动技。选择1名敌将才能发动：刷新双方五行并对比点数。若你的点数＞对方，本回合你方计策伤害变为150%；若你的点数＜对方，下回合对方计策伤害变为150%。每个回合限1次。

func on_trigger_20011()->bool:
	var flagId = ske.get_war_skill_val_int(-1, -1, -1)
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(se.fromId) != flagId:
		return false
	change_scheme_damage_rate(50)
	return false
