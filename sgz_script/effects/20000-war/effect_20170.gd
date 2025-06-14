extends "effect_20000.gd"

# 观星效果和限定技
#【观星】大战场,限定技。你可发动此技能，令你之后的一次<呼风>可选择方向。否则，你方武将用计时，你启用道术，使视野范围内的任何敌将与其距离均视为不超过6。☆制作组“黑铁”提示：使用伪击转杀、火箭、连弩、落石除外。

const EFFECT_ID = 20170
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20026():
	var setting = DataManager.get_env_dict("计策.ONCE.距离")
	for scheme in StaticManager.stratagems:
		if scheme.name == "火箭":
			continue
		if scheme.get_targeting_range(null) != 6:
			continue
		setting[scheme.name] = {
			"无限": 1,
			"最大距离": 6,
		}
	DataManager.set_env("计策.ONCE.距离", setting)
	return false

func effect_20170_start() -> void:
	var msg = "发动限定技【{0}】\n接下来的一次【呼风】可选择风向，可否？".format([
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20170_confirmed() -> void:
	var msg = "天象有变\n风随意转"
	ske.cost_war_cd(99999)
	ske.set_war_skill_val(1)
	ske.war_report()
	play_dialog(actorId, msg, 2, 2999)
	return

