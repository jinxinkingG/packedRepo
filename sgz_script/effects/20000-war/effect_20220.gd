extends "effect_20000.gd"

#天香诱发技
#【天香】大战场，诱发技。“敌方男性武将对你发起攻击宣言”或“你对敌方男性武将发起攻击宣言”时才能发动。取消那次攻击，你与目标强制回到营帐。这个效果在你或目标为主将时，不能发动。

const EFFECT_ID = 20220
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if me == null or me.disabled:
		return false
	var targetId = -1
	if me.actorId == bf.get_attacker_id():
		targetId = bf.get_defender_id()
	elif me.actorId == bf.get_defender_id():
		targetId = bf.get_attacker_id()
	else:
		return false
	var target = DataManager.get_war_actor(targetId)
	if target == null or target.disabled:
		return false
	if me.get_main_actor_id() == me.actorId:
		# 主将不可
		return false
	if target.get_main_actor_id() == target.actorId:
		# 主将不可
		return false
	if not ActorHelper.actor(target.actorId).is_male():
		# 仅限男性
		return false
	return true

func effect_20220_AI_start():
	goto_step("2")
	return

func effect_20220_start():
	var target = me.get_battle_enemy_war_actor()
	var msg = "发动【天香】\n与{0}各自回营\n可否？".format([
		target.get_name()
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20220_2() -> void:
	var target = me.get_battle_enemy_war_actor()
	var msg = "红颜本已薄命\n{0}何以逼迫太甚？".format([
		DataManager.get_actor_honored_title(target.actorId, me.actorId),
	])
	play_dialog(actorId, msg, 2, 2001)
	map.next_shrink_actors = [actorId, target.actorId]
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20220_3() -> void:
	var leader = me.get_leader()
	var target = me.get_battle_enemy_war_actor()
	ske.war_camp_in(actorId)
	ske.war_camp_in(target.actorId)
	cancel_attack()
	ske.war_report()

	report_skill_result_message(ske, 2002)
	return

func effect_20220_report() -> void:
	report_skill_result_message(ske, 2002)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return
