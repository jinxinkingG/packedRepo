extends "effect_20000.gd"

#汉志效果 #解锁技能
#【汉志】大战场，锁定技。若当前战争中，你方没有可撤退的城池，你令主将获得技能<昭烈>。

const TARGET_SKILL = "昭烈"

func on_trigger_20013():
	if not DataManager.endless_model:
		if me.get_retreat_city_id() >= 0:
			return false

	# 无处可退，主将获得昭烈
	var leader = me.get_leader()
	if leader == null:
		return false

	ske.cost_war_cd(99999)
	ske.add_war_skill(leader.actorId, TARGET_SKILL, 99999)
	ske.set_war_skill_val(1, 99999)
	ske.war_report()

	var msg = "退无可退，境已绝矣\n父子君臣，便当背城一战！\n（{0}解锁【{1}】".format([
		leader.get_name(), TARGET_SKILL
	])
	me.attach_free_dialog(msg, 0)
	return false
