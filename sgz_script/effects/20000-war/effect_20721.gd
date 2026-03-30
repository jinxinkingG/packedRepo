extends "effect_20000.gd"

# 神威的大战场效果
#【神威】小战场，主动技。发动后，持续X回合，对方所有士兵单位行动次数-1。每个大战场回合限1次。\nX = 2 + [本次战争你已经击杀/俘虏敌将的次数]\nX 最大为 4。

const ACTIVE_EFFECT_ID = 30314

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null or not loser.disabled:
		return false
	var winner = bf.get_winner()
	if winner == null or winner.actorId != actorId:
		return false
	var times = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	ske.set_war_skill_val(times + 1, 99999, ACTIVE_EFFECT_ID)
	return false
