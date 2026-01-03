extends "effect_20000.gd"

# 特达主动技
#【特达】大战场，主动技。发动时身上所有buff及附加技能的持续时间，改为持续到第2个你方回合的结束阶段。每3回合限1次。

const EFFECT_ID = 20697
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20697_start() -> void:
	var buffs = me.get_buff_names("大战场")
	var skills = SkillHelper.get_actor_scene_skills(actorId, 20000)
	if buffs.empty() and skills.empty():
		var msg = "没有可以发动【{0}】的状态或技能".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = ""
	if not buffs.empty():
		if buffs.size() == 1:
			msg += "[{0}] 状态".format([buffs[0]])
		else:
			msg += "[{0}][{1}] 等{2}状态".format([buffs[0], buffs[1], buffs.size()])
	if not skills.empty():
		if msg != "":
			msg += "\n及"
		if skills.size() == 1:
			msg += "【{0}】技能".format([skills[0]["skill_name"]])
		else:
			msg += "【{0}】【{1}】等{2}技能".format([
				skills[0]["skill_name"], skills[1]["skill_name"], skills.size()
			])
	
	msg += "\n将持续两回合，可否？"
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20697_confirmed() -> void:
	var buffs = me.get_buff_names("大战场")
	for buff in buffs:
		ske.set_war_buff(me.actorId, buff, 2)
	var skills = SkillHelper.get_actor_scene_skills(actorId, 20000)
	for skill in skills:
		ske.add_war_skill(actorId, skill["skill_name"], 2)
	ske.cost_war_cd(3)
	var msg = "吾文武通达，何往不利！"
	report_skill_result_message(ske, 2001, msg, 0)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20697_report() -> void:
	report_skill_result_message(ske, 2001)
	return
