extends "effect_30000.gd"

#戏敌效果实现
#【戏敌】小战场，锁定技。敌方挑衅失败时，你方士气不扣减，由对方代扣，同时你增加4点战术值。

func on_trigger_30012():
	if me == null or enemy == null:
		return false
	ske.battle_change_morale(4, me)
	ske.battle_change_tactic_point(4, me)
	ske.battle_change_morale(-4, enemy)
	ske.battle_report()

	var msg = "小儿徒逞匹夫之勇！\n（{1}发动【戏敌】，战术+4，{0}士气下降".format([
		enemy.get_name(), me.get_name(),
	])
	DataManager.set_env("对话", msg)
	DataManager.set_env("对话表情", 1)
	DataManager.set_env("对话武将", me.actorId)
	return false
