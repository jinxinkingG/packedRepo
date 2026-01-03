extends "res://script/controls.gd"

const RESPONSES = [
	[["却之不恭", 2], ["受之有愧", 2]],
	[["谢{0}厚情", 1], ["谢{0}殊遇", 1]],
	[["谢{0}厚情，唯马首是瞻", 1], ["谢{0}殊遇，当粉身以报", 1]],
]

# 君主为武将加忠，包含了统一计算逻辑
# @return [反馈应答, 反馈表情]
func add_actor_loyalty(
	city:clCity.CityInfo,
	lord:ActorHelper.ActorInfo,
	actor:ActorHelper.ActorInfo,
	gold:int,
	treasure:int=0) -> Array:
	# 效果等级，影响应答
	# 目前设定：默认 0，相性完全契合 +1，效果好（忠诚度 80+）+1
	var level = 0
	# 宝和金的应答不一样
	var idx = 1 if treasure > 0 else 0

	var moral = lord.get_moral()
	# 考虑相性
	var distance = 35
	if SkillRangeBuff.max_val_for_city("唯才是举", city.ID) > 0:
		distance = 0
	elif SkillRangeBuff.max_val_for_vstate("唯才是举", city.get_vstate_id()) > 0:
		distance = 0
	else:
		distance = lord.personality_distance(actor)
	if distance == 0:
		level += 1
		# 完全匹配，视为德 90
		moral = max(90, moral)
	elif distance <= 10:
		# 比较亲近，视为德提升
		moral = max(moral, int((200 + moral) / 3))
	var current = actor.get_loyalty()
	var cost = gold
	var extended = 0
	# 赏赐宝，忠诚上升 = 赏 100 金幅度 + 1~5
	if treasure > 0:
		cost = 100
		extended = randi() % 5 + 1
		city.add_city_property("宝", -treasure)
	if gold > 0:
		# 赏赐金，忠诚上升=君主德/10+消耗金额/20
		city.add_gold(-gold)
	var val = int(moral/10) + int(cost/20) + extended
	var added = actor.add_loyalty(val)
	var extra = SkillRangeBuff.max_val_for_city("赏赐武将效果", city.ID)
	if extra > 0:
		extra = actor.add_loyalty(extra)
	else:
		extra = 0
	var extra2 = 0
	if actor.get_moral() < 50 and current < 70:
		extra2 = SkillRangeBuff.max_val_for_city("赏金低德武将效果", city.ID)
		if extra2 > 0:
			extra2 = actor.add_loyalty(extra2)
			if extra2 > 0:
				extra += extra2
	if actor.get_loyalty() >= 80:
		level += 1
	level = min(RESPONSES.size() - 1, level)

	# 决定应答
	var msg = RESPONSES[level][idx][0] + "\n（忠诚度上升{1}，现为{2}"
	if extra > 0:
		msg = RESPONSES[level][idx][0] + "\n忠诚度上升{1} (+{3})\n现为{2}"
	var mood = RESPONSES[level][idx][1]
	if extra2 > 0:
		msg = "却之不恭，多多益善\n忠诚度上升{1} (+{3})\n现为{2}"
		mood = 1
	msg = msg.format([
		DataManager.get_actor_honored_title(lord.actorId, actor.actorId),
		added, actor.get_loyalty(), extra
	])

	return [msg, mood]

