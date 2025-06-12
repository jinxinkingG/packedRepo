extends "effect_20000.gd"

#峭嗣锁定技
#【峭嗣】大战场，锁定技。你攻击同姓武将时，不消耗机动力。回合结束阶段，你的经验值+X（X=回合内己方将领对与你同姓敌将的攻击次数*50，且X最大为5）。

func on_trigger_20014() -> bool:
	var setting = get_env_dict("战争.攻击消耗")
	if int(setting["攻击来源"]) != me.actorId:
		return false
	var targetId = int(setting["攻击目标"])
	if ActorHelper.actor(targetId).get_first_name() != actor.get_first_name():
		return false
	setting["固定"] = 0
	set_env("战争.攻击消耗", setting)
	return false

func on_trigger_20015() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_attacker_id():
		return false
	var targetId = bf.get_defender_id()
	if ActorHelper.actor(targetId).get_first_name() != actor.get_first_name():
		return false
	var times = ske.get_war_skill_val_int()
	ske.set_war_skill_val(times + 1, 1)
	return false

func on_trigger_20016() -> bool:
	var times = ske.get_war_skill_val_int()
	ske.set_war_skill_val(0, 0)
	if times <= 0:
		return false
	var x = min(times, 5) * 50
	ske.change_actor_exp(me.actorId, x)
	ske.war_report()
	return false
