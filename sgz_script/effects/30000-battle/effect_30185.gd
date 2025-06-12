extends "effect_30000.gd"

#熟兵小战场效果
#【熟兵】大战场&小战场，锁定技。若你未装备「兵书」：大战场你使用计策时，知额外附加5点；小战场：初始阶段你的战术值+1。

func on_trigger_30005()->bool:
	if actor.get_jewelry().id == StaticManager.JEWELRY_ID_BINGSHU:
		return false
	ske.battle_change_tactic_point(1)
	ske.battle_report()
	return false
