extends "effect_20000.gd"

#镇中锁定技
#【镇中】大战场，锁定技。你进言你方主将，令其坐镇中军，不动如山，以稳定军心。战争初始记录你方主将大战场位置坐标，并令其临时附加<德服>，你方主将大战场位置坐标改变后，其失去该附加<德服>。

const TARGET_SKILL = "德服"

func on_trigger_20013() -> bool:
	var leader = me.get_leader()
	if leader == null or leader.actorId == actorId:
		return false
	var enemyLeader = me.get_war_enemy_leader()
	if enemyLeader == null:
		return false
	var pos = ske.get_war_skill_val_int_array()
	if pos.size() == 3:
		return false
	ske.set_war_skill_val([leader.actorId, leader.position.x, leader.position.y])
	ske.add_war_skill(leader.actorId, TARGET_SKILL, 99999)
	var msg = "{0}守备合度\n{1}不可轻动\n但看我等破敌"
	if me.war_vstate().is_defender():
		msg = "{0}来势汹汹\n{1}不可轻动\n稳守自当无虞"
	msg = msg.format([
		DataManager.get_actor_naughty_title(enemyLeader.actorId),
		DataManager.get_actor_honored_title(leader.actorId),
	])
	me.attach_free_dialog(msg, 2)
	msg = "因{0}【{1}】\n{2}获得【{3}】".format([
		actor.get_name(), ske.skill_name,
		leader.get_name(), TARGET_SKILL,
	])
	me.attach_free_dialog(msg, 2, 20000, -2)
	return false

func on_trigger_20027() -> bool:
	var leader = me.get_leader()
	if leader == null or leader.actorId == actorId:
		return false
	ske.remove_war_skill(leader.actorId, TARGET_SKILL)
	return false

func on_trigger_20031() -> bool:
	var leader = me.get_leader()
	if leader == null or leader.actorId == actorId:
		return false
	var pos = ske.get_war_skill_val_int_array()
	if pos.size() != 3:
		return false
	if leader.actorId == pos[0] \
		and leader.position.x == pos[1]\
		and leader.position.y == pos[2]:
		return false
	ske.remove_war_skill(leader.actorId, TARGET_SKILL)
	return false

