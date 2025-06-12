extends "effect_30000.gd"

# 焚营主动技
#【焚营】小战场，主动技。白刃战初始，你的战术值减半。你可发动此技能，获得4轮“火矢”＋“强弩”战术。

const EFFECT_ID = 30289
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_30005() -> bool:
	var reduced = int(me.battle_tactic_point / 2)
	ske.battle_change_tactic_point(-reduced)
	ske.battle_report()
	return false

func effect_30289_start()->void:
	ske.battle_cd(99999)
	var turnsA = ske.set_battle_buff(actorId, "强弩", 4)
	var turnsB = ske.set_battle_buff(actorId, "火矢", 4)
	ske.battle_report()

	var msg = "火雨强弓，摧破敌阵！\n（获得 {0} 回合强弩\n（获得 {1} 回合火矢".format([
		turnsA, turnsB
	])

	me.attach_free_dialog(msg, 2, 30000)
	tactic_end()
	return
