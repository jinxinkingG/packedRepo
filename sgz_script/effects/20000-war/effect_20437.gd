extends "effect_20000.gd"

#摧枯锁定技 #解锁技能
#【摧枯】大战场，锁定技。本次战争中，你使用伤兵计累计造成伤害达到1500/3000/5000时，己方势力的组队经验倍率分别提升10%/20%/40%(不叠加)，直到战争结束。

const BUFF_EFFECT_ID = 20438
const DAMAGE_EVENTS = [
	[1500, 10],
	[3000, 20],
	[5000, 40],
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
	var current = ske.get_war_skill_val_int(BUFF_EFFECT_ID)
	var rate = 0
	for ev in DAMAGE_EVENTS:
		if total < ev[0]:
			continue
		rate = max(rate, ev[1])
	ske.set_war_skill_val(rate, 99999, BUFF_EFFECT_ID)
	if rate <= current:
		return false
	SkillHelper.update_all_skill_buff("摧枯")
	ske.war_report()
	var msg = "摧枯拉朽，当者披靡！\n【{0}】伤害已达{1}\n我军获得 {3}% 团队经验加成".format([
		ske.skill_name, total,
		me.war_vstate().get_lord_name(), rate,
	])
	me.attach_free_dialog(msg, 0)
	return false
