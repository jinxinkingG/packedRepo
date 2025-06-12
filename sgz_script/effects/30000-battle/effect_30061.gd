extends "effect_30000.gd"

#传教锁定技部分
#【传教】小战场,主动技。非城地形：每回合结束前，对方每个士兵单位的兵力-x，你方所有士兵单位，平分对方减少的总兵力，每个单位最高300兵力。x＝你的等级/2，向下取整，持续3回合，显示特殊图标。

# 锁定技判断
func on_trigger_30059():
	if me.get_buff_label_turn(["传教"]) <= 0:
		return false

	var x = int(ceil(actor.get_level() / 2))
	# 记录总兵力
	var total = 0.0
	# 计算我军部队数
	var myUnits = []
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.get_unit_type() == "将":
			continue
		if bu.leaderId == me.actorId:
			myUnits.append(bu)
			continue
		bu.wait_action_name = "减体|-{0}".format([x])
		ske.battle_change_unit_hp(bu, -x)
		total += x

	if total <= 0:
		return false

	if not myUnits.empty():
		var extraHP = total * 1.0 / myUnits.size()
		for bu in myUnits:
			ske.battle_change_unit_hp(bu, extraHP)
	ske.battle_report()

	return false
