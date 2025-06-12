extends "effect_20000.gd"

#酒戒锁定技
#【酒戒】大战场，锁定技。回合结束前，你与德＜50的队友相邻的场合：随机禁用你1个技能，直到下次对方回合结束，同时你的经验+500；若因此禁用了本技能，你立刻转移阵营。

const EFFECT_ID = 20392
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20016() -> bool:
	if SkillHelper.get_actor_skills(actorId).empty():
		return false
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		var wa = DataManager.get_war_actor_by_position(pos)
		if not me.is_teammate(wa):
			continue
		if wa.actor().get_moral() >= 50:
			continue
		var key = "战争.酒戒.武将.{0}".format([actorId])
		DataManager.set_env(key, wa.actorId)
		return true
	return false

func effect_20392_AI_start():
	goto_step("start")
	return

func effect_20392_start():
	var key = "战争.酒戒.武将.{0}".format([actorId])
	var fromId = DataManager.get_env_int(key)
	var msg = "今日无事\n{0}且饮此杯".format([
		DataManager.get_actor_honored_title(actorId, fromId),
	])
	play_dialog(fromId, msg, 1, 2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20392_2():
	var key = "战争.酒戒.武将.{0}".format([actorId])
	var fromId = DataManager.get_env_int(key)
	var msg = "{0}恕罪\n我从天戒，不饮酒".format([
		DataManager.get_actor_honored_title(fromId, actorId),
	])
	play_dialog(actorId, msg, 3, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20392_3():
	var key = "战争.酒戒.武将.{0}".format([actorId])
	var fromId = DataManager.get_env_int(key)
	var skillNames = []
	for skill in SkillHelper.get_actor_skills(actorId):
		skillNames.append(skill.name)
	skillNames.shuffle()
	var banned = skillNames[0]
	ske.ban_war_skill(actorId, banned, 2)
	ske.change_actor_exp(actorId, 500)
	ske.war_report()
	var msg = "大丈夫如何不饮酒？\n真乃笑话！\n（{0}【{1}】被禁用".format([
		me.get_name(), banned,
	])
	if banned != ske.skill_name or actor.get_loyalty() == 100:
		play_dialog(fromId, msg, 0, 2999)
		return
	play_dialog(fromId, msg, 0, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20392_4():
	var msg = "委实不能饮矣..."
	play_dialog(actorId, msg, 3, 2003)
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

func effect_20392_5():
	var key = "战争.酒戒.武将.{0}".format([actorId])
	var fromId = DataManager.get_env_int(key)
	var msg = "你违我将令！\n该打一百！"
	play_dialog(fromId, msg, 0, 2004)
	return

func on_view_model_2004():
	wait_for_skill_result_confirmation(FLOW_BASE + "_6")
	return

func effect_20392_6():
	var key = "战争.酒戒.武将.{0}".format([actorId])
	var fromId = DataManager.get_env_int(key)
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	me.actor_surrend_to(enemyWV.id)
	var msg = "匹夫欺人太甚！\n此地留不得了！\n（{0}转投{1}军".format([
		me.get_name(), enemyWV.get_lord_name(),
	])
	play_dialog(me.actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation("")
	return
