extends "effect_30000.gd"

#骁雄小战场效果
#【骁雄】大战场，主将锁定技。你方武将使用持续性战术时，回合数+1。

func on_trigger_30010()->bool:
	var buffKey = "BUFF.{0}".format([ske.actorId])
	var buff = DataManager.get_env_str(buffKey)
	if not buff in StaticManager.CONTINUOUS_TACTICS:
		return false
	var buffDecFlagKey = "BUFF.DEC.{0}".format([ske.actorId])
	if DataManager.get_env_int(buffDecFlagKey) == 1:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	var buffStatus = wa.get_buff(buff)
	if buffStatus["回合数"] <= 0:
		return false
	if buffStatus["来源武将"] != wa.actorId:
		return false
	wa.set_buff(buff, int(buffStatus["回合数"]) + 1, wa.actorId, "", true)
	var msg = "{0}【{1}】令「{2}」回合数 +1".format([
		me.get_name(), ske.skill_name, buff,
	])
	ske.append_message(msg)
	ske.battle_report()
	return false
