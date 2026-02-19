extends "effect_20000.gd"

#博览
#【博览】大战场，锁定技。你装备书类道具时，计策附加智力 +X。若该书有附加智力时，X = 附加智力值；否则，X = 所有队友道具附加智力的最高值。

func on_trigger_20017()->bool:
	var x = actor.get_equip_feature_total("计策附加智力")
	if x <= 0:
		for wa in me.get_teammates(false, true):
			x = max(x, wa.actor().get_equip_feature_total("计策附加智力"))
	if x <= 0:
		return false
	change_scheme_chance(actorId, ske.skill_name, x)
	return false

func on_trigger_20029()->bool:
	var x = actor.get_equip_feature_total("计策附加智力")
	if x <= 0:
		for wa in me.get_teammates(false, true):
			x = max(x, wa.actor().get_equip_feature_total("计策附加智力"))
	if x <= 0:
		return false
	change_scheme_chance(actorId, ske.skill_name, x)
	return false
