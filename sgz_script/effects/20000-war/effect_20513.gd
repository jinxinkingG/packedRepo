extends "effect_20000.gd"

# 窥圣效果
#【窥圣】大战场，规则技。战争中，发生以下事件之一时，你永久失去<窥圣>，并获得<追义>：①双方移动后，你与敌方阵营的关羽相邻，你立刻转投关羽所在阵营；②你与关羽同阵营出战，关羽连杀3人后。

const GY = StaticManager.ACTOR_ID_GUANYU
const TARGET_SKILL = "追义"

func on_trigger_20003() -> bool:
	var moveType = DataManager.get_env_int("移动")
	var moveStopped = DataManager.get_env_int("结束移动")
	if moveType != 0 and moveStopped != 1:
		return false
	var wa = DataManager.get_war_actor(GY)
	if not me.is_enemy(wa) or not wa.has_position():
		return false
	if Global.get_distance(me.position, wa.position) != 1:
		return false
	var msg = "久闻{0}将军大名\n今得一见，真神人也！\n{1}愿弃暗投明，一任将军驱驰".format([
		ActorHelper.actor(GY).get_first_name(),
		actor.get_short_name(),
	])
	me.attach_free_dialog(msg, 2)
	msg = "（{0}转投{1}军\n（失去【{2}】\n（解锁【{3}】".format([
		actor.get_name(), wa.get_lord_name(),
		ske.skill_name, TARGET_SKILL,
	])
	me.attach_free_dialog(msg, 2)
	me.actor_surrend_to(wa.wvId)
	map.draw_actors()
	SkillHelper.ban_actor_skill(10000, actorId, ske.skill_name, 99999, actorId, ske.skill_name)
	SkillHelper.add_actor_scene_skill(10000, actorId, TARGET_SKILL, 99999, actorId, ske.skill_name)
	return false

func on_trigger_20020() -> bool:
	if ske.actorId != GY:
		return false
	var wa = DataManager.get_war_actor(GY)
	if not me.is_teammate(wa) or not wa.has_position():
		return false
	var defeatHistory = wf.get_env_array("击败武将")
	var total = 0
	for row in defeatHistory:
		if row[0] == GY:
			total += 1
	if total < 3:
		return false
	var msg = "{0}将军真神人也！\n某誓死追随！".format([
		ActorHelper.actor(GY).get_first_name(),
		actor.get_short_name(),
	])
	me.attach_free_dialog(msg, 2)
	msg = "（失去【{2}】\n（解锁【{3}】".format([
		actor.get_name(), wa.get_lord_name(),
		ske.skill_name, TARGET_SKILL,
	])
	me.attach_free_dialog(msg, 2)
	SkillHelper.ban_actor_skill(10000, actorId, ske.skill_name, 99999, actorId, ske.skill_name)
	SkillHelper.add_actor_scene_skill(10000, actorId, TARGET_SKILL, 99999, actorId, ske.skill_name)
	return false
