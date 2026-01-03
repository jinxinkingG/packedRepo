extends "effect_20000.gd"

# 百戏主动技
#【百戏】主动技。消耗5点机动力发动。随机附加一个大战场或小战场技能。每5回合限1次。

const EFFECT_ID = 20705
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20705_start() -> void:
	var msg = "发动【{0}】\n随机附加一个技能\n可否？".format([ske.skill_name])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20705_confirmed() -> void:
	ske.cost_war_cd(5)
	var skills = []
	for skill in StaticManager.get_all_possible_skills(actorId).values():
		var forWar = true
		for effect in skill.effects:
			if effect.id < 20000 or effect.id >= 40000:
				forWar = false
				break
		if not forWar:
			continue
		skills.append(skill)
	var rndIdx = DataManager.pseduo_random_war(skills.size())
	var skillName = skills[rndIdx].name
	var prev = ske.get_war_skill_val_str()
	if prev != "":
		ske.remove_war_skill(actorId, prev)
	ske.add_war_skill(actorId, skillName, 99999)
	ske.set_war_skill_val(skillName)
	var msg = "百戏一出，万法皆空！"
	report_skill_result_message(ske, 2001, msg, 1, actorId, false)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20705_report() -> void:
	report_skill_result_message(ske, 2001)
	return
