extends "effect_20000.gd"

#卜策效果实现
#【卜策】大战场,锁定技。你使用计策时，立即刷新对方五行点数，若你点数＞＝对方，则本次计策命中率+12%，否则本次计策命中率-3%

func on_trigger_20018()->bool:
	var se = DataManager.get_current_stratagem_execution()
	se.goback_disabled = 1
	var targetWA = DataManager.get_war_actor(se.targetId)
	if targetWA == null or targetWA.disabled:
		return false
	targetWA.refresh_poker_random()

	var op = ">="
	if me.get_poker_point_diff(targetWA) < 0:
		op = "<"
	var msg = "吉凶成败，皆由天意\n【{1}】点数{2} {3} {5}".format([
		me.get_name(), ske.skill_name, me.poker_point,
		op, targetWA.get_name(), targetWA.poker_point,
	])
	se.message += se.get_message() + "\n" + msg
	return false

func on_trigger_20017()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var targetWA = DataManager.get_war_actor(se.targetId)
	if targetWA == null or targetWA.disabled:
		return false
	var x = 12
	if me.get_poker_point_diff(targetWA) < 0:
		x = -3
	change_scheme_chance(me.actorId, ske.skill_name, x)
	return false
