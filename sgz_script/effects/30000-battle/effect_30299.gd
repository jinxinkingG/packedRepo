extends "effect_30000.gd"

# 决死效果
#【决死】小战场，锁定技。你0兵进入白刃战时：不受降胆负面状态影响，白刃战初始，获得X回合[士气向上]效果。X=你的胆/10

func on_trigger_30005() -> bool:
	if me.get_soldiers() > 0:
		return false
	var x = int(me.battle_courage / 10)
	if x <= 0:
		return false
	x = bf.set_buff(actorId, "士气向上", x)
	var msg = "将军岂有卧床而终\n今当决死一战！\n（【{0}】获得{1}回合士气向上".format([
		ske.skill_name, x,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
