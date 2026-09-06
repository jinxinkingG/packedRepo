extends "effect_30000.gd"

# 泰然效果
#【泰然】小战场，锁定技。若你为白刃战守方，战斗开始时，你自动以可用的[士]补充兵员，上限2500。战斗结束后，剩余兵力的一半，返回[士]。（制作组提示：拥有与[士]相关技能，才能触发本技能。）

const FLAG_ID = 10068
const FLAG_NAME = "士"
const LIMIT = 2500

func on_trigger_30003() -> bool:
	if bf.get_defender_id() != actorId:
		return false
	if actor.get_soldiers() >= LIMIT:
		return false
	var flags = ske.get_skill_flags(10000, FLAG_ID, FLAG_NAME)
	if flags <= 0:
		return false
	var added = ske.add_actor_soldiers(actorId, flags, LIMIT)
	if added <= 0:
		return false
	ske.cost_skill_flags(10000, FLAG_ID, FLAG_NAME, added)
	ske.battle_report()

	var msg = "左右，沉着应战\n此用兵之时也\n（[{0}] {1} 加入战斗".format([
		FLAG_NAME, added
	])
	me.attach_free_dialog(msg, 2, 30000)
	return false

func on_trigger_30004() -> bool:
	var sendback = int(actor.get_soldiers() / 2)
	if sendback <= 0:
		return false
	sendback = ske.add_skill_flags(10000, FLAG_ID, FLAG_NAME, sendback, 3000)
	ske.sub_actor_soldiers(actorId, sendback)
	ske.war_report()
	return false
