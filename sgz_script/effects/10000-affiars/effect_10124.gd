extends "effect_10000.gd"

#截逆锁定技
#【截逆】内政，锁定技。你方队友被招揽成功的场合，若你与其在同一城内：你有X%的概率将其半路截住，之后可选择将目标「释放/斩杀/置入监狱」（X=你的等级*7）。每月限1次。 注:「置入监狱」需要监狱系统允许此武将进入，没开监狱就没有该选项。

const EFFECT_ID = 10124
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10016() -> bool:
	var cmd = DataManager.get_current_policy_command()
	if cmd == null or not cmd.type in ["招揽"]:
		return false
	if cmd.result <= 0:
		return false
	var target = cmd.target_actor()
	if target.actorId == actorId:
		return false
	ske.affair_cd(1)
	var msg = "既如此，{0}不宜久留\n这便动身吧".format([
		cmd.target_city().get_full_name(),
	])
	cmd.append_result_messages(msg.split("\n"), 1, target.actorId, cmd.target_city().ID)
	var rate = actor.get_level() * 7
	if not Global.get_rate_result(rate):
		msg = "迟了一步，{0}跑得倒快！\n（{1}【{2}】失败".format([
			DataManager.get_actor_naughty_title(target.actorId, actorId),
			actor.get_name(), ske.skill_name,
		])
		cmd.append_result_messages(msg.split("\n"), 0, actorId, cmd.target_city().ID)
		return false
	if DataManager.get_scene_actor_control(actorId) >= 0:
		# 玩家自主选择
		return true
	# AI 根据相性，在释放和收监中选择
	msg = "{0}哪里走！".format([
		DataManager.get_actor_naughty_title(target.actorId, actorId)
	])
	cmd.append_result_messages(msg.split("\n"), 0, actorId, cmd.target_city().ID)
	if actor.personality_distance(target) < 30:
		# 放了
		msg = "恩义虽绝，人情尚在\n吾去意已决，{0}何苦相逼？".format([
			DataManager.get_actor_honored_title(actorId, target.actorId)
		])
		cmd.append_result_messages(msg.split("\n"), 3, target.actorId, cmd.target_city().ID)
		msg = "… …\n罢了，今日一别，是敌非友！"
		cmd.append_result_messages(msg.split("\n"), 3, actorId, cmd.target_city().ID)
		return false
	else:
		msg = "既为{0}所执，任凭处置！".format([
			DataManager.get_actor_naughty_title(actorId, target.actorId)
		])
		cmd.append_result_messages(msg.split("\n"), 3, target.actorId, cmd.target_city().ID)
		msg = "背主之人，何足与论\n斩讫报来！"
		cmd.append_result_messages(msg.split("\n"), 0, actorId, cmd.target_city().ID)
		clCity.move_out(target.actorId)
		target.set_status_dead()
		cmd.result = 0
		msg = "惭愧，{0}本已意动\n奈何为{1}【{2}】\n已被斩杀！".format([
			cmd.target_actor().get_name(), actor.get_name(), ske.skill_name,
		])
		cmd.append_result_messages(msg.split("\n"), 3)
	return false

func effect_10124_start() -> void:
	var cmd = DataManager.get_current_policy_command()
	var msg = "{0}哪里走！\n（{1}军{2}招揽成功\n（{3}【{4}】发动".format([
		DataManager.get_actor_naughty_title(cmd.target_actor().actorId, actorId),
		cmd.vstate().get_dynasty_title_or_lord_name(),
		cmd.actioner().get_name(),
		actor.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 0, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_ask")
	return

func effect_10124_ask() -> void:
	var cmd = DataManager.get_current_policy_command()
	var msg = "{0}叛逃，如何处置？".format([
		cmd.target_actor().get_name()
	])
	var options = ["释放", "斩杀"]
	if DataManager.game_set["监狱系统"] != "无":
		options.append("收监")
	SceneManager.bind_bottom_menu(msg, options)
	SceneManager.show_cityInfo(false)
	SceneManager.lsc_menu.show_orderbook(false)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_menu_item(FLOW_BASE + "_decided")
	return

func effect_10124_decided() -> void:
	var cmd = DataManager.get_current_policy_command()
	var decision = DataManager.get_env_str("目标项")
	var msg = ""
	var target = cmd.target_actor()
	var mood = 0
	match decision:
		"释放":
			if actorId == cmd.target_vstate().get_lord_id():
				msg += "吾"
			else:
				msg += "我主"
			msg += "仁以待人\n{0}自去罢！\n今日一别，是敌非友！".format([
				DataManager.get_actor_honored_title(target.actorId, actorId),
			])
			mood = 2
			cmd.canvass_result()
		"斩杀":
			msg = "背主之人，何足与论\n斩讫报来！"
			play_dialog(actorId, msg, mood, 2002)
			return
		"收监":
			msg = "左右拿下！收监论罪"
			clCity.move_out(target.actorId)
			clCity.move_to_ceil(target.actorId, cmd.target_city().ID)
			# 这里仍要手动设置状态，原因是需要修改原势力
			# 否则会自动从监狱里出来
			target.set_status_captured(cmd.vstate().id)
	play_dialog(actorId, msg, mood, 2999)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_kill")
	return

func effect_10124_kill() -> void:
	var cmd = DataManager.get_current_policy_command()
	var target = cmd.target_actor()
	clCity.move_out(target.actorId)
	target.set_status_dead()
	var msg = "{0}死亡".format([target.get_name()])
	SceneManager.show_vstate_dialog(msg)
	LoadControl.set_view_model(2999)
	return
