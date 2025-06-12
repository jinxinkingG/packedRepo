extends "effect_20000.gd"

#连破锁定技 #解锁技能
#【连破】大战场,锁定技。本次战争中，你使用伤兵计累计造成的伤害达到1500/3000/5000时，你将依次获得<看破>/<度势>/<神威>，直到战争结束。

const DAMAGE_EVENTS = [
	[1500, "看破"],
	[3000, "度势"],
	[5000, "神威"],
]

func on_trigger_20004()->bool:
	var total = ske.get_war_skill_val_int()
	if total <= 0:
		return false
	var schemes = DataManager.get_env_array("战争.计策列表")
	var msg = DataManager.get_env_str("战争.计策提示")
	var msgs = Array(msg.split("\n"))
	msgs.append("【{0}】伤害：{1}".format([ske.skill_name, total]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(actorId, schemes, msg)
	return false

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != actorId:
		return false
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	# 累加伤兵量
	var damage = se.get_total_damage()
	var total = ske.get_war_skill_val_int()
	ske.set_war_skill_val(total + damage, 99999)
	_check_damage_events()
	return false

func _check_damage_events():
	var total = ske.get_war_skill_val_int()
	if total <= 0:
		return false
	var added = []
	for ev in DAMAGE_EVENTS:
		if total < ev[0]:
			continue
		var skill = str(ev[1])
		if SkillHelper.actor_has_skills(actorId, [skill]):
			continue
		var skills = []
		ske.add_war_skill(me.actorId, skill, 99999)
		added.append(skill)
	if added.empty():
		return false
	ske.war_report()
	var msg = "敌势已破，乘胜追击！\n（{0}解锁技能：{1}".format([
		me.get_name(), "、".join(added),
	])
	me.attach_free_dialog(msg, 0)
	return false
