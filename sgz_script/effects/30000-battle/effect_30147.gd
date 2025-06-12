extends "effect_30000.gd"

#束巧锁定技
#【束巧】小战场,锁定技。你使用咒缚失败时，仍获得一回合咒缚效果

func on_trigger_30008()->bool:
	if get_tactic_name() != "咒缚":
		return false
	if get_tactic_result() != 0:
		return false
	ske.set_war_buff(actorId, "咒缚", 1)
	ske.war_report()
	var enemy = me.get_battle_enemy_war_actor()
	var msg = "战术失败，【{0}】发动\n{1}被咒止一回合".format([
		ske.skill_name, enemy.get_name()
	])
	me.attach_free_dialog(msg, 2, 30000)
	DataManager.set_env("结果", 1)
	DataManager.set_env("战斗.战术接管", 1)
	return false
