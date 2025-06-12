extends "effect_20000.gd"

# 荡寇效果
#【荡寇】大战场，锁定技。你对武力不大于你的敌将发起攻击宣言时，对方其他武将不能响应此攻击将技能发动。

func on_trigger_20015() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != actorId:
		return false
	if actor.get_power() < bf.get_target().actor().get_power():
		return false
	bf.set_env("禁止守方诱发", [ske.skill_name, actorId])
	me.attach_free_dialog("荡寇诛邪，群丑辟易！\n（本次攻击守方诱发技禁用", 0)
	return false
