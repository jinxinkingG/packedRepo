extends "effect_20000.gd"

#暗通主动技
#【暗通】大战场，主动技。你可以选择消一个忠＜80的对方武将，再选择交给对方100金或米，使其定止1回合，每个回合限1次。

const EFFECT_ID = 20493
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST = 100

func effect_20493_start()->void:
	var wv = me.war_vstate()
	if wv.money < COST and wv.rice < COST:
		var msg = "金米不足\n无法发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return
	var targets = []
	for targetId in get_enemy_targets(me):
		var target = ActorHelper.actor(targetId)
		if target.get_loyalty() >= 80:
			continue
		targets.append(targetId)
	var msg = "选择敌军发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_decide")
	return

func effect_20493_decide()->void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var msg = "暗贿{0}所部上下\n令其定止一回合".format([
		wa.get_name(),
	])
	var options = ["{0}金".format([COST]), "{0}米".format([COST])]
	var wv = me.war_vstate()
	if wv.money < COST:
		options.remove(0)
	elif wv.rice < COST:
		options.remove(1)
	play_dialog(actorId, msg, 2, 2001, true, options)
	return

func on_view_model_2001()->void:
	if wait_for_skill_option() >= 0:
		goto_step("go")
	return

func effect_20493_go()->void:
	var targetId = DataManager.get_env_int("目标")
	var wa = DataManager.get_war_actor(targetId)
	var wv = me.war_vstate()
	var idx = SceneManager.actor_dialog.lsc.cursor_index
	var option = SceneManager.actor_dialog.lsc.items[idx]
	var item = "金"
	var left = 0
	if "米" in option:
		ske.change_wv_rice(-COST)
		item = "米"
		left = wv.rice
	else:
		ske.change_wv_gold(-COST)
		left = wv.money
	ske.set_war_buff(targetId, "定止", 1)
	ske.cost_war_cd(1)

	map.draw_actors()
	var msg = "花费{0}{1}，余{2}\n{3}所部上下相疑\n正可相机用兵".format([
		COST, item, left, wa.get_name(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_20493_end()->void:
	ske.war_report()
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
