extends "effect_20000.gd"

#枕戈效果
#【枕戈】大战场，锁定技。你的机动力上限+X（X=装备提供的攻击力）

func on_trigger_20013():
	if me.dic_other_variable.has(ske.skill_name):
		return false
	me.dic_other_variable[ske.skill_name] = 1
	if not me.dic_other_variable.has("额外机上限"):
		me.dic_other_variable["额外机上限"] = 0
	me.dic_other_variable["额外机上限"] += int(actor.get_equip_attr_total("攻击力"))
	return false
