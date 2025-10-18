extends "effect_20000.gd"

#排异锁定效果部分
#【排异】大战场，主动技。你通过<争功>获得的其他队友的主经验累计达到1500/3000/6000时，各增加1次发动本技能的机会。发动的回合结束时，你至多可挑选1名阴阳面的队友一起进入额外回合，只在此额外回合中：你视为拥有<奋困>，并对你和该队友之外的敌我将领均附加沉默状态。

const ACTIIVE_EFFECT_ID = 20452

func on_trigger_20013()->bool:
	if not DataManager.is_extra_war_round():
		return false
	# 判断排异发动标记
	var flags = ske.get_war_skill_val_int_array(ACTIIVE_EFFECT_ID)
	if flags.size() < 3 or flags[2] != 1:
		return false
	# 更新排异发动标记
	flags[2] = 2
	ske.set_war_skill_val(flags, 99999, ACTIIVE_EFFECT_ID)
	# 追加奋困
	ske.add_war_skill(actorId, "奋困", 1)
	# 沉默其他人
	for wa in wf.get_war_actors(false):
		if wa.actorId in [actorId, flags[0]]:
			continue
		wa.set_buff("沉默", 1, actorId)
	return false

func on_trigger_20016() -> bool:
	if not DataManager.is_extra_war_round():
		return false
	# 判断排异发动标记
	var flags = ske.get_war_skill_val_int_array(ACTIIVE_EFFECT_ID)
	if flags.size() < 3 or flags[2] != 2:
		return false
	# 所有人解除沉默（因沉默结算与额外回合配合有问题）
	for wa in wf.get_war_actors(false):
		var buffStatus = wa.get_buff("沉默")
		if buffStatus["回合数"] == 1 and buffStatus["来源武将"] == actorId:
			wa.set_buff("沉默", 0, actorId, ske.skill_name, true)
	return false
