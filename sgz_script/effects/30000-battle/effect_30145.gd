extends "effect_30000.gd"

#暴弓效果
#【暴弓】小战场,锁定技。你及你的弓兵射击时，有50%概率造成150%暴击伤害。

func on_trigger_30009():
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() in ["弓", "将"]:
			bu.dic_combat["射箭爆率"] = 0.5
			bu.dic_combat["射箭爆伤"] = 1.5
			bu.mark_buffed()
	return false
