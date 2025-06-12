extends "effect_20000.gd"

#知杰效果实现
#【知杰】大战场,锁定技。你的计策列表与你方智力最高者的计策列表相同。

func check_trigger_correct()->bool:
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return false
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))
	var replaced = get_env("战争.计策替换")
	if typeof(replaced) != TYPE_DICTIONARY:
		replaced = {}

	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false

	var actor = ActorHelper.actor(self.actorId)
	var maxInt = actor.get_wisdom()
	var maxLevel = actor.get_level()
	for targetId in get_teammate_targets(me, 9999):
		var targetActor = ActorHelper.actor(targetId)
		var curInt = targetActor.get_wisdom()
		if curInt > maxInt:
			maxInt = curInt
			maxLevel = max(maxLevel, targetActor.get_level())

	var learned = []
	var costRequired = true
	for scheme in schemes:
		learned.erase(str(scheme[0]))
		learned.append(str(scheme[0]))
		if costRequired and int(scheme[1]) == 0:
			costRequired = false
	var extended = false
	for scheme in me.get_stratagems(maxInt, maxLevel):
		var name = str(scheme.name)
		var cost = scheme.get_cost_ap(self.actorId)
		if name in learned:
			continue
		if name in replaced:
			continue
		if not costRequired:
			cost = 0
		schemes.append([name, cost, ""])
		extended = true
	if extended:
		var msgs = Array(msg.split("\n"))
		msgs.append("【知杰】增加可用计策")
		msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(self.actorId, schemes, msg)
	return false
