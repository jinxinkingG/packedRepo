extends "effect_20000.gd"

#稳进主动技
#【稳进】大战场，主动技。①使用后记录你的机动力为X，再清空。则下回你你恢复机动力时，额外恢复X点，X最大为18，每2回合限1次。②你机动力为0时，受到计策伤害-50%.

const EFFECT_ID = 20555
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20555_start() -> void:
	var ap = me.action_point
	if ap <= 0:
		goto_step("end")
		return
	ske.set_war_skill_val(ap, 2)
	ske.cost_war_cd(2)
	ske.change_actor_ap(actorId, -ap)
	ske.war_report()

	var msg = "步步为营，蓄势待发！\n（{0}放弃{1}机动力".format([
		me.get_name(), ap,
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_20555_end() -> void:
	FlowManager.add_flow("player_skill_end_trigger")
	return
