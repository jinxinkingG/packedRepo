extends "effect_20000.gd"

#窥圣效果
#【窥圣】大战场，锁定技。你在场时，敌方关羽计策表增加“笼络”，关羽对你使用的<笼络>必定成功。那之后，你的忠变为90，永久失去该技能，并获得<追义>。

const TARGET_SKILL = "追义"

func on_trigger_20038() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.name != "笼络":
		return false
	if se.targetId != actorId:
		return false
	var fromId = se.get_action_id(actorId)
	if fromId != StaticManager.ACTOR_ID_GUANYU:
		return false
	se.skip_redo = 1
	se.set_must_success(actorId, ske.skill_name)
	var msg = "{0}将军，真神人也！\n（失去【{1}】\n（解锁【{2}】".format([
		ActorHelper.actor(fromId).get_name(),
		ske.skill_name,
		TARGET_SKILL,
	])
	me.attach_free_dialog(msg, 2)
	ske.set_war_skill_val(1, 1)
	return false

func on_trigger_20012() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		return false
	ske.set_war_skill_val(0, 0)
	SkillHelper.ban_actor_skill(10000, actorId, ske.skill_name, 99999, actorId, ske.skill_name)
	SkillHelper.add_actor_scene_skill(10000, actorId, TARGET_SKILL, 99999, actorId, ske.skill_name)
	actor.set_loyalty(90)
	return false
