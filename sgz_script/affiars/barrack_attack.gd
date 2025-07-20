extends "affairs_base.gd"

#出征
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤"
	
	FlowManager.bind_signal_method("attack_choose_target_city", self)
	FlowManager.bind_signal_method("attack_choose_actors", self)
	FlowManager.bind_signal_method("attack_check_all_go", self)
	FlowManager.bind_signal_method("attack_with_goods", self)
	FlowManager.bind_signal_method("attack_with_goods_confirm", self)
	FlowManager.bind_signal_method("attack_choose_main_actor", self)
	FlowManager.bind_signal_method("attack_use_orderbook_start", self)
	FlowManager.bind_signal_method("attack_all_decided", self)
	FlowManager.bind_signal_method("attack_use_orderbook_end", self)
	FlowManager.bind_signal_method("attack_annoucement", self)
	FlowManager.bind_signal_method("attack_animation", self)
	FlowManager.bind_signal_method("check_reinforcements", self)
	FlowManager.bind_signal_method("attack_into_war", self)

	FlowManager.clear_pre_history.append("attack_annoucement")

	return

#按键操控
func _input_key(delta: float):
	var scene = SceneManager.current_scene()
	match LoadControl.get_view_model():
		211:#选择城市
			var fromCity = clCity.city(DataManager.player_choose_city)
			scene.show_attackable_city_lines(fromCity.ID)
			var connectedEnemyCities = clCity.get_attackable_city_ids(fromCity).keys()
			var cityId = wait_for_choose_city(delta, "enter_barrack_menu", connectedEnemyCities)
			if cityId < 0:
				var currentPointedCityId = SceneManager.current_scene().get_curosr_point_city()
				if currentPointedCityId >= 0 \
					and currentPointedCityId != fromCity.ID \
					and currentPointedCityId != DataManager.get_env_int("内政.战争.上次选定"):
					var currentPointedCity = clCity.city(currentPointedCityId)
					var msg = "此为{0}".format([currentPointedCity.get_full_name()])
					#var leaderName = currentPointedCity.get_leader_name()
					#if leaderName != "":
					#	msg += "\n太守为{0}".format([leaderName])
					SceneManager.show_unconfirm_dialog(msg)
					SceneManager.dialog_msg_complete(true)
				return
			DataManager.set_env("内政.战争.上次选定", cityId)
			var targetCity = clCity.city(cityId)
			# 判断同盟
			if DataManager.is_alliance(targetCity.get_vstate_id(), fromCity.get_vstate_id()):
				var msg = "此为{0}\n不可攻击盟友".format([targetCity.get_full_name()])
				SceneManager.show_unconfirm_dialog(msg)
				return
			# 判断相连和归属
			if not cityId in connectedEnemyCities:
				var msg = "此为{0}\n无法进攻该城".format([targetCity.get_full_name()])
				SceneManager.show_unconfirm_dialog(msg)
				return
			var wf = DataManager.new_war_fight(fromCity.ID, targetCity.ID)
			scene.reset_view()
			FlowManager.add_flow("attack_choose_actors")
		212:#选择出征的武将
			if not wait_for_choose_actor("enter_barrack_menu"):
				return
			var city = clCity.city(DataManager.player_choose_city)
			var aindex = SceneManager.actorlist.get_select_actor()
			var actors:Array = SceneManager.actorlist.get_picked_actors()
			if aindex == -1:
				if actors.empty():
					return;
				DataManager.set_env("派遣武将", actors)
				if city.get_actors_count() > actors.size():
					FlowManager.add_flow("attack_with_goods")
				else:
					FlowManager.add_flow("attack_check_all_go")
			else:
				SceneManager.actorlist.set_actor_picked(aindex, get_max_attack_actors());
			actors = SceneManager.actorlist.get_picked_actors()
			SceneManager.actorlist.rtlMessage.text = "请选将 ({0}/{1})".format([
				actors.size(), get_max_attack_actors(),
			])
		213:#是否放弃此城
			wait_for_yesno("attack_with_goods", "enter_barrack_menu")
		214:#携带金、米、宝物数量
			#输入数字
			if not wait_for_number_input("attack_choose_actors", true):
				return
			#确认数量
			var conNumberInput = SceneManager.input_numbers.get_current_input_node()
			var number:int = conNumberInput.get_number()
			var goods = DataManager.get_env_int_array("携带数量")
			goods[SceneManager.input_numbers.input_index] = number
			DataManager.set_env("携带数量", goods)
			if SceneManager.input_numbers.next_input_index():
				var input = SceneManager.input_numbers.get_current_input_node();
				input.set_number(0,true);
			else:
				FlowManager.add_flow("attack_with_goods_confirm");
		215:#确认金米
			if Global.is_action_pressed_BY():
				if not SceneManager.dialog_msg_complete():
					return
				FlowManager.add_flow("attack_with_goods")
				return
			wait_for_yesno("attack_choose_main_actor", "enter_barrack_menu")
		220:#选择主将
			if not wait_for_choose_actor("enter_barrack_menu"):
				return
			var actorId = SceneManager.actorlist.get_select_actor();
			var actors = DataManager.get_env_int_array("派遣武将")
			actors.erase(actorId)
			actors.insert(0, actorId)
			DataManager.set_env("派遣武将", actors)
			FlowManager.add_flow("attack_all_decided")
		216:#命令书
			wait_for_yesno("attack_use_orderbook_end", "enter_barrack_menu")
		217:#空城攻击动画
			wait_for_confirmation("player_ready", "")
		218:
			wait_for_confirmation("check_reinforcements", "")
		219:#攻击动画
			wait_for_confirmation("attack_into_war", "")
		221:
			wait_for_confirmation("attack_animation", "")
		222:
			wait_for_confirmation("attack_annoucement", "")
	return

#选择出征城市
func attack_choose_target_city():
	SceneManager.clear_bottom()
	DataManager.twinkle_citys.clear()
	var scene:Control = SceneManager.current_scene()
	scene.cursor.show()
	var city = clCity.city(DataManager.player_choose_city)
	scene.set_city_cursor_position(city.ID)
	var msg = "兵出{0}\n进攻哪座城池？\n请指定".format([
		city.get_full_name(),
	])
	SceneManager.show_unconfirm_dialog(msg)
	LoadControl.set_view_model(211)
	return

#选择出征武将
func attack_choose_actors():
	var wf = DataManager.get_current_war_fight()
	SceneManager.current_scene().cursor.hide()
	var msg = "请选将 (开始键跳结束）"
	SceneManager.show_actorlist_army(wf.from_city().get_actor_ids(), true, msg, false)
	LoadControl.set_view_model(212)
	return

#攻击：判断空城
func attack_check_all_go():
	SceneManager.show_yn_dialog("是否放弃此城？")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(213)
	return

#输入携带金米数量
func attack_with_goods():
	var wf = DataManager.get_current_war_fight()
	var city = wf.from_city()
	var props = ["金", "米"]
	var limits = [city.get_gold(), city.get_rice()]
	var credited = wf.get_env_int("预扣金")
	if credited > 0:
		limits[0] -= credited
	DataManager.set_env("携带数量", [0,0,0,0])
	SceneManager.show_input_numbers("请选择携带的金、米数量", props, limits)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(214)
	return

#金米确认
func attack_with_goods_confirm():
	var goods = DataManager.get_env_int_array("携带数量")
	var msg = "携带金{0} 米{1}\n可否出征？".format([goods[0],goods[1]])
	SceneManager.show_yn_dialog(msg)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(215)
	return

#选择主将
func attack_choose_main_actor():
	var wf = DataManager.get_current_war_fight()
	var actors = DataManager.get_env_int_array("派遣武将")
	if wf.from_city().get_lord_id() in actors or actors.size() == 1:
		FlowManager.add_flow("attack_all_decided")
		return

	SceneManager.current_scene().cursor.hide()
	var msg = "请选择主将"
	SceneManager.show_actorlist_army(actors, false, msg, false)
	LoadControl.set_view_model(220)
	return

func attack_all_decided() -> void:
	var wf = DataManager.get_current_war_fight()
	wf.sendActors = DataManager.get_env_int_array("派遣武将")
	for actorId in wf.sendActors:
		if SkillHelper.auto_trigger_skill(actorId, 10022, "attack_use_orderbook_start"):
			return
	FlowManager.add_flow("attack_use_orderbook_start")
	return

#命令书
func attack_use_orderbook_start():
	var wf = DataManager.get_current_war_fight()
	if wf.get_env_int("不消耗命令书") > 0:
		FlowManager.add_flow("attack_use_orderbook_end")
		return
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否")
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(216)
	return

#命令书消耗动画
func attack_use_orderbook_end():
	var wf = DataManager.get_current_war_fight()
	for actorId in wf.from_city().get_actor_ids():
		if SkillHelper.auto_trigger_skill(actorId, 10011, "attack_animation"):
			return
	if wf.get_env_int("不消耗命令书") > 0:
		FlowManager.add_flow("attack_animation")
		return
	SceneManager.dialog_use_orderbook_animation("attack_animation")
	return

#动画
func attack_animation():
	SceneManager.cleanup_animations()
	var wf = DataManager.get_current_war_fight()
	var fromCity = wf.from_city()
	var targetCity = wf.target_city()
	#记录战争历史
	DataManager.record_war_history(fromCity, targetCity)
	if targetCity.get_vstate_id() != -1 and targetCity.get_actors_count() > 0:
		#非空城，进入战争模式
		_ready_to_war()
		return

	#更改归属
	targetCity.set_vstate_id(wf.fromVstateId)
	
	var goods = DataManager.get_env_int_array("携带数量")
	#攻方城内去除出征的武将
	for actorId in wf.sendActors:
		clCity.move_to(actorId, targetCity.ID)
	
	#城内剩余武将更新
	if fromCity.get_actors_count() == 0:
		fromCity.set_vstate_id(-1)
	#物资运输
	fromCity.add_gold(-goods[0])
	fromCity.add_rice(-goods[1])
	targetCity.add_gold(goods[0])
	targetCity.add_rice(goods[1])
	#空城，直接占领
	DataManager.set_env("对话", "")
	var msg = "已顺利拿下{0}".format([
		targetCity.get_name(),
	])
	var speaker = wf.sendActors[0]
	var mood = 2
	SceneManager.play_affiars_animation("Barrack_Attack", "", false, msg, speaker, mood)
	LoadControl.set_view_model(217)
	return

#检查援军
func check_reinforcements():
	var wf = DataManager.get_current_war_fight()
	if wf.defenderWV.get_main_controlNo() >= 0:
		return
	# AI 在这里考虑援军
	var maxScore = -1
	var reinforcementCity = null
	var reinforcements = []
	var reinforcementMin = 3
	var reinforcementMax = 3
	if wf.sendActors.size() >= 5:
		reinforcementMax = 5
	var riceCost = 0
	for connectedId in wf.target_city().get_connected_city_ids([wf.targetVstateId]):
		var connectedCity = clCity.city(connectedId)
		var candidates = []
		var actorIds = connectedCity.get_actor_ids()
		if actorIds.size() <= reinforcementMin:
			# 人太少了，算了
			continue
		for actorId in actorIds:
			var actor = ActorHelper.actor(actorId)
			# 君主不去
			if actor.get_loyalty() == 100:
				continue
			# 兵少不去
			if actor.get_soldiers() < 1000:
				continue
			candidates.append(actor)
		candidates.sort_custom(Global.actorComp, "by_power")
		if candidates.size() >= reinforcementMax:
			candidates = candidates.slice(0, reinforcementMax - 1)
		if candidates.size() == actorIds.size():
			candidates.pop_back()
		var score = 0
		var riceEstimation = 0
		var availables = []
		while not candidates.empty():
			var c = candidates.pop_front()
			score += c.get_power_score() * c.get_soldiers()
			# 按20天预估粮草，留一些余粮
			riceEstimation += int(c.get_soldiers() / 250) * 20
			if connectedCity.get_rice() < riceEstimation * 2 + 100:
				break
			availables.append(c)
		if availables.size() < reinforcementMin:
			continue
		if score > maxScore:
			maxScore = score
			reinforcementCity = connectedCity
			reinforcements = availables
			riceCost = riceEstimation
	if reinforcementCity == null or reinforcements.empty():
		FlowManager.add_flow("attack_into_war")
		return
	var wv = War_Vstate.new(reinforcementCity.get_vstate_id(), true)
	wv.side = "防守方"
	wv.from_cityId = reinforcementCity.ID
	wv.init_actors = []
	wv.main_actorId = -1
	wv.money = 0
	wv.rice = riceCost
	wv.settled = 0
	# 扣减粮草
	reinforcementCity.add_rice(-riceCost)
	# 记住当前的武将id顺序
	wv.fromCityActorIds = reinforcementCity.get_actor_ids()
	# 武将出列
	for r in reinforcements:
		clCity.move_out(r.actorId)
		wv.init_actors.append(r.actorId)
	wv.main_actorId = wv.init_actors[0]
	# 援军三天后到达战场
	wv.pendingDates = 3
	wf.extraWV = wv
	var msg = "{0}已从{1}派出援军\n预计{2}天后到达战场".format([
		reinforcementCity.vstate().get_lord_name(),
		reinforcementCity.get_full_name(), wf.extraWV.pendingDates,
	])
	DataManager.twinkle_citys = [wf.fromCityId, wf.targetCityId, reinforcementCity.ID]
	SceneManager.show_confirm_dialog(msg, wf.sendActors[0])
	LoadControl.set_view_model(219)
	return

#进入战争界面
func attack_into_war():
	var wf = DataManager.get_current_war_fight()
	wf.init_war()
	SceneManager.show_cityInfo(false)
	
	if FlowManager.controlNo != AutoLoad.playerNo:
		return

	LoadControl.end_script()
	FlowManager.clear_bind_method()
	FlowManager.add_flow("go_to_scene|res://scene/scene_war/scene_war.tscn")
	FlowManager.add_flow("war_run_start")
	return

func _ready_to_war():
	var wf = DataManager.get_current_war_fight()
	var goods = DataManager.get_env_int_array("携带数量")
	
	#攻方，城内扣减带出的金、米
	var fromCity = wf.from_city()
	var targetCity = wf.target_city()

	fromCity.add_gold(-goods[0])
	fromCity.add_rice(-goods[1])

	# 记住当前的武将id顺序
	var fromCityActorIds = fromCity.get_actor_ids()

	var mainActorId:int = -1
	#攻方城内去除出征的武将
	for actorId in wf.sendActors:
		clCity.move_out(actorId)
		if actorId == fromCity.get_lord_id():
			mainActorId = actorId
	
	if mainActorId != -1:
		wf.sendActors.erase(mainActorId)
		wf.sendActors.insert(0, mainActorId)

	if fromCity.get_actors_count() == 0:
		fromCity.set_vstate_id(-1)
	
	#写入守方情况
	var defenderWV = War_Vstate.new(wf.targetVstateId)
	defenderWV.side = "防守方"
	defenderWV.from_cityId = targetCity.ID
	defenderWV.init_actors = targetCity.get_actor_ids()
	defenderWV.main_actorId = defenderWV.init_actors[0]
	defenderWV.money = targetCity.get_gold()
	defenderWV.rice = targetCity.get_rice()
	wf.defenderWV = defenderWV
	
	targetCity.set_property("金", 0)
	targetCity.set_property("米", 0)
	targetCity.clear_actors()
	
	#写入进攻方情况
	var attackerWV = War_Vstate.new(wf.fromVstateId)
	attackerWV.side = "攻击方"
	attackerWV.from_cityId = fromCity.ID
	attackerWV.init_actors = wf.sendActors.duplicate()
	attackerWV.main_actorId = attackerWV.init_actors[0]
	attackerWV.money = goods[0]
	attackerWV.rice = goods[1]
	# 记住当前的武将id顺序
	attackerWV.fromCityActorIds = fromCityActorIds
	wf.attackerWV = attackerWV

	wf.defenderWV.vstate().hate(wf.attackerWV.vstate().id)
	
	fromCity.add_chaos_score(5)
	targetCity.add_chaos_score(5)

	var messages = wf.get_env_array("攻击宣言")
	if wf.attackerWV.init_actors.size() > 10:
		var msg = "{0}人马，如此雄壮\n何愁不克{1}！".format([
			fromCity.get_region(), targetCity.get_full_name()
		])
		messages.append([msg, fromCity.get_lord_id(), 0])
	if wf.get_env_int("跳过默认攻击宣言") <= 0:
		messages.append(["势必攻下该城", wf.attackerWV.init_actors[0], 0])
	wf.set_env("攻击宣言", messages)
	FlowManager.add_flow("attack_annoucement")
	return

func attack_annoucement()->void:
	var wf = DataManager.get_current_war_fight()
	var messages = wf.get_env_array("攻击宣言")
	if messages.empty():
		FlowManager.add_flow("check_reinforcements")
		return
	var message = messages.pop_front()
	var msg = message[0]
	var speaker = int(message[1])
	var mood = int(message[2])
	wf.set_env("攻击宣言", messages)

	DataManager.twinkle_citys = [wf.from_city().ID, wf.target_city().ID]
	if messages.empty():
		# 最后一条
		SceneManager.play_affiars_animation("Barrack_Attack", "", false, msg, speaker, mood)
		LoadControl.set_view_model(218)
	else:
		# 还没说完
		SceneManager.show_confirm_dialog(msg, speaker, mood)
		LoadControl.set_view_model(222)
	return

func get_max_attack_actors()->int:
	var city = clCity.city(DataManager.player_choose_city)
	if SkillHelper.actor_has_skills(city.get_lord_id(), ["雄壮"]):
		return 12
	return 10
