extends "effect_20000.gd"

#良助锁定效果 #机动力
#【良助】大战场，锁定技。你方武将若因发动主动技能而消耗机动力，恢复其消耗的一半机动力值，至多15点，每回合限一次。

const EFFECT_ID = 20308
const AP_LIMIT = 15

func check_trigger_correct()->bool:
	var ap = get_env_int("战争.技能消耗机动力")
	ap = int(ap / 2)
	ap = min(AP_LIMIT, ap)
	if ap <= 0:
		return false
	if me.disabled:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	ske.cost_war_cd(1)
	ap = ske.change_actor_ap(wa.actorId, ap)
	ske.war_report()
	var msg = "凭我疾风势，助君青云力\n（{0}发动【良助】\n{1}回复{2}机动力".format([
		me.get_name(), wa.get_name(), ap,
	])
	me.attach_free_dialog(msg, 1)
	return false
