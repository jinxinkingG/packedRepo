extends "effect_20000.gd"

#博览
#【博览】大战场,锁定技。你装备书类道具时，该书附加的智力翻倍

func on_trigger_20017()->bool:
	var x = actor.get_equip_feature_total("计策附加智力")
	if x <= 0:
		return false
	change_scheme_chance(actorId, ske.skill_name, x)
	return false
