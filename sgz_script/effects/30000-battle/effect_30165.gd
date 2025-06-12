extends "effect_30000.gd"

#金创主动技及被动效果
#【金创】小战场，主动技。使用后，你的体+8，战术值+4。每日限一次

const EFFECT_ID = 30165
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const HP_RECOVER = 8
const TACTIC_RECOVER = 4

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2", false)
	return

func check_AI_perform()->bool:
	# 体力 < 50 时发动
	if ActorHelper.actor(self.actorId).get_hp() < 50:
		return true
	return false

func effect_30165_AI_start():
	goto_step("start")
	return

func effect_30165_start():
	ske.cost_war_cd(1)
	ske.battle_cd(99999)
	var recover = ske.change_actor_hp(me.actorId, HP_RECOVER)
	ske.battle_change_tactic_point(TACTIC_RECOVER, me)
	ske.battle_report()
	var msg = "世受国恩，惟知有战！\n（{0}发动【金创】，体力+{1}，战术值+{2}".format([
		actor.get_name(), recover, TACTIC_RECOVER
	])
	SceneManager.show_confirm_dialog(msg, me.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func effect_30165_2():
	if me.get_controlNo() < 0:
		LoadControl.end_script()
		FlowManager.add_flow("unit_action")
	else:
		FlowManager.add_flow("tactic_end")
	return
