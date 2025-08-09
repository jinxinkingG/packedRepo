extends "effect_20000.gd"

# 穷守限定技
#【穷守】大战场，主将限定技。战争守方可发动，从城中调出备用兵，为你补充兵力，至多补充至2500，若如此，你直到战争结束前禁用计策列表。

const EFFECT_ID = 20631
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const LIMIT = 2500

func effect_20631_start() -> void:
	var city = wf.target_city()
	if city.get_backup_soldiers() <= 0:
		var msg = "{0}已无后备兵".format([city.get_full_name()])
		play_dialog(actorId, msg, 3, 2999)
		return
	if actor.get_soldiers() >= LIMIT:
		var msg = "兵员充足，无须补充".format([city.get_full_name()])
		play_dialog(actorId, msg, 2, 2999)
		return

	var msg = "从{0}抽调后备兵员\n自身禁用计策\n可否？".format([city.get_full_name()])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20631_confirmed() -> void:
	var city = wf.target_city()
	var total = city.get_backup_soldiers()

	ske.cost_war_cd(99999)
	var changed = ske.add_actor_soldiers(actorId, total, LIMIT)
	ske.change_city_property(city.ID, "后备兵", -changed)
	ske.set_war_buff(actorId, "禁策", 99)
	ske.war_report()

	var msg = "智可穷，力可尽，志不可夺！\n全军列阵，固守决胜！\n（已从{0}抽调{1}勇士".format([
		city.get_full_name(), changed,
	])
	play_dialog(actorId, msg, 2, 2999)
	return

