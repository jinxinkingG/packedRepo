extends "effect_20000.gd"

#八阵主动技 #道术 #连续发动
#【八阵】大战场，主动技。指定距离6以内的1名敌将，消耗8点机动力发动。概率性对该敌将及其相邻延伸目标附加道术 {八阵} 状态。
#【八阵*】大战场，主动技。指定距离6以内的1名敌将，消耗8点机动力发动。概率性对该敌将附加道术 {八阵} 状态。传自武侯，一开始似乎…稍弱。你达到8级，战争中第一次发动命中时，可以消耗10000点经验出师，永久解锁 <八阵>

const EFFECT_ID = 20005
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func get_scheme_name():
	if ske.skill_name == "八阵*":
		return "奇门遁甲*"
	return "奇门遁甲"

func get_cost_ap()->int:
	if actorId != StaticManager.ACTOR_ID_ZHUGELIANG:
		return 8
	var reduced = SkillRangeBuff.max_val_for_war_vstate("八阵减耗", me.wvId)
	if reduced > 0:
		return int(max(1, 8 - reduced))
	return 8

func effect_20005_start():
	if not assert_action_point(actorId, get_cost_ap()):
		return
	var se = DataManager.new_stratagem_execution(actorId, get_scheme_name())
	var targets = se.get_available_targets()[0]
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20005_2():
	var msg = "消耗{0}点机动力\n可否？".format([get_cost_ap()])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20005_3():
	var se = DataManager.get_current_stratagem_execution()
	
	ske.cost_ap(get_cost_ap(), true)

	se.set_target(get_env_int("目标"))
	var rate = se.get_rate([se.targetId])
	se.perform_to_targets([se.targetId])

	var msg = se.get_message()
	if se.rate < 100:
		msg += "\n成功率：{0}%".format([se.rate])

	ske.play_se_animation(se, 2002, msg, 0)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4", FLOW_BASE + "_redo")
	return

func effect_20005_4():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return

func effect_20005_redo():
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded > 0:
		# 标记成功
		# 目前的作用是配合【八阵*】的出师判断
		# 所以只需要标记曾经成功即可
		ske.set_war_skill_val(1)
	if me.action_point < get_cost_ap():
		FlowManager.add_flow("player_skill_end_trigger")
		return
	se = DataManager.new_stratagem_execution(actorId, get_scheme_name())
	var targets = []
	for targetId in se.get_available_targets()[0]:
		var wa = DataManager.get_war_actor(targetId)
		if wa.get_buff_label_turn(["乱石阵"]) > 0:
			continue
		targets.append(targetId)
	if targets.empty():
		FlowManager.add_flow("player_skill_end_trigger")
		return
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2003)
	return

func on_view_model_2003() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2", true, true, FLOW_BASE + "_cancel")
	return

# 取消连续发动
func effect_20005_cancel() -> void:
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
