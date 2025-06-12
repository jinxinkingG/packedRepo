extends "effect_30000.gd"

#白毦效果
#【白毦】小战场,锁定技。你的步兵和骑兵，在对敌兵造成近战伤害时，有60%的概率造成150%暴击伤害。

func on_trigger_30009():
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if not bu.get_unit_type() in ["步", "骑"]:
			continue
		bu.dic_combat["爆率"] = 0.6
		bu.dic_combat["爆伤"] = 1.5
		bu.mark_buffed()
	return false
