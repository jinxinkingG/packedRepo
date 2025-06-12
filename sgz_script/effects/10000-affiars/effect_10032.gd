extends "effect_10000.gd"

#涉猎锁定技
#【涉猎】内政,锁定技。你装备书时，每月经验+该书的知附加值*30

# 锁定技部分
func on_trigger_10001() -> bool:
	var equip = actor.get_jewelry()
	if equip.subtype() != "书":
		return false
	var wisdom = actor.get_equip_feature_total("计策附加智力")
	if wisdom <= 0:
		return false
	actor.add_exp(wisdom * 30)
	return false
