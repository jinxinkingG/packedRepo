extends "effect_30000.gd"

#骁勇小战场效果
#【骁勇】大战场,主动技。1回合1次，消耗1机动力发动：你可选择回到前3~10步之内的任意位置。以此效果进行位移后，若你相邻存在可攻击的敌将，你必须与其中一名敌将进入白兵，并在本次白兵结束之前，禁用对手所有技能。

const XIAOYONG_EFFECT_ID = 20013
const EFFECT_ID = 30125
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)

func _input_key(delta):
	match LoadControl.get_view_model():
		2000:
			wait_for_skill_result_confirmation("")
	return

func effect_30125_AI_start():
	return self.effect_30125_start()

func effect_30125_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var targetActorId = -1
	if self.actorId == DataManager.battle_actors[1]:
		targetActorId = DataManager.battle_actors[0]
	if self.actorId == DataManager.battle_actors[0]:
		targetActorId = DataManager.battle_actors[1]
	var me = DataManager.get_war_actor(self.actorId)
	var enemy = DataManager.get_war_actor(targetActorId)
	enemy.set_buff("沉默", 1, self.actorId)
	var msg = "敌势可破，全军突击！！！\n（本场战斗\n（{0}的技能被禁用".format([
		ActorHelper.actor(targetActorId).get_name()
	])
	SceneManager.show_confirm_dialog(msg, self.actorId, 0)
	LoadControl.set_view_model(2000)
	return

func check_trigger_correct()->bool:
	var skv = SkillHelper.get_skill_variable(20000, XIAOYONG_EFFECT_ID, self.actorId)
	if skv["turn"] <= 0 or skv["value"] != 1:
		return false
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var targetActorId = -1
	if self.actorId == DataManager.battle_actors[1]:
		targetActorId = DataManager.battle_actors[0]
	if self.actorId == DataManager.battle_actors[0]:
		targetActorId = DataManager.battle_actors[1]
	if targetActorId < 0:
		return false
	var enemy = DataManager.get_war_actor(targetActorId)
	if enemy == null or enemy.disabled:
		return false
	# 如果已经被沉默了，就不触发
	if enemy.get_buff_label_turn(["沉默"]) > 0:
		return false
	return true
