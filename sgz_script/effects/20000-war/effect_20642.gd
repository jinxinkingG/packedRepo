extends "effect_20000.gd"

# 睥睨锁定技
#【睥睨】大战场，锁定技。你的回合结束时，以对方场上体力最大且大于40的武将为目标。使目标的体力减少你的点数值；若该点数>5，对方可以选择对你发起攻击。

const EFFECT_ID = 20642
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_LIMIT = 40

func on_trigger_20016() -> bool:
	var x = me.poker_point
	if x <= 0:
		return false
	var target = null
	var minHP = HP_LIMIT
	for wa in me.get_enemy_war_actors(true):
		var hp = wa.actor().get_hp()
		if hp <= minHP:
			continue
		target = wa
		minHP = hp
	if target == null:
		return false
	var battle = true
	if x <= 5:
		# 如果点数小于等于 5，不会引起战斗
		# 不需要走完整流程，直接插入对话结束即可
		battle = false
	elif check_combat_targets([actorId]).empty():
		# 如果不可攻击，也不需要进入战斗
		battle = false
	if not battle:
		var reduced = ske.change_actor_hp(target.actorId, -x)
		ske.cost_war_cd(1)
		ske.war_report()
		var msg = "{0}无谋匹夫尔！\n（【{1}】发动".format([
			DataManager.get_actor_naughty_title(target.actorId, actorId),
			ske.skill_name,
		])
		me.attach_free_dialog(msg, 0)
		msg = "小儿无礼太甚！（{0}体力 {1}".format([
			target.get_name(), reduced,
		])
		me.attach_free_dialog(msg, 0, 20000, target.actorId)
		return false
	ske.set_war_skill_val(target.actorId, 1)
	return true

func effect_20642_start() -> void:
	ske.cost_war_cd(1)
	# 技能发动后自动结束回合
	ske.mark_auto_finish_turn()
	var targetId = ske.get_war_skill_val_int()
	var target = DataManager.get_war_actor(targetId)

	var msg = "{0}无谋匹夫尔！\n（【{1}】发动".format([
		DataManager.get_actor_naughty_title(target.actorId, actorId),
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_perform")
	return

func effect_20642_perform() -> void:
	var targetId = ske.get_war_skill_val_int()
	var target = DataManager.get_war_actor(targetId)

	var reduced = ske.change_actor_hp(target.actorId, -me.poker_point)
	ske.war_report()

	var msg = "小儿无礼太甚！（{0}体力 {1}\n（{0}发起攻击".format([
		target.get_name(), reduced,
	])
	play_dialog(targetId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20642_fight() -> void:
	var targetId = ske.get_war_skill_val_int()
	var target = DataManager.get_war_actor(targetId)
	var terrian = ""
	var tarrianCN = map.get_blockCN_by_position(me.position)
	if tarrianCN in StaticManager.CITY_BLOCKS_CN:
		terrian = "land"
	start_battle_and_finish(targetId, actorId, ske.skill_name, actorId, terrian)
	return
