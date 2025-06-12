extends "effect_20000.gd"

#协力锁定技 #攻击机动力
#【协力】大战场，锁定技。你方其他武将伤兵计成功时，本回合你下一次攻击不消耗机动力。

#用计完成
func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	if se.get_action_id(me.actorId) == me.actorId:
		return false
	# 标记可行
	ske.set_war_skill_val(1, 1)
	return false

 #判断白刃攻击消耗
func on_trigger_20014()->bool:
	var dic = get_env_dict("战争.攻击消耗")
	if dic["攻击来源"] != actorId:
		return false
	if ske.get_war_skill_val_int() != 1:
		return false
	dic["固定"] = 0
	set_env("战争.攻击消耗", dic)
	return false

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if actorId != bf.get_attacker_id():
		return false
	if ske.get_war_skill_val_int() != 1:
		return false
	ske.set_war_skill_val(0, 0)
	me.attach_free_dialog("协力同心，金石辟易！\n（本次攻击不消耗机动力", 0)
	return false
