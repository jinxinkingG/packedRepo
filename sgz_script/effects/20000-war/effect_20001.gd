extends "effect_20000.gd"

#施恩主动技
#【施恩】大战场，主动技。你可以指定任意你方武将，将自己任意点数的机动力交给该武将。


const EFFECT_ID = 20001
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const LATEST_KEY = "技能.施恩.LAST"

#开始-选择6格内的队友
func effect_20001_start():
	var targets = get_teammate_targets(me)
	var lastId = get_env_int(LATEST_KEY)
	if lastId in targets:
		targets.erase(lastId)
		targets.insert(0, lastId)
		set_env("目标", lastId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

#选择交予的机动力数值
func effect_20001_2():
	var targetId = get_env_int("目标")
	SceneManager.hide_all_tool()
	var msg = "交予{0}多少机动力？".format([
		ActorHelper.actor(targetId).get_name()
	])
	SceneManager.show_input_numbers(msg, ["机动力"], [me.action_point], [0], [2])
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_number_input(FLOW_BASE + "_3")
	return

#播放动画
func effect_20001_3():
	var targetId = get_env_int("目标")
	var ap = get_env_int("数值")

	set_env(LATEST_KEY, targetId)
	ap = ske.cost_ap(ap, true)
	ap = ske.change_actor_ap(targetId, ap)
	set_env("数值", ap)

	map.cursor.hide()
	SceneManager.hide_all_tool()
	var msg = "惟贤惟德，能服于人\n{0}善用之".format([
		DataManager.get_actor_honored_title(targetId, self.actorId)
	])
	ske.play_war_animation("Strategy_Talking", 2002, targetId, msg, 2)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20001_4():
	var targetId = get_env_int("目标")
	var ap = get_env_int("数值")
	var msg = "{0}交予{1}{2}点机动力".format([
		me.get_name(), ActorHelper.actor(targetId).get_name(), ap,
	])
	ske.war_report()
	play_dialog(-1, msg, 1, 2003)
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation()
	return
