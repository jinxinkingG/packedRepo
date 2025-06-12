extends "effect_20000.gd"

#枪神锁定技 #技能附加
#【枪神】大战场&小战场，锁定技。你武器为枪时，根据你的五行，自动附加技能：木和火附加<百鸟>，金和水附加<朝凤>，土附加<百鸟>、<朝凤>。

func appended_skill_list() -> PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	var actor = me.actor()
	if not "枪" in actor.get_weapon_types():
		return ret
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			ret.append("百鸟")
		War_Character.FivePhases_Enum.Fire:
			ret.append("百鸟")
		War_Character.FivePhases_Enum.Metal:
			ret.append("朝凤")
		War_Character.FivePhases_Enum.Water:
			ret.append("朝凤")
		War_Character.FivePhases_Enum.Earth:
			ret.append("百鸟")
			ret.append("朝凤")
	return ret

func on_trigger_20013()->bool:
	# 见面问候，与冲阵各自判定触发，只说一次
	if DataManager.get_env_int("战争.童渊弟子") > 0:
		return false
	var found = null
	for wa in wf.get_war_actors(false, true):
		if wa.actorId == me.actorId:
			continue
		if SkillHelper.actor_has_skills(wa.actorId, ["枪神", "冲阵"], true):
			found = wa
			break
	if found == null:
		return false
	var greeting = "同门上阵，当倍加奋发\n{0}尚能杀敌否？"
	var response = "{0}\n且看我今日武艺！"
	if me.is_enemy(found):
		greeting = "{0}久违\n不想今日刀兵相见"
		response = "战阵之上，各为其主\n请{0}赐教！"
	greeting = greeting.format([
		DataManager.get_actor_honored_title(found.actorId, me.actorId)
	])
	response = response.format([
		DataManager.get_actor_honored_title(me.actorId, found.actorId)
	])
	me.attach_free_dialog(greeting, 2)
	me.attach_free_dialog(response, 0, 20000, found.actorId)
	DataManager.set_env("战争.童渊弟子", 1)
	return false
