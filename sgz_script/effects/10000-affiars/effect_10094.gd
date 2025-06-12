extends "effect_10000.gd"

#正礼效果
#【正礼】内政，锁定技。每月你所在城有30%概率触发以下事件，若触发成功则进入2个月的技能冷却。①你非太守，且太守德<50:太守举办奢侈的宴会，被你当面呵斥，太守和额外3名德<50的随机将领德+1。②你非君主，且君主德<90:君主穿衣过于随意，被你劝阻，德+1。

const CHANCE = 30

func on_trigger_10001()->bool:
	if DataManager.get_scene_actor_control(actorId) < 0:
		# 非玩家控制不发动
		return false
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	if chance_for_event_1(cityId):
		ske.affair_cd(2)
		return false
	if chance_for_event_2(cityId):
		ske.affair_cd(2)
		return false
	return false

func chance_for_event_1(cityId:int)->bool:
	var city = clCity.city(cityId)
	var leaderId = city.get_leader_id()
	if leaderId == actorId:
		return false
	var leader = ActorHelper.actor(leaderId)
	if leader.get_moral() >= 50:
		return false
	if not Global.get_rate_result(CHANCE):
		return false
	# 办宴会
	var participants = []
	for participantId in city.get_actor_ids():
		if participantId == actorId:
			continue
		if participantId == leaderId:
			continue
		var participant = ActorHelper.actor(participantId)
		if participant.get_moral() >= 50:
			continue
		participants.append(participant)
	participants.shuffle()
	if participants.size() > 3:
		participants = participants.slice(0, 2)
	var nicks = []
	var names = []
	for p in participants:
		names.append(p.get_name())
		nicks.append(DataManager.get_actor_honored_title(p.actorId, leaderId))
	var msg = "今日无事，不如宴饮\n唤吾家歌姬来，献舞助兴！\n"
	city.attach_free_dialog(msg, leaderId, 1)
	if participants.empty():
		msg = "独饮西楼，月何皎皎~\n"
	else:
		msg = "与{0}同乐！\n".format(["、".join(nicks)])
	msg += "{0}哪里去，快快入座？".format([
		DataManager.get_actor_honored_title(actorId, leaderId)
	])
	city.attach_free_dialog(msg, leaderId, 1)
	msg = "民无生息于外\n礼崩乐坏于内\n国家何安！"
	city.attach_free_dialog(msg, actorId, 0)
	msg = "{0}之言是也\n谨受教".format([
		DataManager.get_actor_honored_title(actorId, leaderId)
	])
	city.attach_free_dialog(msg, leaderId, 2)
	leader.set_moral(leader.get_moral() + 1)
	for p in participants:
		p.set_moral(p.get_moral() + 1)
	msg = "{0}【{1}】劝谏\n{2}德+1"
	if participants.size() > 0:
		msg = "{0}【{1}】劝行止\n{2}、{3}等德+1"
	msg = msg.format([
		actor.get_name(), ske.skill_name,
		leader.get_name(), "、".join(names)
	])
	city.attach_free_dialog(msg, -1, 2)
	return true

func chance_for_event_2(cityId:int)->bool:
	var city = clCity.city(cityId)
	var lordId = city.get_lord_id()
	if lordId == actorId:
		return false
	var lord = ActorHelper.actor(lordId)
	if lord.get_moral() >= 90:
		return false
	if not Global.get_rate_result(CHANCE):
		return false
	# 正衣冠
	var msg = "见过主公\n主公何处归来？"
	city.attach_free_dialog(msg, actorId, 2)
	msg = "巡游方回\n{0}必有要事？".format([
		DataManager.get_actor_honored_title(actorId, lordId),
	])
	city.attach_free_dialog(msg, lordId, 2)
	msg = "臣无他事，只是主公服饰非常\n绣帽薄衫，半袖缥绫\n不知是何礼仪？\n"
	city.attach_free_dialog(msg, actorId, 2)
	msg = "... ..."
	city.attach_free_dialog(msg, lordId, 2)
	lord.set_moral(lord.get_moral() + 1)
	msg = "{0}【{1}】正衣冠\n{2}德+1"
	msg = msg.format([
		actor.get_name(), ske.skill_name, lord.get_name(),
	])
	city.attach_free_dialog(msg, -1, 2)
	return true
