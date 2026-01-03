extends "effect_20000.gd"

#三策被动效果
#【三策】大战场，锁定技。每回合开始时，系统随机选择上中下三个计策。本回合结束前，上策、中策、下策，对应机动力消耗减为1/3、1/2、2/3。（向上取整，最少减到2）

const COST_DOWNS = [
	[1, 3.0],
	[1, 2.0],
	[2, 3.0],
]

func on_trigger_20005()->bool:
	var dic = ske.get_war_skill_val_dic()
	var settings = DataManager.get_env_dict("计策.消耗")
	var name = settings["计策"]
	var cost = int(settings["所需"])
	cost = get_scheme_cost(name, cost)
	reduce_scheme_ap_cost(name, cost)
	return false

func on_trigger_20004()->bool:
	var schemes = get_env_array("战争.计策列表")
	var msg = get_env_str("战争.计策提示")
	var names = ske.get_war_skill_val_array()
	var notes = ["上策", "中策", "下策"]
	for scheme in schemes:
		var cost = int(scheme[1])
		cost = get_scheme_cost(scheme[0], cost)
		if cost <= 0:
			continue
		scheme[1] = cost
		var idx = names.find(scheme[0])
		if idx >= 0 and idx < notes.size():
			if scheme.size() == 2:
				scheme.append("")
			scheme[2] = notes[idx]
#	if msg.split("\n").size() < 3:
#		msg += "\n因【三策】计策消耗降低"
	change_stratagem_list(me.actorId, schemes, msg)
	return false

func on_trigger_20013()->bool:
	var schemes = me.get_stratagems()
	schemes.shuffle()
	var names = []
	var msgs = []
	for i in 3:
		if i >= schemes.size():
			break
		names.append(schemes[i].name)
		var msg = "{0}的消耗将减至{1}/{2}".format([schemes[i].name, COST_DOWNS[i][0], int(COST_DOWNS[i][1])])
		msgs.append(msg)
		ske.append_message(msg)
	ske.set_war_skill_val(names, 1)
	ske.war_report()
	me.attach_free_dialog("吾有三策，各尽其妙", 1)
	me.attach_free_dialog("\n".join(msgs), 1)
	return false

func get_scheme_cost(name:String, cost:int)->int:
	var names = ske.get_war_skill_val_array()
	var idx = names.find(name)
	if idx < 0 or idx >= COST_DOWNS.size():
		return -1
	var costDown = COST_DOWNS[idx]
	cost = int(ceil(cost * costDown[0] / costDown[1]))
	cost = max(2, cost)
	return cost
