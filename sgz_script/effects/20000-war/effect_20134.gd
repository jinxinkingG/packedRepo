extends "effect_20000.gd"

#幕后效果实现
#【幕后】大战场,锁定技。与你相邻的己方武将计策列表和你一样

func on_trigger_20004()->bool:
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return false
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))

	var who = DataManager.get_war_actor(ske.actorId)
	if who == null or who.disabled:
		return false
	if not me.is_teammate(who):
		return false
	if Global.get_distance(who.position, me.position) != 1:
		return false
	var replaced = get_env("战争.计策替换")
	if typeof(replaced) != TYPE_DICTIONARY:
		replaced = {}
	var costRequired = true
	var learned = {}
	for scheme in schemes:
		var name = str(scheme[0])
		var cost = int(scheme[1])
		var ext = ""
		if scheme.size() > 2:
			ext = str(scheme[2])
		if costRequired and cost == 0:
			costRequired = false
		learned[name] = [cost, ext]
	schemes = []
	for scheme in me.get_stratagems():
		var name = scheme.name
		if name in replaced:
			name = replaced[name]
			if not name in StaticManager.stratagemDic:
				continue
		var cost = 0
		var ext = ""
		if name in learned:
			cost = learned[name][0]
			ext = learned[name][1]
		elif costRequired:
			cost = scheme.get_cost_ap(who.actorId)
		schemes.append([name, cost, ext])
	var msgs = Array(msg.split("\n"))
	msgs.append("已复刻{0}的计策".format([
		ActorHelper.actor(self.actorId).get_name()
	]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(ske.actorId, schemes, msg)
	return false
