extends "effect_20000.gd"

#苦谏主动技和睿敛、庸非、勉援效果
#【苦谏】大战场，主动技。你需消耗X点机动力(X为你本回合发动本技能的次数)，并指定1名队友为目标发动。令目标选择一项效果：A. 增加1点机动力；B. 大战场攻击距离+5。若目标选择效果B，此技能本回合不能再次发动。
#【睿敛】大战场，锁定技。你每次发动<苦谏>，机动力+1。
#【庸非】大战场，锁定技。你发动<苦谏>时，若目标选择增加机动力，则使其额外恢复1点体力。
#【勉援】大战场，锁定技。你发动<苦谏>时，若目标一意孤行，则将你兵力转移150至该目标。

const EFFECT_ID = 20354
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const REINFORCE_SOLDIERS = 150

const DIALOGS = [
	"情势不明，{0}万不可冒进",
	"敌军势大，{0}小心应付",
	"{1}狡诈，{0}不可不防",
]

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func on_view_model_2003()->void:
	match wait_for_skill_option():
		0:
			goto_step("5")
		1:
			goto_step("6")
	return

func on_view_model_2004()->void:
	wait_for_pending_message(FLOW_BASE + "_7")

func effect_20354_start():
	if not wait_choose_actors(get_teammate_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20354_2():
	var war_map = SceneManager.current_scene().war_map
	war_map.cursor.hide()
	var targetId = get_env_int("目标")
	var ap = ske.get_war_skill_val_int() + 1
	if not assert_action_point(me.actorId, ap):
		return
	var msg = "【{0}】{1}\n需{2}点机动力\n可否？".format([
		ske.skill_name, ActorHelper.actor(targetId).get_name(), ap
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20354_3():
	var targetId = get_env_int("目标")
	var ap = ske.get_war_skill_val_int() + 1
	var wv = me.war_vstate()
	var enemyLeader = wv.get_enemy_vstate().main_actorId
	
	ske.set_war_skill_val(ap, 1)
	ske.cost_ap(ap, true)
	if SkillHelper.actor_has_skills(actorId, ["睿敛"]):
		ske.change_actor_ap(actorId, 1)

	var dialogs = DIALOGS.duplicate()
	dialogs.shuffle()
	var msg = dialogs[0].format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
		ActorHelper.actor(enemyLeader).get_name(),
	])
	play_dialog(me.actorId, msg, 3, 2002)
	return

func effect_20354_4():
	var targetId = get_env_int("目标")
	var msg = "{0}此言 ……".format([
		DataManager.get_actor_honored_title(me.actorId, targetId),
	])
	set_env("列表值", ["不无道理", "暮气深重"])
	play_dialog(targetId, msg, 2, 2003, true, get_env_array("列表值"))
	return

func effect_20354_5():
	var targetId = get_env_int("目标")
	ske.change_actor_ap(targetId, 1)
	if SkillHelper.actor_has_skills(actorId, ["庸非"]):
		ske.change_actor_hp(targetId, 1)
	var msg = "{0}善纳谏言，幸也".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	report_skill_result_message(ske, 2004, msg, 1, -1, false)
	return

func effect_20354_6():
	var targetId = DataManager.get_env_int("目标")
	ske.cost_war_cd(1)
	ske.change_actor_attack_range(targetId, 5)
	var reinforced = 0
	if SkillHelper.actor_has_skills(actorId, ["勉援"]):
		reinforced = int(min(REINFORCE_SOLDIERS, actor.get_soldiers()))
		if reinforced > 0:
			reinforced = ske.sub_actor_soldiers(actorId, reinforced)
			reinforced = ske.add_actor_soldiers(targetId, reinforced)
	var msg = "{0}何苦一意孤行".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	if reinforced > 0:
		msg = "{0}既然意决\n{1}岂能坐视\n（支援{2} {3}士兵".format([
			DataManager.get_actor_honored_title(targetId, actorId),
			DataManager.get_actor_self_title(actorId),
			ActorHelper.actor(targetId).get_name(),
			reinforced,
		])
	report_skill_result_message(ske, 2004, msg, 3, -1, false)
	return

func effect_20354_7():
	report_skill_result_message(ske, 2004)
	return
