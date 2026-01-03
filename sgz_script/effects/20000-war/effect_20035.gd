extends "effect_20000.gd"

#恃武诱发技 #替代攻击
#及协武效果
#【恃武】大战场，诱发技。你的队友发起攻击时，你可以消耗5机动力发动。你替代之进入白刃战。每回合限制3次。
#【协武】大战场，锁定技。你方其他武将发动<恃武>后，该武将的机动力+5，体力+5。每回合限1次。

const EFFECT_ID = 20035
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5
const TIMES_LIMIT = 3

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if me == null or me.disabled:
		return false
	if ske.actorId != bf.get_attacker_id():
		# 不是进攻方，跳过
		return false
	if ske.actorId == me.actorId:
		# 自己没必要触发
		return false
	if me.action_point < COST_AP:
		#机动力不足，无法发动
		return false
	# AI 判断
	if me.get_controlNo() < 0 and \
		me.get_soldiers() <= bf.get_defender().get_soldiers() \
		and me.get_soldiers() < 1500:
		return false
	return true

func effect_20035_AI_start():
	goto_step("2")
	return

func effect_20035_start():
	var bf = DataManager.get_current_battle_fight()
	map.cursor.hide()
	var msg = "发动{0}\n需{1}点机动力\n可否？".format([ske.skill_name, COST_AP])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20035_2():
	var bf = DataManager.get_current_battle_fight()

	ske.cost_war_limited_times(TIMES_LIMIT)
	ske.cost_ap(COST_AP)
	bf.attackerId = me.actorId
	var msg = "{0}替代发起攻击".format([
		me.get_name()
	])
	ske.append_message(msg)
	msg = "必斩{0}首级\n献于麾下！\n（{1}".format([
		bf.get_defender().get_name(), msg
	])
	ske.war_report()
	play_dialog(me.actorId, msg, 0, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_done")
	return

func effect_20035_done() -> void:
	for srb in SkillRangeBuff.find_for_war_vstate("恃武助力", me.wvId):
		if srb.actorId == actorId:
			# 自己不能协
			continue
		var srbSke = SkillHelper.new_ske_from_range_buff(actorId, srb)
		srbSke.change_actor_ap(actorId, 5)
		var hp = srbSke.change_actor_hp(actorId, 5)
		srbSke.cost_war_cd(1)
		srbSke.war_report()
		var msg = "壮哉{0}，吾亦当协力！\n（{1}【{2}】\n（{3}机动力 +5"
		if hp > 0:
			msg += "，体力 +{4}"
		msg = msg.format([
			DataManager.get_actor_honored_title(actorId, srb.actorId),
			ActorHelper.actor(srb.actorId).get_name(), srb.skillName,
			actor.get_name(), hp,
		])
		play_dialog(srb.actorId, msg, 0, 2999)
		return
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
