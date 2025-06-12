extends "effect_20000.gd"

#戈室锁定技
#【戈室】大战场，主将锁定技。敌方与你同姓的武将每有1名，你方所有武将“武”临时提升2点；己方与你同姓的武将每有1名，你方所有武将“统”临时提升2点。

func on_trigger_20013()->bool:
	var firstName = actor.get_first_name()
	var x = 0
	var y = 0
	var teammates = get_teammate_targets(me, 999)
	for targetId in teammates:
		if ActorHelper.actor(targetId).get_first_name() == firstName:
			x += 1
	for targetId in get_enemy_targets(me, true, 999):
		if ActorHelper.actor(targetId).get_first_name() == firstName:
			y += 1
	var targets = teammates
	targets.append(me.actorId)
	var powerChanged = []
	var leadershipChanged = []
	for targetId in targets:
		var prevX = 0
		var prevY = 0
		var prev = ske.get_war_skill_val_int_array(ske.effect_Id, targetId)
		if prev.size() == 2:
			prevX = prev[0]
			prevY = prev[1]
		if x != prevX:
			ske.change_war_leadership(targetId, (x - prevX) * 2)
			leadershipChanged.append(targetId)
		if y != prevY:
			ske.change_war_power(targetId, (y - prevY) * 2)
			powerChanged.append(targetId)
		ske.set_war_skill_val([x, y], 99999, ske.effect_Id, targetId)
	if powerChanged.size() + leadershipChanged.size() == 0:
		return false
	ske.war_report()
	if get_env_int("战争.戈室.宣言") > 0:
		# 一场战斗只喊一次
		return false
	var props = "武统"
	if powerChanged.empty():
		props = "统率"
	if leadershipChanged.empty():
		props = "武力"
	var msg = "同室操戈\n吾等何颜以对父亲！"
	if powerChanged.size() < leadershipChanged.size():
		msg = "兄弟外御其侮\n正当其时也！"
	msg += "\n（【{0}】强化众将{1}".format([ske.skill_name, props])
	append_free_dialog(me, msg, 0)
	set_env("战争.戈室.宣言", 1)
	return false
