extends "effect_20000.gd"

# 救主诱发技 #截击
#【救主】大战场,诱发技。你方主将小战场撤退时，你可以发动：对追击你方主将者，发起战斗宣言。

const EFFECT_ID = 20222
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20020() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if me == null or me.disabled:
		return false
	var loser = bf.get_loser()
	if loser == null or loser.disabled:
		return false
	if loser.actorId != ske.actorId:
		return false
	if ske.actorId == actorId:
		return false
	if loser.actorId != me.get_main_actor_id():
		return false
	var target = loser.get_battle_enemy_war_actor()
	if target == null or target.disabled:
		return false
	if check_combat_targets([target.actorId]).empty():
		# 如果不可攻击，也不需要进入战斗
		return false
	return true

func effect_20222_AI_start() -> void:
	goto_step("2")
	return

func effect_20222_start() -> void:
	var bf = DataManager.get_current_battle_fight()
	var leader = bf.get_loser()
	var target = leader.get_battle_enemy_war_actor()

	var msg = "{0}败退\n发动【{1}】，截击{2}\n可否？".format([
		leader.get_name(), ske.skill_name, target.get_name(),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	map.next_shrink_actors = [target.actorId, leader.actorId]
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20222_2() -> void:
	var bf = DataManager.get_current_battle_fight()
	var leader = bf.get_loser()
	var target = leader.get_battle_enemy_war_actor()

	var msg = "{0}速退，{1}在此\n{2}休得张狂！".format([
		DataManager.get_actor_honored_title(leader.actorId, me.actorId),
		DataManager.get_actor_self_title(me.actorId),
		DataManager.get_actor_naughty_title(target.actorId, me.actorId),
	])
	play_dialog(actorId, msg, 0, 2001)
	map.next_shrink_actors = [target.actorId, me.actorId]
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20222_3() -> void:
	var bf = DataManager.get_current_battle_fight()
	var leader = bf.get_loser()
	var target = leader.get_battle_enemy_war_actor()
	start_battle_and_finish(actorId, target.actorId)
	return
