extends "effect_20000.gd"

#放逐
#【放逐】大战场,锁定技。你被用计伤兵时，若用计者不是主将，则他有X%的概率回到营帐（X=你的等级*8）。

const EFFECT_ID = 20140
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)
	return

func _input_key(delta:float):
	match LoadControl.get_view_model():
		2000:
			wait_for_skill_result_confirmation("")
	return

func effect_20140_AI_start():
	return effect_20140_start()

func effect_20140_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var me = DataManager.get_war_actor(self.actorId)
	var actor = ActorHelper.actor(self.actorId)
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(self.actorId)
	var fromWarActor = DataManager.get_war_actor(fromId)
	var fromActor = ActorHelper.actor(fromId)
	var skillInfo = "{1}发动【放逐】\n　{0}已被迫回营".format([
		fromActor.get_name(), actor.get_name()
	])
	se.append_result(ske.skill_name, skillInfo, fromId, self.actorId)
	var msg = "{0}小儿如此放肆！\n（{1}".format([
		DataManager.get_actor_naughty_title(fromId, self.actorId), skillInfo
	])
	fromWarActor.camp_in()
	se.skip_redo = 1
	FlowManager.add_flow("draw_actors")
	play_dialog(self.actorId, msg, 0, 2000)
	return

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != self.actorId:
		return false
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var fromId = se.get_action_id(self.actorId)
	if fromId < 0:
		return false
	var fromWarActor = DataManager.get_war_actor(fromId)
	if fromWarActor == null or fromWarActor.disabled:
		return false
	var map = SceneManager.current_scene().war_map
	var blockCN = map.get_blockCN_by_position(fromWarActor.position)
	if blockCN == "太守府":
		# 不能对太守府的武将发动
		return false
	if fromWarActor.get_main_actor_id() == fromWarActor.actorId:
		# 不能对主将发动
		return false
	var actor = ActorHelper.actor(self.actorId)
	var x = actor.get_level() * 8
	return Global.get_rate_result(x)
