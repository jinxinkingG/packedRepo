extends "effect_20000.gd"

#破竹被动效果
#【破竹】大战场，主将锁定技。你方回合，你方武将每击杀/俘虏一个敌将时，你方“武”排名前五的武将机动力+6。（若并列，允许超过五人）

const EFFECT_ID = 20287
const AP_GAIN = 6

func on_trigger_20027()->bool:
	# 触发武将的状态
	var targetActor = ActorHelper.actor(ske.actorId)
	if not targetActor.is_status_captured() and not targetActor.is_status_dead():
		return false

	# 判断是否我方回合
	var wf = DataManager.get_current_war_fight()
	if wf.current_war_vstate().id != me.wvId:
		return false

	# 判断来源是否我方武将
	var fromId = DataManager.get_env_int("战争.DISABLE.FROM")
	if fromId < 0:
		return false
	var from = DataManager.get_war_actor(fromId)
	if not me.is_teammate(from):
		return false

	# 简单插入排序
	var mostPowerful = []
	for wa in me.war_vstate().get_war_actors(false, true):
		var power = wa.actor().get_power()
		var i = 0
		while i < mostPowerful.size():
			if power >= mostPowerful[i][1]:
				break
			i += 1
		if i < mostPowerful.size():
			mostPowerful.insert(i, [wa, power])
		else:
			mostPowerful.append([wa, power])

	var affected = []
	var leastPower = -1
	for i in mostPowerful.size():
		if affected.size() > 5 and mostPowerful[i][1] < leastPower:
			break
		affected.append(mostPowerful[i][0])
		leastPower = mostPowerful[i][1]
	var names = []
	for wa in affected:
		ske.change_actor_ap(wa.actorId, AP_GAIN, false)
		names.append(wa.get_name())
	if names.size() > 3:
		names[2] += "等{0}人".format([names.size()])
		names = names.slice(0, 2)
	ske.war_report()
	# 统一更新一次光环，避免重复更新耗时
	SkillHelper.update_all_skill_buff(ske.skill_name)

	var msg = "势如破竹，克期灭敌！\n（{0}机动力+6".format(["、".join(names)])
	me.attach_free_dialog(msg, 0)
	return false
