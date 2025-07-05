extends "effect_20000.gd"

#困名锁定技
#【困名】大战场，锁定技。结束阶段，若你是己方机动力最高的武将，将机动力平均分给己方所有将领。

func on_trigger_20016()->bool:
	var wv = me.war_vstate()
	if wv == null:
		return false
	var ap = me.action_point
	if ap <= 0:
		return false
	var teammates = []
	for wa in wv.get_war_actors(false):
		if wa.actorId == actorId:
			continue
		if wa.action_point > me.action_point:
			return false
		teammates.append(wa)
	if teammates.empty():
		return false
	ske.change_actor_ap(actorId, -ap, false)
	var left = ap
	while not teammates.empty():
		var wa = teammates.pop_front()
		var shared = int(left / (teammates.size() + 1))
		left -= shared
		ske.change_actor_ap(wa.actorId, shared, false)
	ske.war_report()
	# 统一更新一次光环，避免重复更新耗时
	SkillHelper.update_all_skill_buff(ske.skill_name)

	var msg = "此名望之重也 … …\n（【{0}】效果\n（将 {1} 机动力平分给众将".format([
		ske.skill_name, ap,
	])
	me.attach_free_dialog(msg, 3)
	return false
