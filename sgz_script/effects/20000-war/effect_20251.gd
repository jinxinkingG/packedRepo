extends "effect_20000.gd"

#义劝主动技实现
#【义劝】大战场,主动技。若敌将仅有1人、兵力不足1000、非君主、且无路可退，才能发动：将敌将无视条件笼络至你方。可对城地形目标发动。

const EFFECT_ID = 20251
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SOLDIERS_LIMIT = 1000

func effect_20251_start():
	var targets = get_enemy_targets(me, true)
	if targets.empty():
		var msg = "没有可以发动{0}的目标".format([ske.skill_name])
		play_dialog(me.actorId, msg, 2, 2999)
		return
	if targets.size() > 1:
		var msg = "敌军并非孤立无援\n谅未必肯降"
		play_dialog(me.actorId, msg, 2, 2999)
		return
	var target = DataManager.get_war_actor(targets[0])
	if target.actor().get_loyalty() >= 100:
		var msg = "不可对君主发动{0}".format([ske.skill_name])
		play_dialog(me.actorId, msg, 2, 2999)
		return
	if target.get_retreat_city_id() >= 0:
		var msg = "敌军未陷绝境\n谅未必肯降"
		play_dialog(me.actorId, msg, 2, 2999)
		return
	if target.get_soldiers() >= SOLDIERS_LIMIT:
		var msg = "敌军尚有一战之力\n谅未必肯降"
		play_dialog(me.actorId, msg, 2, 2999)
		return
	DataManager.set_env("目标", target.actorId)
	var msg = "对{0}发动{1}\n劝其归降\n可否？".format([
		target.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20251_2():
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}身陷绝境矣，然非战之罪，何不留有用之身，以待来日？".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20251_3():
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}高义，吾亦知之，然主公恩厚，岂忍背弃？\n今日有死而已".format([
		DataManager.get_actor_honored_title(me.actorId, targetId),
	])
	play_dialog(targetId, msg, 0, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20251_4():
	var targetId = DataManager.get_env_int("目标")
	var msg = "{0}此言，固义气深重，然兄非家臣，乃汉臣也，大丈夫岂可逞匹夫之快？".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
	])
	play_dialog(actorId, msg, 2, 2003)
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

func effect_20251_5():
	var targetId = DataManager.get_env_int("目标")
	var target = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)
	var msg = "…… ……\n既如此，{0}愿降\n（{0}加入我军".format([
		target.get_name(),
	])
	targetActor.set_loyalty(min(70, targetActor.get_moral()))
	targetActor.set_prev_vstate_id(target.vstate().id)
	targetActor.set_soldiers(0)
	target.actor_surrend_to(me.wvId)
	play_dialog(targetId, msg, 3, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
