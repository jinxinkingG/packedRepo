extends "effect_20000.gd"

#幻移效果 #减伤
#【幻移】大战场，锁定技。你被计策“火计/乱水/要击”伤兵后，你发动黄巾军秘术：转移一部分“即将被计策杀死的士兵”至友军。你方所有其他武将，兵力+X，X＝本次计策伤害*80%÷（你方人数-1），友军兵力恢复上限2500。若你方主将是“张角”，且队友有“张宝”，则任意队友都可以触发<幻移>。（对方获得20%经验）

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.name in ["火计", "乱水", "要击"]:
		return false
	if se.targetId != ske.actorId:
		return false
	var wv = me.war_vstate()
	if wv == null:
		return false
	var leader = wv.get_leader()
	if leader == null:
		return false
	var team = wv.get_war_actors(false, true)
	if team.size() <= 1:
		# 无人可以转移
		return false
	if ske.actorId != actorId:
		# 不是我触发的
		if leader.actorId != StaticManager.ACTOR_ID_ZHANGJIAO:
			# 主将不是张角
			return false
		var found = false
		for wa in team:
			if wa.actorId == StaticManager.ACTOR_ID_ZHANGBAO_HJ:
				# 找到张宝
				found = true
				break
		if not found:
			return false

	var damage = se.get_soldier_damage_for(ske.actorId)
	if damage <= 0:
		return false
	var transfer = int(damage*4/5)
	if transfer <= 0:
		return false
	var count = team.size() - 1
	var total = 0
	var recover = int((transfer - total) / count)
	var names = []
	for wa in team:
		if wa.actorId == ske.actorId:
			continue
		total += ske.add_actor_soldiers(wa.actorId, recover, 2500)
		names.append(wa.get_name())
		count -= 1
		if count <= 0:
			break
		recover = int((transfer - total) / count)
	if total <= 0:
		# 没有转移成功
		return false
	se.skip_redo = 1
	ske.war_report()

	if names.size() > 3:
		names[2] += "等{0}人".format([names.size()])
		names = names.slice(0, 2)
	var memo = ""
	if ske.actorId != actorId:
		var wa = DataManager.get_war_actor(ske.actorId)
		memo = "为" + wa.get_name()
	var msg = "太平在上，如律令敕！\n（【{0}】转移伤兵 {1}\n（移兵至{2}".format([
		ske.skill_name, transfer, "、".join(names), total, memo,
	])
	me.attach_free_dialog(msg, 0)
	return false
