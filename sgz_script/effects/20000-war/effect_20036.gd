extends "effect_20000.gd"

#援护诱发技部分 #替代防御
#【援护】大战场，诱发技。你所指定守护的队友(默认为主将)被攻击的场合，你可消耗2点机动力发动：你替代之被攻击。同时，你可以通过主动发动本技能，更改守护的目标。

const EFFECT_ID = 20036
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 2

func _init() -> void:
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)
	return

func _input_key(delta:float):
	match LoadControl.get_view_model():
		2000:
			wait_for_yesno(FLOW_BASE + "_2", false)
		2001:
			wait_for_skill_result_confirmation("")
	return

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId != _get_marked_actor_id(ske, me):
		# 不是保护目标，跳过
		return false
	if ske.actorId == me.actorId:
		# 自己没必要触发
		return false
	#机动力不足，无法发动
	if me.action_point < COST_AP:
		return false
	return true

func effect_20036_AI_start():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	
	if me.get_soldiers() <= bf.get_defender().get_soldiers() \
		and me.get_soldiers() < 1500:
		LoadControl.end_script()
		return
	effect_20036_2()
	return

func effect_20036_start():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()

	var war_map = SceneManager.current_scene().war_map
	war_map.cursor.hide()
	var msg = "发动{0}\n需{1}点机动力\n可否？".format([ske.skill_name, COST_AP])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20036_2():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()

	ske.cost_ap(COST_AP)
	ske.replace_battle_defender(ske.actorId)
	ske.war_report()

	var msg = "{0}不必惊慌！\n{1}在此！\n（{2}代替被攻击".format([
		DataManager.get_actor_honored_title(ske.actorId, me.actorId),
		DataManager.get_actor_self_title(me.actorId),
		me.get_name(),
	])
	play_dialog(me.actorId, msg, 0, 2001)
	return

func _get_marked_actor_id(ske:SkillEffectInfo, me:War_Actor)->int:
	var marked = ske.get_war_skill_val_int()
	if marked < 0:
		return me.get_main_actor_id()
	var wa = DataManager.get_war_actor(marked)
	if wa == null or wa.disabled or not wa.has_position():
		return me.get_main_actor_id()
	return marked

