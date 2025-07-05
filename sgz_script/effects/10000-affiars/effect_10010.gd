extends "effect_10000.gd"

#荐才效果一及误信，推荐在野
#【荐才】内政，锁定技。每年一月、五月。九月，若势力范围内的城池内有在野武将，则自动寻得一位加入本城。他势力的易招揽武将若拒绝加入，则由你出面说服，概率为5*你的等级%
#【误信】内政，转换技·锁定。你视为拥有技能<荐才>。若你当前所在势力不是“初次出仕的势力”（@初势力），且该势力未灭亡，则你永久转为<阴>。

const EFFECT_ID = 10010
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10001()->bool:
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)

	if DataManager.month % 4 != 1: # 1/5/9
		return false

	for c in clCity.all_cities([city.get_vstate_id()]):
		for targetId in clCity.get_unoffice_actors(c.ID):
			var targetActor = ActorHelper.actor(targetId)
			if not targetActor.is_status_unofficed():
				continue
			if targetActor.get_dislike_vstate_id() == city.get_vstate_id():
				continue
			# 模拟搜到人
			var cmd = DataManager.new_search_command(cityId, actorId)
			cmd.result = 5
			cmd.foundActorId = targetActor.actorId
			cmd.actorCost = 0
			return true

	# 若要测试荐才效果，可 uncomment 下面五行
	#var cmd = DataManager.new_search_command(cityId, actorId)
	#cmd.result = 5
	#cmd.foundActorId = StaticManager.ACTOR_ID_ZHUGELIANG
	#cmd.actorCost = 0
	#return true

	return false

func effect_10010_AI_start():
	var cmd = DataManager.get_current_search_command()
	# AI 直接获得
	cmd.force_actor_join(cmd.foundActorId)

	var reporter = -1
	for p in DataManager.players:
		if p.actorId >= 0:
			reporter = p.actorId
			break
	SoundManager.play_anim_bgm("res://resource/sounds/se/Strategy02.ogg")
	DataManager.twinkle_citys = [cmd.cityId]
	var msg = "据报\n{0}引荐{1}加入{2}军\n出仕于{3}".format([
		cmd.actioner().get_name(), cmd.found_actor().get_name(),
		cmd.city().get_lord_name(), cmd.city().get_name(),
	])
	SceneManager.show_confirm_dialog(msg, reporter, 2)
	LoadControl.set_view_model(3000)
	return

func on_view_model_3000_delta(delta:float):
	Global.wait_for_confirmation(FLOW_BASE + "_AI_end", "", delta)
	return

func effect_10010_AI_end():
	var cmd = DataManager.get_current_search_command()
	SceneManager.hide_all_tool()
	var msg = "{0} 军 战略中".format([
		cmd.vstate().get_dynasty_title_or_lord_name()
	])
	SceneManager.show_vstate_dialog(msg)
	DataManager.twinkle_citys = []
	LoadControl.end_script()
	return

func effect_10010_start():
	var cmd = DataManager.get_current_search_command()

	var greeting = "贺喜主公！\n在下寻访到一位{0}，特为引荐"
	if actor.get_loyalty() == 100:
		greeting = "可喜可贺！\n寻访到一位{0}"
	var found = cmd.found_actor()
	var title = "贤才"
	if found.get_power() >= 80:
		title = "猛将"
	if found.get_wisdom() >= 80:
		title = "大才"
	greeting = greeting.format([title])
	DataManager.twinkle_citys = [cmd.cityId]
	SceneManager.show_confirm_dialog(greeting, actorId, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10010_2():
	var cmd = DataManager.get_current_search_command()
	var found = cmd.found_actor()

	# 取荐才者与君主之间相性相近者计算忠诚度
	cmd.distance = actor.personality_distance(found)
	cmd.distance = min(cmd.distance, cmd.lord().personality_distance(found))
	# 无条件加入
	cmd.actorJoin = 1
	cmd.actorCost = 0
	cmd.accept_actor()
	var greeting = "{0}不才\n愿为主公执鞭坠镫"
	if found.get_power() >= 80:
		greeting = "{0}不才\n愿为主公扫荡天下"
	if found.get_wisdom() >= 80:
		greeting = "{0}不才\n愿随主公开万世太平"
	greeting = greeting.format([found.get_name()])
	DataManager.twinkle_citys = [cmd.cityId]
	SceneManager.show_confirm_dialog(greeting, found.actorId)
	LoadControl.set_view_model(2999)
	return
