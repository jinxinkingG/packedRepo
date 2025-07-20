extends "effect_20000.gd"

# 注经锁定技
#【注经】大战场，锁定技。你装备的书类道具所提供的“用计附加智力”效果，改为直接增加到你的“知”属性上。

func on_trigger_20013() -> bool:
	var disabled = me.get_ext_variable("装备词条禁用", [])
	disabled.erase("计策附加智力")
	me.set_ext_variable("装备词条禁用", disabled)
	var wisdom = actor.get_equip_feature_total("计策附加智力")
	var prev = ske.get_war_skill_val_int()
	ske.set_war_skill_val(wisdom)
	if wisdom != prev:
		ske.change_war_wisdom(actorId, wisdom - prev)
	ske.war_report()
	return false

func on_trigger_20017() -> bool:
	var disabled = me.get_ext_variable("装备词条禁用", [])
	disabled.erase("计策附加智力")
	disabled.append("计策附加智力")
	me.set_ext_variable("装备词条禁用", disabled)
	return false
