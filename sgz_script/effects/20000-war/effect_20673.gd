extends "effect_20000.gd"

# 龙聚效果
#【龙聚】大战场，诱发技。己方其他武将发动<龙胆>、<八阵>的场合：你可移动到该武将周围的一个空位。并使该武将获得你一半机动力。每回合限1次

const EFFECT_ID = 20673
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20040() -> bool:
	if ske.actorId == actorId:
		return false
	var prevSkeData = DataManager.get_env_dict("战争.完成技能")
	if prevSkeData.empty():
		return false
	var prevSke = SkillEffectInfo.new()
	prevSke.input_data(prevSkeData)
	if prevSke.effect_type != "主动":
		return false
	if not prevSke.skill_name in ["龙胆", "八阵"]:
		return false
	# 判断目标位置
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled or not wa.has_position():
		return false
	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if me.position == pos:
			continue
		if not me.can_move_to_position(pos):
			continue
		positions.append(pos)
	if positions.empty():
		return false
	DataManager.set_env("技能.触发." + ske.skill_name, prevSke.skill_name)
	return true

func effect_20673_AI_start() -> void:
	# AI 随机选择一个位置
	var wa = DataManager.get_war_actor(ske.actorId)
	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if me.position == pos:
			continue
		if not me.can_move_to_position(pos):
			continue
		positions.append(pos)
	if positions.empty():
		skill_end_clear()
		return
	positions.shuffle()
	DataManager.set_target_position(positions[0])
	goto_step("selected")
	return

func effect_20673_start() -> void:
	var wa = DataManager.get_war_actor(ske.actorId)
	var positions = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = wa.position + dir
		if me.position == pos:
			continue
		if not me.can_move_to_position(pos):
			continue
		positions.append(pos)
	if positions.empty():
		skill_end_clear()
		return
	var msg = "选择【{0}】发动点".format([ske.skill_name])
	wait_choose_positions(positions, msg)
	return

func on_view_model_2000() -> void:
	wait_for_choose_position(FLOW_BASE + "_selected")
	return

func effect_20673_selected() -> void:
	var pos = DataManager.get_target_position()
	var ap = int(me.action_point / 2)

	ske.cost_war_limited_times(2)
	ske.change_war_actor_position(actorId, pos)
	if ap > 0:
		ske.change_actor_ap(actorId, -ap)
		ske.change_actor_ap(ske.actorId, ap)
	ske.war_report()

	var msg = "{0}慢些，{1}来啦"
	var mood = 1
	var source = DataManager.get_env_str("技能.触发." + ske.skill_name)
	if source == "八阵":
		msg = "{0}神算，带我看看"
		if ske.actorId != StaticManager.ACTOR_ID_ZHUGELIANG:
			msg = "{0}这阵法，好像见过 ……"
			mood = 2
	msg += "\n（发动【{2}】\n（交予{3} {4}机动力"
	msg = msg.format([
		DataManager.get_actor_honored_title(ske.actorId, actorId),
		DataManager.get_actor_self_title(actorId), ske.skill_name,
		ActorHelper.actor(ske.actorId).get_name(), ap,
	])
	play_dialog(actorId, msg, mood, 2990)
	return
