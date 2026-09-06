extends "effect_20000.gd"

#援兵锁定技 #后备兵 #士兵分配
#【援兵】大战场，主动技。将城中的后备兵抽调给自己，使你兵力+300。每3回合限1次。


const EFFECT_ID = 20733
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_TROOPS = 300
const SOLDIERS_LIMIT = 2500

func effect_20733_start() -> void:
	if actor.get_soldiers() >= SOLDIERS_LIMIT:
		var msg = "兵员足备，无须后援"
		play_dialog(actorId, msg, 2, 2999)
		return
	var city = me.war_vstate().from_city()
	var troops = city.get_backup_soldiers()
	var cost = min(troops, COST_TROOPS)
	if troops <= 0:
		var msg = "{0}已无后备兵可用".format([city.get_full_name()])
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "{0}现有后备兵{1}\n调度至多{2}人增援\n可否？".format([
		city.get_full_name(), troops, cost,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20733_confirmed() -> void:
	var city = me.war_vstate().from_city()
	var troops = city.get_backup_soldiers()
	var cost = min(troops, COST_TROOPS)
	ske.cost_war_cd(3)
	var recover = ske.add_actor_soldiers(actorId, cost, 2500)
	ske.change_city_property(city.ID, "后备兵", -recover)
	ske.war_report()

	map.draw_actors()
	var msg = "{0}尚有余力，必挫{1}！\n（兵力增加{2}".format([
		city.get_full_name(), me.get_war_enemy_leader().get_name(),
		recover
	])
	play_dialog(actorId, msg, 0, 2999)
	return
