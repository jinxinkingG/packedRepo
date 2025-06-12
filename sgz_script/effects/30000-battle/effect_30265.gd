extends "effect_30000.gd"

#论势小战场效果
#【论势】大战场，主动技。消耗5机动力，发动后，下一次白刃战中，己方武将的士气至少比对方高1点。每3日限一次。

const ACTIVE_EFFECT_ID = 20529

func on_trigger_30005() -> bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	var wa = DataManager.get_war_actor(ske.actorId)
	enemy = wa.get_battle_enemy_war_actor()
	var x = enemy.battle_morale + 1 - wa.battle_morale
	var msg = get_message(wa, enemy, x)
	msg = msg.format([
		DataManager.get_actor_honored_title(wa.actorId, actorId),
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		actor.get_short_name(),
	])
	wa.attach_free_dialog(msg, 2, 30000, me.actorId)
	if x > 0:
		x = ske.battle_change_morale(x, wa)
		msg = "{0}【{1}】\n{2}部士气提升{3}".format([
			actor.get_name(), ske.skill_name,
			wa.get_name(), x,
		])
		wa.attach_free_dialog(msg, 2, 30000, -2)
	ske.battle_report()
	return false

func get_message(wa:War_Actor, enemy:War_Actor, x:int) -> String:
	if x <= 0:
		return "吾军壮勇绝伦\n{1}何能敌？\n更无须{2}多言耳"
	var a = wa.actor()
	var b = enemy.actor()
	var msgs = []
	if a.get_wisdom() > b.get_wisdom():
		msgs.append("{1}多谋少决\n{0}得策辄行\n此谋胜也")
	if a.get_soldiers() < b.get_soldiers():
		msgs.append("{1}好为虚势，不知兵要\n{0}以少克众，用兵如神\n此武胜也")
	if a.get_moral() > b.get_moral():
		msgs.append("{1}恤近忽远\n{0}虑无不周\n此仁胜也")
	if a.get_leadership() > b.get_leadership():
		msgs.append("{1}听谗惑乱\n{0}浸润不行\n此明胜也")
	if msgs.empty():
		msgs.append("{1}以逆动\n{0}以顺率\n此义胜也")
	msgs.shuffle()
	return msgs[0]
