extends "effect_20000.gd"

#青囊效果实现
#【青囊】大战场,诱发技。你方武将被伤兵计策命中时，你可以消耗2个[药]和3点机动力发动：该损兵者恢复本次计策伤害50%的兵力。然后你的经验+200

const EFFECT_ID = 20228
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_SCENE_ID = 10000
const FLAG_ID = 10003
const FLAG_NAME = "药"
const COST_FLAG = 2
const COST_AP = 3
const EXP_GAIN = 200

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_3", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)
	return

func _input_key(delta:float):
	var view_model = LoadControl.get_view_model();
	match view_model:
		2000:
			wait_for_yesno(FLOW_BASE + "_2", false)
		2001:
			wait_for_pending_message(FLOW_BASE + "_3", "")
	return

func effect_20228_AI_start():
	FlowManager.add_flow(FLOW_BASE + "_2")
	return

func effect_20228_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var me = DataManager.get_war_actor(self.actorId)
	var teammate = DataManager.get_war_actor(ske.actorId)
	var msg = "消耗{0}个[药]和{1}机动力\n发动【青囊】，为{2}恢复兵力，可否？".format([
		COST_FLAG, COST_AP, ActorHelper.actor(ske.actorId).get_name()
	])
	play_dialog(self.actorId, msg, 2, 2000, true)
	return

func effect_20228_2():
	var ske = SkillHelper.read_skill_effectinfo()
	var se = DataManager.get_current_stratagem_execution()
	var damage = se.get_soldier_damage_for(ske.actorId)
	var recover = int(damage / 2)

	ske.cost_ap(COST_AP)
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAG)
	ske.change_actor_exp(ske.skill_actorId, EXP_GAIN)
	ske.change_actor_soldiers(ske.actorId, recover)
	var msg = "{0}稍安\n士卒之伤可解".format([
		DataManager.get_actor_honored_title(ske.actorId, ske.skill_actorId),
	])
	report_skill_result_message(ske, 2001, msg, 1)
	return

func effect_20228_3():
	var ske = SkillHelper.read_skill_effectinfo()
	report_skill_result_message(ske, 2001)
	return

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	if ske.actorId == self.actorId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.succeeded <= 0:
		return false
	if not se.damage_soldier():
		return false
	if ske.actorId != se.targetId:
		return false
	if se.get_soldier_damage_for(se.targetId) <= 0:
		return false
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var teammate = DataManager.get_war_actor(ske.actorId)
	if teammate == null or teammate.disabled:
		return false
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, self.actorId, FLAG_NAME)
	if flags < COST_FLAG:
		return false
	if me.action_point < COST_AP:
		return false
	return true
