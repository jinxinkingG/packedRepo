extends "effect_20000.gd"

#急救主动技
#【急救】大战场,主动技。你可以指定一个己方武将，消耗3个[药]和2点点机动力，将其体力恢复30，然后你的经验+30

const EFFECT_ID = 20169
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_SCENE_ID = 10000
const FLAG_ID = 10003
const FLAG_NAME = "药"
const COST_FLAG = 3
const COST_AP = 2
const HP_RECOVER = 30
const EXP_GAIN = 30

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4", FLOW_BASE + "_5")
	return

func on_view_model_3000():
	wait_for_pending_message(FLOW_BASE + "_AI_2", FLOW_BASE + "_AI_3")
	return

func check_AI_perform_20000()->bool:
	if me.action_point < COST_AP:
		return false
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, self.actorId, FLAG_NAME)
	if flags < COST_FLAG:
		return false
	var mostHurt = -1
	var maxHurt = 20
	for targetId in get_teammate_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		var hurt = targetActor.get_max_hp() - int(targetActor.get_hp())
		if hurt >= maxHurt:
			maxHurt = hurt
			mostHurt = targetId
	if mostHurt < 0:
		return false
	set_env("目标", mostHurt)
	return true

func effect_20169_AI_start():
	goto_step("3")
	return

func effect_20169_AI_2():
	report_skill_result_message(ske, 3000)
	return

func effect_20169_AI_3():
	LoadControl.end_script()
	FlowManager.add_flow("AI_skill_end_trigger")
	return

# 发动主动技
func effect_20169_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var me = DataManager.get_war_actor(self.actorId)
	var actor = ActorHelper.actor(self.actorId)

	if not assert_action_point(self.actorId, COST_AP):
		return
	if not assert_flag_count(self.actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAG):
		return

	var targets = []
	var checking = get_teammate_targets(me)
	checking.append(self.actorId)
	for targetId in checking:
		var targetActor = ActorHelper.actor(targetId)
		if targetActor.get_hp() < targetActor.get_max_hp():
			targets.append(targetId)
	if targets.empty():
		LoadControl._error("众将均未受伤", me.actorId, 1)
		return
	if not wait_choose_actors(targets, "选择队友发动【{0}】", true):
		return
	LoadControl.set_view_model(2000)
	return

# 已选定队友
func effect_20169_2():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗{0}个[{1}]和{2}机动力\n为{3}恢复至多{4}体\n可否？".format([
		COST_FLAG, FLAG_NAME, COST_AP, targetActor.get_name(), HP_RECOVER,
	])
	play_dialog(self.actorId, msg, 2, 2001, true)
	return

# 执行
func effect_20169_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)

	ske.cost_ap(COST_AP, true)
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, COST_FLAG)
	ske.change_actor_exp(ske.skill_actorId, EXP_GAIN)
	ske.change_actor_hp(targetId, 30)

	var name = DataManager.get_actor_honored_title(targetId, me.actorId)
	if targetId == ske.skill_actorId:
		name = "阿普" # 华佗药童
	var msg = "{0}勿忧，外伤而已".format([name])
	FlowManager.add_flow("draw_actors")
	var nextViewModel = 2002
	if me.get_controlNo() < 0:
		nextViewModel = 3000
	map.next_shrink_actors = [me.actorId, targetId]
	report_skill_result_message(ske, nextViewModel, msg, 1)
	return

func effect_20169_4():
	report_skill_result_message(ske, 2002)
	return

func effect_20169_5():
	if me.action_point < COST_AP:
		FlowManager.add_flow("player_skill_end_trigger")
		return
	var flags = SkillHelper.get_skill_flags_number(FLAG_SCENE_ID, FLAG_ID, self.actorId, FLAG_NAME)
	if flags < COST_FLAG:
		FlowManager.add_flow("player_skill_end_trigger")
		return
	var targets = []
	for targetId in get_teammate_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		if targetActor.is_injured():
			targets.append(targetId)
	if targets.empty():
		FlowManager.add_flow("player_skill_end_trigger")
		return
	ske.reset_for_redo()
	if not wait_choose_actors(targets, "选择队友发动【急救】", true):
		return
	LoadControl.set_view_model(2000)
	return
