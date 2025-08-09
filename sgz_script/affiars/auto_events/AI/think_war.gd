extends "res://script/controls.gd"

const wait_sec = 0.8;

var ias;

#AI-战争决策
func _init() -> void:
	LoadControl.view_model_name = "内政-AI-步骤";
	ias = Global.load_script(DataManager.mod_path+"sgz_script/affiars/auto_events/AI/IAffiarsStrategy.gd")
	FlowManager.bind_import_flow("AI_War", self)
	FlowManager.bind_import_flow("AI_War_1", self)
	FlowManager.bind_import_flow("AI_War_2", self)
	FlowManager.bind_import_flow("AI_War_3_AI", self)
	FlowManager.bind_import_flow("AI_War_4_AI", self)
	FlowManager.bind_import_flow("AI_War_3_player", self)
	FlowManager.bind_import_flow("AI_VS_PLAYER_before_war", self)
	FlowManager.bind_import_flow("AI_VS_PLAYER_reinforce", self)
	FlowManager.bind_import_flow("AI_VS_PLAYER_reinforce_leader", self)
	FlowManager.bind_import_flow("AI_VS_PLAYER_reinforce_resource", self)
	FlowManager.bind_import_flow("AI_VS_PLAYER_reinforce_confirm", self)
	FlowManager.bind_import_flow("AI_VS_PLAYER_reinforce_go", self)
	FlowManager.bind_import_flow("AI_VS_PLAYER_into_war", self)
	FlowManager.bind_import_flow("AI_VS_AI_into_war", self)
	return

#按键操控
func _input_key(delta: float):
	SceneManager.skip_tips = false
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		106:#AI攻击确认
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			FlowManager.add_flow("AI_VS_PLAYER_before_war")
		107:#观战AI确认
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				SceneManager.actor_dialog.lsc.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				SceneManager.actor_dialog.lsc.move_right()
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			LoadControl.set_view_model(-1)
			match SceneManager.actor_dialog.lsc.cursor_index:
				0:
					FlowManager.add_flow("AI_War_3_player")
				1:
					FlowManager.add_flow("AI_War_3_AI")
		117:
			SceneManager.skip_tips = true
			var wf = DataManager.get_current_war_fight()
			var candidateCityIds = DataManager.get_env_int_array("可选目标")
			var forbidden = DataManager.get_env_dict("不可选目标")
			var cityId = wait_for_choose_city(delta, "AI_VS_PLAYER_into_war", candidateCityIds)
			if cityId < 0:
				return
			if str(cityId) in forbidden:
				var msg = forbidden[str(cityId)]
				SceneManager.show_unconfirm_dialog(msg, wf.target_city().get_leader_id(), 2)
				return
			# 判断相连和归属
			var city = clCity.city(cityId)
			if cityId == wf.target_city().ID:
				var msg = "请选择援军城市"
				SceneManager.show_unconfirm_dialog(msg, wf.target_city().get_leader_id(), 2)
				return
			if city.get_vstate_id() != wf.target_city().get_vstate_id():
				var msg = "{0}不是我方城池".format([city.get_name()])
				SceneManager.show_unconfirm_dialog(msg, wf.target_city().get_leader_id(), 2)
				return
			if not cityId in candidateCityIds:
				var msg = "道路不通\n无法从{0}派出援军".format([city.get_name()])
				SceneManager.show_unconfirm_dialog(msg, wf.target_city().get_leader_id(), 2)
				return
			if city.get_rice() <= 0:
				var msg = "{0}粮草已尽\n无法派出援军".format([city.get_name()])
				SceneManager.show_unconfirm_dialog(msg, wf.target_city().get_leader_id(), 3)
				return
			DataManager.set_env("援军城", cityId)
			FlowManager.add_flow("AI_VS_PLAYER_reinforce")
		118:
			SceneManager.skip_tips = true
			if not wait_for_choose_actor("AI_VS_PLAYER_before_war"):
				return
			var cityId = DataManager.get_env_int("援军城")
			var city = clCity.city(cityId)
			var limit = 5
			var aindex = SceneManager.actorlist.get_select_actor()
			var actors:Array = SceneManager.actorlist.get_picked_actors()
			if aindex == -1:
				if actors.empty():
					return
				DataManager.set_env("援军武将", actors)
				FlowManager.add_flow("AI_VS_PLAYER_reinforce_leader")
			else:
				SceneManager.actorlist.set_actor_picked(aindex, limit)
			actors = SceneManager.actorlist.get_picked_actors()
			SceneManager.actorlist.rtlMessage.text = "请选将 ({0}/{1})".format([
				actors.size(), limit
			])
		119:
			SceneManager.skip_tips = true
			if not wait_for_choose_actor(""):
				return
			var actorId = SceneManager.actorlist.get_select_actor()
			var actorIds = DataManager.get_env_int_array("援军武将")
			actorIds.erase(actorId)
			actorIds.insert(0, actorId)
			DataManager.set_env("援军武将", actorIds)
			FlowManager.add_flow("AI_VS_PLAYER_reinforce_resource")
		120:
			SceneManager.skip_tips = true
			#输入数字
			if not wait_for_number_input("AI_VS_PLAYER_reinforce"):
				return
			#确认数量
			var conNumberInput = SceneManager.input_numbers.get_current_input_node()
			var number:int = conNumberInput.get_number()
			var goods = DataManager.get_env_int_array("携带数量")
			goods[SceneManager.input_numbers.input_index] = number
			DataManager.set_env("携带数量", goods)
			if SceneManager.input_numbers.next_input_index():
				var input = SceneManager.input_numbers.get_current_input_node();
				input.set_number(0, true)
			else:
				FlowManager.add_flow("AI_VS_PLAYER_reinforce_confirm");
		121:#确认金米
			SceneManager.skip_tips = true
			wait_for_yesno("AI_VS_PLAYER_reinforce_go", "AI_VS_PLAYER_reinforce_resource")
		122:
			SceneManager.skip_tips = true
			wait_for_confirmation("AI_VS_PLAYER_into_war")
	return

#获取AI战略行进路线
func AI_War():
	LoadControl.set_view_model(100);
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var vs = clVState.vstate(vstateId)
	var cur = DataManager.year * 12 + DataManager.month
	var startingYear = StaticManager.get_starting_year(DataManager.drama_path)
	var startingMonth = StaticManager.get_starting_month(DataManager.drama_path)
	var monthPassed = cur - startingYear * 12 - startingMonth
	if DataManager.diffculities == 0 and monthPassed < 12:
		# 简单难度下，开局12个月内，AI 不会发动战争
		FlowManager.add_flow("AI_next")
		return
	elif DataManager.diffculities <= 2 and monthPassed < 6:
		# 普通和困难难度下，开局6个月内，AI 不会发动战争
		FlowManager.add_flow("AI_next")
		return

	var targetCityId = think_about_target_city_id(vstateId)
	if targetCityId < 0:
		FlowManager.add_flow("AI_next")
		return
	DataManager.game_trace("  {0}军战争决策: 攻击{1}".format([
		vs.get_lord_name(), clCity.city(targetCityId).get_name(),
	]))
	DataManager.set_env("战争城", targetCityId)
	FlowManager.add_flow("AI_War_1")
	return

#思考可行性
func AI_War_1()->void:
	LoadControl.set_view_model(101);
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var vs = clVState.vstate(vstateId)
	var targetCityId = DataManager.get_env_int("战争城")
	var vstate_cityIds = DataManager.get_env_int_array("内政.AI城池")
	var targetCity = clCity.city(targetCityId)
	#目标城评分（AI思索要带不小于这个评分的武将）
	var enemy_actor_score = 0;

	var targetActors = targetCity.get_actor_ids()
	for i in targetActors.size():
		var actorId = targetActors[i]
		if i > 10:#不考虑超10人的分数
			break;
		var actor = ActorHelper.actor(actorId)
		var actor_score = actor.get_leadership() * min(99, actor.get_soldiers()/20)
		enemy_actor_score+=actor_score;
	# 本月已经从哪些城出发打过目标
	var repeatedFromCityIds = []
	for record in DataManager.war_history:
		if DataManager.year != record[0]:
			continue
		if DataManager.month != record[1]:
			continue
		if vstateId != record[2]:
			continue
		repeatedFromCityIds.append(record[3])
	#寻找目标相邻的己方城池中，评分最高的武将组合
	var from_cityId = -1;
	var send_actors = [];
	var max_actors_score = 0;
	var max_city_score = 0
	#先寻找最适合出发的城池
	for cityId in targetCity.get_connected_city_ids([vstateId]):
		# 排除同月从同一城池出发的连续攻击
		if cityId in repeatedFromCityIds:
			continue
		var city = clCity.city(cityId)
		#寻找己方城池最多的城
		var city_score = city.get_connected_city_ids([vstateId]).size()
		if city_score >= max_city_score:
			max_city_score = city_score
			from_cityId = cityId
	if avoid_too_many_wars(from_cityId, targetCity.ID):
		DataManager.game_trace("玩家保护-跳过战争")
		FlowManager.add_flow("AI_next")
		return

	#来源城
	var fromCity = clCity.city(from_cityId)
	
	#应该按照周边城的留守人数决定最多留多少人
	var diffcuilts_max_need_nums = [5,3,2,2,2];
	var need_defence_num = 0;
	#敌人城市最大几个，就留几个
	for near_cityId in fromCity.get_connected_city_ids():
		if near_cityId == targetCity.ID:
			#跳过目标城本身
			continue
		var nearCity = clCity.city(near_cityId)
		if nearCity.get_vstate_id() == vstateId:
			continue;
		var actors_num = min(diffcuilts_max_need_nums[DataManager.diffculities], nearCity.get_actors_count());
		
		if(actors_num > need_defence_num):
			need_defence_num = actors_num;
			
	#派出武将
	var temp_actors = [];
	var total_score = 0;
	
	while(true):
		var max_score = 0;
		var send_actorId:int = -1;
		var least_num = fromCity.get_actors_count()-temp_actors.size();
		var diff_fix = [-3,-3,1,0]
		if(least_num <= need_defence_num || temp_actors.size()>=10):
			break;
		for actorId in fromCity.get_actor_ids():
			if(temp_actors.has(actorId)):
				continue;
			if fromCity.get_actors_count() <= 1:
				continue;
			var actor = ActorHelper.actor(actorId)
			if actor.is_injured():
				continue;
			var max_sodiers = DataManager.get_actor_max_soldiers(actorId);
			actor.set_soldiers(min(max_sodiers, actor.get_soldiers()+Global.get_random(5,9)*100))
			if actor.get_soldiers() < 1000:
				#小于1000兵，不出战，先征兵
				continue;
			if(actorId==vs.get_lord_id()):
				continue;#君主不出征
			var actor_score = (actor.get_power()+actor.get_wisdom()+actor.get_leadership())/3 * max(1,actor.get_soldiers())/10;
			if(max_score<actor_score):
				max_score = actor_score;
				send_actorId = actorId;
		if(send_actorId>=0 && !temp_actors.has(send_actorId)):
			temp_actors.append(send_actorId);
			total_score+=max_score;
		else:
			#如果人数不够，从邻城移动武将
			for nearCityId in _get_all_link_city(fromCity.ID, fromCity.get_vstate_id()):
				var nearCity = clCity.city(nearCityId)
				if nearCity.get_vstate_id() != vstateId:
					continue;
				var actorsCount = nearCity.get_actors_count()
				if actorsCount <= 1 or actorsCount <= need_defence_num:
					continue;
				for actorId in nearCity.get_actor_ids():
					if(temp_actors.has(actorId)):
						continue;
					var actor = ActorHelper.actor(actorId)
					if actor.is_injured():
						continue;
					var max_sodiers = DataManager.get_actor_max_soldiers(actorId);
					actor.set_soldiers(min(max_sodiers, actor.get_soldiers()+Global.get_random(5,9)*100))
					if actor.get_soldiers() < 1000:
						#小于1000兵，不出战
						continue;
					if(actorId==vs.get_lord_id()):
						continue;#君主不出征
					var actor_score = (actor.get_power()+actor.get_wisdom()+actor.get_leadership())/3 * max(1,actor.get_soldiers())/10;
					if(max_score<actor_score):
						max_score = actor_score;
						send_actorId = actorId;
				if(send_actorId>=0 && !temp_actors.has(send_actorId)):
					send_actorId = int(send_actorId);
					clCity.move_to(send_actorId, fromCity.ID)
					temp_actors.append(send_actorId);
					total_score+=max_score;
					if nearCity.get_actors_count() == 0:
						nearCity.change_vstate(-1)
				if temp_actors.size()+1 >= targetCity.get_actors_count():
					break;
		if(send_actorId<0):
			FlowManager.add_flow("AI_next");
			return;

	if(enemy_actor_score>total_score && temp_actors.size()<10):
		if(Global.get_rate_result(90)):
			FlowManager.add_flow("AI_next");
			return;

	max_actors_score = total_score;
	send_actors = temp_actors.duplicate();

	var add_score_array = [-10000,0,5000,10000,10000];
	if(from_cityId<0):
		FlowManager.add_flow("AI_next");
		return;
	
	if(send_actors.size()==0):
		FlowManager.add_flow("AI_next");
		return;
	
	var war_rate = 90;
	if(max_actors_score+add_score_array[DataManager.diffculities] <enemy_actor_score):
		war_rate = [5,5,20,40,40][DataManager.diffculities];
	
	if(!Global.get_rate_result(war_rate) && send_actors.size()<10):
		FlowManager.add_flow("AI_next");
		return;
	
	#判断携带的金米是否足够
	var war_need_rice = send_actors.size() * 4*10
	var war_need_money = send_actors.size() * 10
	var fix_money = Global.get_random(0,40);
	
	if(Global.get_rate_result(50)):
		war_need_money -= fix_money;
		if war_need_money < 0: war_need_money = 0
	else:
		war_need_money += fix_money;
	if fromCity.get_gold() < war_need_money:
		var max_money = 100;
		var max_money_cityId = -1;
		var send_money = 0;
		#A55C
		fromCity.add_gold(war_need_money - fromCity.get_gold())
		DataManager.orderbook -=2;
		
		FlowManager.add_flow("AI_next");
		return;
		
	#A727
	if fromCity.get_rice() < war_need_rice:
		var max_rice = 100;
		var max_rice_cityId = -1;
		var send_rice = 0;
		var c_bool = true;
		fromCity.add_rice(war_need_rice - fromCity.get_rice())
		DataManager.orderbook -= 2
		FlowManager.add_flow("AI_next");
		return;

	# 必须在这里初始化，否则空城出击后面就找不到了
	var wf = DataManager.new_war_fight(fromCity.ID, targetCity.ID)
	#A79C
	fromCity.add_gold(-war_need_money)
	fromCity.add_rice(-war_need_rice)
	
	#防止派遣君主，但不是主将
	var lordId = vs.get_lord_id()
	if lordId in send_actors:
		send_actors = Array(PoolIntArray(send_actors))
		send_actors.erase(lordId)
		send_actors.insert(0,lordId)

	DataManager.orderbook -= send_actors.size() * 3
	
	if targetCity.get_vstate_id() == -1:
		targetCity.change_vstate(vstateId)
		# 占领空城，只派一个人去
		var send_actorId = send_actors.pop_back()
		clCity.move_to(send_actorId, targetCity.ID)
		targetCity.add_gold(war_need_money)
		targetCity.add_rice(war_need_rice)
		FlowManager.add_flow("AI_next")
		return

	wf.sendActors = send_actors.duplicate()
	for actorId in wf.sendActors:
		clCity.move_out(actorId)
	var targetVstate = clVState.vstate(wf.targetVstateId)
	targetVstate.relation_index_change(vstateId, -80)
	war_need_money = max(war_need_money, 0) + 300
	war_need_rice = max(war_need_rice, 0) + 300
	DataManager.set_env("携带金米", [war_need_money, war_need_rice])

	FlowManager.add_flow("AI_War_2")
	var msg = "- <y{0}>军从<r{1}>出击，攻击<y{2}>的<r{3}>".format([
		vs.get_lord_name(), fromCity.get_name(),
		targetVstate.get_lord_name(), targetCity.get_name(),
	])
	DataManager.record_affair_log(msg)
	return

#发起战争
func AI_War_2():
	var wf = DataManager.get_current_war_fight()
	LoadControl.set_view_model(102)
	var fromCity = wf.from_city()
	var fromVstate = wf.from_vstate()
	var targetCity = wf.target_city()
	var targetVstate = wf.target_vstate()
	
	fromCity.add_chaos_score(5)
	targetCity.add_chaos_score(5)
	
	#记录战争历史
	DataManager.record_war_history(fromCity, targetCity)
	#判断派遣武将中是否存在玩家
	for actorId in wf.sendActors:
		if DataManager.get_actor_controlNo(actorId) >= 0:
			FlowManager.add_flow("AI_War_3_player")
			return
	#判断防守方君主是否玩家
	if DataManager.get_actor_controlNo(targetVstate.get_lord_id()) >= 0:
		FlowManager.add_flow("AI_War_3_player")
		return
	_count_AI_win()
	#观海模式下，允许观战
	if DataManager.is_autoplay_mode() and Input.is_action_pressed("EMU_SELECT"):
		var msg = "{0}从{1}出兵\n攻击{2}的{3}\n是否观战？".format([
			fromVstate.get_lord_name(), fromCity.get_full_name(),
			targetVstate.get_lord_name(), targetCity.get_full_name(),
		])
		SceneManager.show_yn_dialog(msg, -5, 2)
		LoadControl.set_view_model(107)
		return
	FlowManager.add_flow("AI_War_3_AI")
	return

#AI直接战斗，播放战斗动画
func AI_War_3_AI():
	var wf = DataManager.get_current_war_fight()
	LoadControl.set_view_model(103)
	SceneManager.hide_all_tool()
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var atk_win_rate = DataManager.get_env_int("攻方胜率")
	var winnerVstateId = DataManager.get_env_int("结算方")
	var winnerVS = clVState.vstate(winnerVstateId)
	var dialogs = [
		"{1}  军  战斗中\n  (胜率:{0}%)".format([atk_win_rate, vs.get_dynasty_title_or_lord_name()]),
		"{0}  军  胜利".format([winnerVS.get_dynasty_title_or_lord_name()])
	];
	DataManager.set_env("多段文字", dialogs)
	DataManager.twinkle_citys = [wf.from_city().ID, wf.target_city().ID]
	DataManager.player_choose_city = wf.from_city().ID;#防止动画遮挡城池
	
	var msg = "{0}  军  出征".format([vs.get_dynasty_title_or_lord_name()])
	SceneManager.play_affiars_animation(
		"AI_War", "AI_War_4_AI", true,
		msg, -1, 2,
		self,"wait_change_word"
	)
	return

func wait_change_word(frame:int):
	if frame in [7,17]:
		var dialogs = DataManager.get_env_array("多段文字")
		if dialogs.size() > 0:
			SceneManager.show_vstate_dialog(dialogs.pop_front())
	return

#处理战后数据
func AI_War_4_AI():
	var wf = DataManager.get_current_war_fight()
	LoadControl.set_view_model(104);
	DataManager.twinkle_citys = [];
	SceneManager.hide_all_tool();
	var atk_res = DataManager.get_env_int_array("携带金米")
	var atk_money = int(atk_res[0])
	var atk_rice = int(atk_res[1])
	
	var wonVstateId = DataManager.get_env_int("结算方")
	
	var fromCity = wf.from_city()
	var warCity = wf.target_city()
	var attackingActors = wf.sendActors
	var defendingActors = wf.target_city().get_actor_ids()
	var attackerMorale = DataManager.get_env_int("攻方气势")
	var defenderMorale = DataManager.get_env_int("守方气势")
	var attackerLossRate = defenderMorale * 1.0 / max(1.0, attackerMorale + defenderMorale)
	var defenderLossRate = attackerMorale * 1.0 / max(1.0, attackerMorale + defenderMorale)
	
	var attackerTotalLoss = 0;#攻方总计失去兵力
	#攻方根据守方气势，减少兵力和体力
	for actorId in attackingActors:
		var actor = ActorHelper.actor(actorId)
		var loss = int(actor.get_soldiers() * attackerLossRate)
		actor.set_soldiers(actor.get_soldiers() - loss)
		attackerTotalLoss += loss
		
	var defenderTotalLoss = 0;#守方总计失去兵力
	#守方根据攻方气势，减少兵力和体力
	for actorId in defendingActors:
		var actor = ActorHelper.actor(actorId)
		var loss = int(actor.get_soldiers() * defenderLossRate)
		actor.set_soldiers(actor.get_soldiers() - loss)
		defenderTotalLoss += loss

	var duration = Global.get_random(5, 15)
	wf.target_city().add_rice(duration * 4 * defendingActors.size())
	atk_rice -= min(atk_rice, duration * 4 * attackingActors.size())
	
	var attackerEXP = int(defenderTotalLoss / max(1, attackingActors.size()))
	var defenderEXP = int(attackerTotalLoss / max(1, defendingActors.size()))
	#如果守方胜利
	if wonVstateId == wf.targetVstateId:
		#攻方全体退回原城
		for actorId in attackingActors:
			var actor = ActorHelper.actor(int(actorId))
			clCity.move_to(actor.actorId, fromCity.ID);
			DataManager.actor_add_Exp(actorId, attackerEXP, false)
			actor.set_hp(actor.get_hp() - max(0, Global.get_random(-15, 15)))

		#守方全体按兵不动
		for actorId in defendingActors:
			DataManager.actor_add_Exp(actorId, defenderEXP, false)

		# 攻方资源归位
		fromCity.add_gold(atk_money)
		fromCity.add_rice(atk_rice)

	#如果攻方胜利
	if wonVstateId == wf.fromVstateId:
		# 记录城池易主
		var conqueredCityIds = DataManager.get_env_int_array("内政.MONTHLY.城池易主")
		conqueredCityIds.append(warCity.ID)
		warCity.change_vstate(wf.fromVstateId)
		#攻方占领战争城
		warCity.clear_actors()
		#守方撤退逻辑
		_rand_actors_out(defendingActors, wf.targetVstateId, defenderEXP)

		for actorId in attackingActors:
			clCity.move_to(actorId, warCity.ID)
			DataManager.actor_add_Exp(actorId, attackerEXP, false)
		warCity.add_gold(atk_money)
		warCity.add_rice(atk_rice)

		#战后城池属性损失X/10
		_decrease("人口", Global.get_random(1,2))
		var dates = [21, 16, 11, 6]
		var losses = [6, 4, 3, 2]
		var loss = 1
		for i in dates.size():
			if wf.date >= dates[i]:
				loss = losses[i]
				break
		_decrease("土地", loss)
		_decrease("产业", loss)
		_decrease("统治度", loss)
	if fromCity.get_actors_count() == 0:
		fromCity.change_vstate(-1)
	var action = "攻占"
	if wonVstateId == wf.targetVstateId:
		action = "保卫"
	var winner = clVState.vstate(wonVstateId)
	DataManager.record_affair_log("  - 攻方胜率：{0}%，<y{1}>军胜利，{2}<r{3}>".format([
		DataManager.get_env_int("攻方胜率"),
		winner.get_lord_name(), action, warCity.get_name(),
	]), true)
	FlowManager.add_flow("check_actor_dead");
	return

func _decrease(proname:String,X:int):
	var wf = DataManager.get_current_war_fight()
	var warCity = wf.target_city()
	warCity.add_city_property(proname, -int(warCity.get_property(proname))*X/10)
	return

func AI_War_3_player():
	LoadControl.set_view_model(103)
	var goods = DataManager.get_env_int_array("携带金米")
	var wf = DataManager.get_current_war_fight()
	var fromVS = wf.from_vstate()
	var targetCity = wf.target_city()
	var fromCity = wf.from_city()

	DataManager.player_choose_city = fromCity.ID

	#写入守方情况
	var defenderWV = War_Vstate.new(targetCity.get_vstate_id(), false, false)
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
	var attackerWV = War_Vstate.new(fromVS.id, false, true)
	attackerWV.from_cityId = fromCity.ID
	attackerWV.init_actors = wf.sendActors.duplicate()
	attackerWV.main_actorId = attackerWV.init_actors[0]
	attackerWV.money = goods[0]
	attackerWV.rice = goods[1]
	wf.attackerWV = attackerWV

	wf.target_vstate().relation_index_change(fromVS.id, -80)

	var msg ="{0}急报！\n{1}军自{2}来犯！".format([
		targetCity.get_full_name(), fromVS.get_dynasty_title_or_lord_name(),
		fromCity.get_full_name(),
	])
	DataManager.twinkle_citys = [targetCity.ID, fromCity.ID]
	SceneManager.play_affiars_animation(
		"AI_Attack", "", false,
		msg, wf.defenderWV.main_actorId, 0
	)

	LoadControl.set_view_model(106)
	return

func AI_VS_PLAYER_before_war():
	Global.clear_waits()
	SceneManager.cleanup_animations()
	if DataManager.is_autoplay_mode():
		# 观海模式下按「选择」观战，无援军
		FlowManager.add_flow("AI_VS_PLAYER_into_war")
		return
	var wf = DataManager.get_current_war_fight()
	var targetCity = wf.target_city()
	var candidateCityIds = []
	var forbidden = {}
	for cityId in targetCity.get_connected_city_ids([targetCity.get_vstate_id()]):
		var city = clCity.city(cityId)
		if city.get_actor_ids().size() >= 2:
			candidateCityIds.append(cityId)
		else:
			forbidden[str(cityId)] = "武将不足，无法派出援军"
	if candidateCityIds.empty():
		FlowManager.add_flow("AI_VS_PLAYER_into_war")
		return
	DataManager.set_env("可选目标", candidateCityIds)
	DataManager.set_env("不可选目标", forbidden)
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.show()
	scene_affiars.set_city_cursor_position(candidateCityIds[0])
	SceneManager.show_unconfirm_dialog("是否需要援军？\n可选择邻接城市\n「B」键不指派援军", wf.defenderWV.main_actorId)
	LoadControl.set_view_model(117)
	return

#指派援军
func AI_VS_PLAYER_reinforce()->void:
	var cityId = DataManager.get_env_int("援军城")
	SceneManager.current_scene().cursor.hide()
	SceneManager.hide_all_tool()
	var city = clCity.city(cityId)
	var msg = "请选将 (开始键跳结束)"
	SceneManager.show_actorlist_army(city.get_actor_ids(), true, msg, false)
	LoadControl.set_view_model(118)
	return

#已选择援军武将，选择主将
func AI_VS_PLAYER_reinforce_leader()->void:
	var cityId = DataManager.get_env_int("援军城")
	var actorIds = DataManager.get_env_int_array("援军武将")
	var city = clCity.city(cityId)
	var lordId = city.get_lord_id()
	if lordId in actorIds:
		# 君主出援，自动主将
		actorIds.erase(lordId)
		actorIds.insert(0, lordId)
		DataManager.set_env("援军武将", actorIds)
		FlowManager.add_flow("AI_VS_PLAYER_reinforce_resource")
		return
	SceneManager.current_scene().cursor.hide()
	var msg = "请选择主将"
	SceneManager.show_actorlist_army(actorIds, false, msg, false)
	LoadControl.set_view_model(119)
	return

#输入携带金米数量
func AI_VS_PLAYER_reinforce_resource():
	var cityId = DataManager.get_env_int("援军城")
	var city = clCity.city(cityId)
	var props = ["金", "米"]
	var limits = [city.get_gold(), city.get_rice()]
	DataManager.set_env("携带数量", [0,0,0,0])
	SceneManager.show_input_numbers("请选择携带的金、米数量", props, limits)
	SceneManager.show_cityInfo(true, cityId)
	LoadControl.set_view_model(120)
	return

#金米确认
func AI_VS_PLAYER_reinforce_confirm():
	var cityId = DataManager.get_env_int("援军城")
	var actorIds = DataManager.get_env_int_array("援军武将")
	var goods = DataManager.get_env_int_array("携带数量")
	var msg = "携带金{0} 米{1}\n可否出征？".format([goods[0],goods[1]])
	SceneManager.show_yn_dialog(msg, actorIds[0])
	SceneManager.show_cityInfo(true, cityId)
	LoadControl.set_view_model(121)
	return

#派出援军
func AI_VS_PLAYER_reinforce_go()->void:
	var wf = DataManager.get_current_war_fight()
	var cityId = DataManager.get_env_int("援军城")
	var goods = DataManager.get_env_int_array("携带数量")
	var city = clCity.city(cityId)
	var actorIds = DataManager.get_env_int_array("援军武将")
	var wv = War_Vstate.new(city.get_vstate_id(), true, false)
	wv.from_cityId = city.ID
	wv.init_actors = []
	wv.main_actorId = -1
	wv.money = goods[0]
	wv.rice = goods[1]
	wv.settled = 0
	# 扣减粮草
	city.add_gold(-goods[0])
	city.add_rice(-goods[1])
	wv.fromCityActorIds = city.get_actor_ids()
	# 武将出列
	for actorId in actorIds:
		clCity.move_out(actorId)
		wv.init_actors.append(actorId)
	wv.main_actorId = wv.init_actors[0]
	# 援军三天后到达战场
	wv.pendingDates = 3
	wf.extraWV = wv
	SceneManager.hide_all_tool()
	var scene = SceneManager.current_scene()
	scene.cursor.show()
	scene.set_city_cursor_position(cityId)
	var msg = "遵命！即刻驰援{0}\n预计三天后到达战场".format([
		wf.target_city().get_full_name(),
	])
	SceneManager.show_confirm_dialog(msg, actorIds[0], 0)
	LoadControl.set_view_model(122)
	return

#进入战争界面
func AI_VS_PLAYER_into_war():
	DataManager.auto_save("defence")
	LoadControl.end_script()
	DataManager.twinkle_citys.clear()
	SceneManager.show_cityInfo(false)
	DataManager.twinkle_citys = []
	DataManager.war_control_sort = []
	var wf = DataManager.get_current_war_fight()
	wf.init_war()
	FlowManager._temp_save_data(true)
	if FlowManager.controlNo != AutoLoad.playerNo:
		return
	FlowManager.clear_bind_method()
	FlowManager.add_flow("go_to_scene|res://scene/scene_war/scene_war.tscn")
	FlowManager.add_flow("war_run_start")
	return

#无视距离获取相邻的己方城
func _get_all_link_city(from_cityId:int,vstateId:int)->PoolIntArray:
	var prointer = [];
	var results_array = [];
	var has_check = [from_cityId];
	prointer = [from_cityId];
	
	while(!prointer.empty()):
		var cityId = prointer.pop_front();
		var city = clCity.city(cityId)
		has_check.append(cityId);
		for near_cityId in city.get_connected_city_ids():
			if(has_check.has(near_cityId)):
				continue;
			var nearCity = clCity.city(near_cityId)
			if nearCity.get_vstate_id() != vstateId:
				continue;
			results_array.append(near_cityId);
			prointer.append(near_cityId);
	return results_array;

# 计算AI战斗胜率
# 约定必须写入的变量：
# 攻方气势、守方气势、攻方胜率、结算方
func _count_AI_win()->void:
	if DataManager.diffculities >= 4:
		# 挑战模式，尝试以武将为单位模拟
		# 避免战争结果过于随机
		_count_AI_win_4()
		return
	var wf = DataManager.get_current_war_fight()
	#城防因素 = 城防值 * 守方武将数 / 20
	#攻方胜率 = 攻方气势 * 100 / (守方气势 + 攻方气势 + 城防因素)
	var attackingActors = wf.sendActors
	var attackMorale = _get_morale(attackingActors)
	DataManager.set_env("攻方气势", attackMorale)
	var warCity = wf.target_city()
	var defendingActors = warCity.get_actor_ids()
	var defendeMorale = _get_morale(defendingActors)
	DataManager.set_env("守方气势", defendeMorale)

	var soldiers = 0
	for id in attackingActors:
		soldiers += ActorHelper.actor(id).get_soldiers()
	DataManager.record_affair_log("  - 攻方主将：<y{0}>，武将：<y{1}>，兵力：<y{2}>".format([
		ActorHelper.actor(attackingActors[0]).get_name(), attackingActors.size(), soldiers,
	]), true)
	soldiers = 0
	for id in defendingActors:
		soldiers += ActorHelper.actor(id).get_soldiers()
	DataManager.record_affair_log("  - 守方主将：<y{0}>，武将：<y{1}>，兵力：<y{2}>".format([
		ActorHelper.actor(defendingActors[0]).get_name(), defendingActors.size(), soldiers,
	]), true)

	var attackWinRate = attackMorale * 100 / (defendeMorale + attackMorale)
	var wonVstateId = warCity.get_vstate_id()
	if Global.get_rate_result(attackWinRate):
		wonVstateId = wf.from_vstate().id
	DataManager.set_env("攻方胜率", attackWinRate)
	DataManager.set_env("结算方", wonVstateId)
	return

# 计算AI战斗胜率
# 约定必须写入的变量：
# 攻方气势、守方气势、攻方胜率、结算方
func _count_AI_win_4()->void:
	var wf = DataManager.get_current_war_fight()
	var warCity = wf.target_city()
	var defenderVstateId = warCity.get_vstate_id()
	var attackerVstateId = wf.from_vstate().id

	var attackingActors = wf.sendActors
	var defendingActors = warCity.get_actor_ids()
	var attackingScores = []
	var defendingScores = []
	var attackingTotal = 0
	var defendingTotal = 0
	var attackerBuff = 1
	var defenderBuff = 1
	if DataManager.year >= 220:
		# 持久战御三家因子
		var supremeVstateIds = [StaticManager.VSTATEID_CAOCAO, StaticManager.VSTATEID_LIUBEI, StaticManager.VSTATEID_SUNJIAN]
		if attackerVstateId in supremeVstateIds:
			attackerBuff *= 1.4
		if defenderVstateId in supremeVstateIds:
			defenderBuff *= 1.4
		# 持久战大势力因子
		var attackerCityCount = clCity.all_cities([attackerVstateId]).size()
		var defenderCityCount = clCity.all_cities([defenderVstateId]).size()
		if attackerCityCount * 2 >= defenderCityCount * 3:
			attackerBuff *= 1.4
		elif attackerCityCount * 3 <= defenderCityCount * 2:
			defenderBuff *= 1.4
	for actorId in attackingActors:
		var actor = ActorHelper.actor(actorId)
		var power = actor.get_power()
		var leadership = actor.get_leadership()
		var wisdom = actor.get_wisdom()
		var score = power + leadership + wisdom
		if leadership > 90:
			score *= 1.2
		if wisdom > 90:
			score *= 1.2
		score *= actor.get_soldiers()
		score *= attackerBuff
		attackingScores.append(score)
		attackingTotal += score
	for i in range(0, min(15, defendingActors.size())):
		# 营帐超过5人就不计入了
		var actorId = defendingActors[i]
		var actor = ActorHelper.actor(actorId)
		var power = actor.get_power()
		var leadership = actor.get_leadership()
		var wisdom = actor.get_wisdom()
		var score = power + leadership + wisdom
		if leadership > 90:
			score *= 1.2
		if wisdom > 90:
			score *= 1.2
		score *= actor.get_soldiers()
		if i < 4:
			# 城防加成
			score *= 1.2
		elif i > 10:
			# 营帐减成
			score *= 0.3
		score *= defenderBuff
		defendingScores.append(score)
		defendingTotal += score
	# 总气势
	DataManager.set_env("攻方气势", attackingTotal)
	DataManager.set_env("守方气势", defendingTotal)
	# 下面开始分武将随机
	while not defendingScores.empty() and not attackingScores.empty():
		var defendingScore = defendingScores.pop_front()
		var attackingScore = attackingScores.pop_front()
		if defendingScore + attackingScore == 0:
			# 特殊情况，直接略过
			continue
		var attackingWinRate = attackingScore * 100 / (attackingScore + defendingScore)
		var actualWinRate = attackingWinRate
		# 减少一点极端情况的随机性
		if attackingWinRate >= 80:
			actualWinRate = 100
		elif attackingWinRate <= 20:
			actualWinRate = 0
		if Global.get_rate_result(actualWinRate):
			# 攻方胜出，攻方积分打折后放回池子，败方淘汰
			attackingScore = attackingScore - int(defendingScore * (100 - attackingWinRate) / 100)
			if attackingScore > 0:
				attackingScores.append(attackingScore)
		else:
			# 守方胜出，守方积分打折后放回池子，败方淘汰
			defendingScore = defendingScore - int(attackingScore * attackingWinRate / 100)
			if defendingScore > 0:
				defendingScores.append(defendingScore)
	var winRate = 50
	if attackingTotal + defendingTotal > 0:
		winRate = int(attackingTotal * 100 / (attackingTotal + defendingTotal))
	var wonVstateId = defenderVstateId
	if defendingScores.empty():
		if winRate < 50:
			winRate += 20
		wonVstateId = attackerVstateId
	else:
		if winRate > 50:
			winRate -= 20
	DataManager.set_env("攻方胜率", winRate)
	DataManager.set_env("结算方", wonVstateId)
	return

#获取气势
func _get_morale(actors:Array)->int:
	#单将能力 = (max(武力, 智力) + 统 ) / 2，大致范围 50 ~ 100
	#武将因子 = sum(单将能力) / 10，大致范围 20 ~ 80
	#兵力因子 = 总兵力 / 200，大致范围 20 ~ 100
	#战争气势 = 武将因子 + 兵力因子，大致范围 40 ~ 200
	#武、知最大值
	var max_value = 0;
	#单将能力合计
	var sum_value = 0;
	#兵力合计
	var sum_sodiers = 0;
	var i = 0
	for actorId in actors:
		var actor = ActorHelper.actor(actorId)
		#单将能力 = 武知最大值
		var actor_max_v = max(actor.get_power(), actor.get_wisdom())
		if(actor_max_v > max_value):
			max_value = actor_max_v;
		var soldiers = actor.get_soldiers()
		if i == 0:
			# 主将翻倍
			actor_max_v *= 2
			soldiers *= 2
		elif i >= 10:
			#兵营中的价值打折
			actor_max_v /= 3
			soldiers /= 3
		sum_value += actor_max_v
		sum_sodiers += soldiers
		i += 1
	#武将因子
	var actors_divisor = int(sum_value / 10);
	#兵力因子
	var sodiers_divisor = int(sum_sodiers / 200);
	#战争气势
	return int(min(200, actors_divisor + sodiers_divisor));

func _rand_actors_out(actors:PoolIntArray, vstateId:int, defenderEXP:float):
	var wf = DataManager.get_current_war_fight()
	var warCity = wf.target_city()
	var pendingActors = Array(actors)
	
	while not pendingActors.empty():
		var actorId = pendingActors.pop_front()
		DataManager.actor_add_Exp(actorId, defenderEXP, false)
		var actor = ActorHelper.actor(actorId)
		actor.set_prev_vstate_id(vstateId)
		var targetCityId = -1
		var score = 9999
		#先寻找相邻的己方城池
		for cityId in warCity.get_connected_city_ids([vstateId]):
			var city = clCity.city(cityId)
			if city.get_actors_count() < score:
				score = city.get_actors_count()
				targetCityId = cityId
		if targetCityId < 0:
			#找不到就找相邻的空城
			for cityId in warCity.get_connected_city_ids([-1]):
				targetCityId = cityId
				break
		if targetCityId < 0:
			#还是没有可撤的城就下野/俘虏
			_capture_actor(actorId, warCity.ID)
		else:
			#找到可撤退的城
			var retreatCity = clCity.city(targetCityId)
			retreatCity.change_vstate(vstateId)
			clCity.move_to(actorId, retreatCity.ID)
			retreatCity.add_gold(warCity.get_gold())
			retreatCity.add_rice(warCity.get_rice())
			warCity.set_property("金", 0)
			warCity.set_property("米", 0)
	return

func _capture_actor(actorId:int, capture_to_city_id:int)->void:
	var actor = ActorHelper.actor(actorId)
	var capture = true
	#["无","非君主","全武将","仅君主"],
	match DataManager.get_game_setting("监狱系统"):
		"非君主":
			if actor.get_loyalty() == 100:
				capture = false
		"仅君主":
			if actor.get_loyalty() != 100:
				capture = false
		"无":
			capture = false
	# 一半概率未能俘虏
	if capture and Global.get_rate_result(50):
		capture = false
	if capture:
		actor.set_hp(1)
		actor.set_status_captured()
		clCity.move_to_ceil(actor.actorId, capture_to_city_id)
	else:
		actor.set_hp(5)
		actor.set_loyalty(max(10, 79-actor.get_loyalty()))
		var exileTargetCityIds = clCity.city(capture_to_city_id).get_connected_city_ids()
		exileTargetCityIds.append(capture_to_city_id)
		exileTargetCityIds.shuffle()
		actor.set_status_exiled(-1, exileTargetCityIds[0])
	return

func think_about_target_city_id(vstateId:int)->int:
	var vs = clVState.vstate(vstateId)
	if DataManager.diffculities >= 4:
		# 挑战逻辑
		return think_about_target_city_id_4(vstateId)
	# 原有逻辑
	var final_way = [];
	var vstate_cityIds = DataManager.get_env_int_array("内政.AI城池")
	#己方有多个城市时，寻找去往指定处路线最长的路线，防止中间有节点被敌人占领
	for cityId in vstate_cityIds:
		var way:Array = ias.search_way(vstateId, cityId, vs.get_target_city_id());
		if(way.empty()):
			continue;
		if(way.size()>final_way.size()):
			final_way = way.duplicate();
	if(final_way.empty()):
		#没有战略目标时，不再继续
		return -1
	var ret = -1;
	for to in final_way:
		var toCity = clCity.city(to)
		if toCity.get_vstate_id() == vstateId:
			continue
		#盟友城池，避开
		if 0 < clVState.get_alliance_month(vstateId, toCity.get_vstate_id()):
			continue
		return to
	return -1

func think_about_target_city_id_4(vstateId:int)->int:
	var vs = clVState.vstate(vstateId)
	# 玩家高仇恨
	var fixKey = "内政.{0}攻击玩家".format([vstateId])
	var rate = DataManager.get_fix_v_rate(30, fixKey)
	var playerFirst = Global.get_rate_result(rate)
	DataManager.set_fix_rate_v(fixKey, playerFirst)
	DataManager.game_trace("  {0}军战争思考".format([
		vs.get_lord_name()
	]))
	# 我方所有城池
	var myCities = []
	for cityId in DataManager.get_env_int_array("内政.AI城池"):
		myCities.append(clCity.city(cityId))
	var candidates = {}
	# 优先找空城和孤城
	for city in myCities:
		for connectedId in city.get_connected_city_ids():
			if not _target_city_id_valid(vstateId, connectedId):
				continue
			var connectedCity = clCity.city(connectedId)
			var connectedVstateId = connectedCity.get_vstate_id()
			if connectedVstateId == -1 or connectedCity.get_connected_city_ids([connectedVstateId]).empty():
				candidates[connectedId] = connectedCity
	if not candidates.empty():
		return _choose_attack_target_city_from(vs, candidates.values(), "首要")
	# 先找到所有可攻击目标，同时，计算指标
	# 领地分了多少块（尽量连接）
	# 内部连接数（越密集越好）
	# 前线城市数（越少越好）
	var regions = {}
	var regionId = 0
	var frontierCityCount = 0
	var innerConnections = 0
	var targets = {}
	for city in myCities:
		if not city.ID in regions:
			regions[city.ID] = regionId
			regionId += 1
		var brothers = city.get_connected_city_ids([vstateId])
		for id in brothers:
			innerConnections += 1
			if id in regions:
				regions[city.ID] = regions[id]
				break
		for id in brothers:
			regions[id] = regions[city.ID]
		var enemyCount = 0
		for connectedId in city.get_connected_city_ids([], [vstateId]):
			if not _target_city_id_valid(vstateId, connectedId):
				continue
			var connectedCity = clCity.city(connectedId)
			if connectedCity.get_vstate_id() == -1:
				# 空城
				targets[connectedCity.ID] = connectedCity
			else:
				# 敌方城池
				targets[connectedCity.ID] = connectedCity
				enemyCount += 1
		if enemyCount > 0:
			frontierCityCount += 1
	# 优先寻找可以把两片孤岛链接起来的目标
	var parts = {}
	for id in regions:
		if not regions[id] in parts:
			parts[regions[id]] = []
		parts[regions[id]].erase(id)
		parts[regions[id]].append(id)
	parts = parts.values()
	candidates = {}
	if parts.size() > 1:
		DataManager.game_trace("    {0}军被分割为{1}块".format([
			vs.get_lord_name(), parts.size(),
		]))
		for targetCity in targets.values():
			if not _target_city_id_valid(vstateId, targetCity.ID):
				continue
			var partConnected = []
			var score = 0
			for i in parts.size():
				for connectedId in targetCity.get_connected_city_ids():
					if connectedId in parts[i]:
						score += 1
						break
			if score > 1:
				candidates[targetCity.ID] = targetCity
	if not candidates.empty():
		return _choose_attack_target_city_from(vs, candidates.values(), "优先")
	# 寻找玩家目标
	candidates = {}
	if playerFirst:
		for targetCity in targets.values():
			if not _target_city_id_valid(vstateId, targetCity.ID):
				continue
			if DataManager.get_actor_controlNo(targetCity.get_lord_id()) >= 0:
				candidates[targetCity.ID] = targetCity
	if not candidates.empty():
		return _choose_attack_target_city_from(vs, candidates.values(), "玩家")
	# 寻找后期战略目标
	candidates = {}
	if DataManager.year >= 220:
		# 游戏后期，优先看势力大小
		var score = int(myCities.size() / 2)
		var prioredVstateId = -1
		for targetCity in targets.values():
			if not _target_city_id_valid(vstateId, targetCity.ID):
				continue
			var targetVstateId = targetCity.get_vstate_id()
			var cityCount = clCity.all_cities([]).size()
			if cityCount < score:
				prioredVstateId = targetVstateId
				score = cityCount
		for targetCity in targets.values():
			if not _target_city_id_valid(vstateId, targetCity.ID):
				continue
			if targetCity.get_vstate_id() == prioredVstateId:
				candidates[targetCity.ID] = targetCity
	if not candidates.empty():
		return _choose_attack_target_city_from(vs, candidates.values(), "仇恨")
	# 在可选城市中按照指标得分排序
	# 指标参考内部连接数和前线城市数
	var maxScore = -5000
	candidates = {}
	for targetCity in targets.values():
		if not _target_city_id_valid(vstateId, targetCity.ID):
			continue
		var assumedMyCities = []
		assumedMyCities.append_array(myCities)
		assumedMyCities.append(targetCity)
		var assumedFrontierCityCount = 0
		var assumedInnerConnections = 0
		var assumedParts = parts.duplicate(true)
		for city in assumedMyCities:
			var enemyCityIds = city.get_connected_city_ids([], [vs.id, -1])
			enemyCityIds.erase(targetCity.ID)
			if enemyCityIds.size() > 0:
				assumedFrontierCityCount += 1
			var brotherIds = city.get_connected_city_ids([vs.id])
			assumedInnerConnections += brotherIds.size()
			if targetCity.ID != city.ID and targetCity.ID in city.get_connected_city_ids():
				assumedInnerConnections += 1
		var score = frontierCityCount - assumedFrontierCityCount
		score += (assumedInnerConnections - innerConnections) * 2
		if score > maxScore:
			maxScore = score
			candidates.clear()
			candidates[targetCity.ID] = targetCity
		elif score == maxScore:
			candidates[targetCity.ID] = targetCity
	if not candidates.empty():
		return _choose_attack_target_city_from(vs, candidates.values(), "可选")
	return -1

func _choose_attack_target_city_from(vs:clVState.VStateInfo, targets:Array, reason:String="")->int:
	var names = []
	for target in targets:
		names.append(target.get_name())
	DataManager.game_trace("    {0}军以{1}为{2}目标".format([
		vs.get_lord_name(), "、".join(names), reason,
	]))
	if targets.empty():
		return -1
	# 攻击弱者
	targets.sort_custom(self, "_sort_by_city_power")
	DataManager.game_trace("  {0}军攻击弱点城市{1}".format([
		vs.get_lord_name(), targets[0].get_name(),
	]))
	return targets[0].ID

func _sort_by_city_power(a:clCity.CityInfo, b:clCity.CityInfo)->bool:
	var scoreA = _get_morale(a.get_actor_ids())
	var scoreB = _get_morale(b.get_actor_ids())
	return scoreA < scoreB

# 是否合理的攻击目标
func _target_city_id_valid(vstateId:int, targetCityId:int)->bool:
	var targetCity = clCity.city(targetCityId)
	if 0 < clVState.get_alliance_month(vstateId, targetCity.get_vstate_id()):
		# 盟友城池
		return false
	# 后期，规避反复争夺
	if DataManager.year >= 220:
		var conqueredCityIds = DataManager.get_env_int_array("内政.MONTHLY.城池易主")
		if targetCityId in conqueredCityIds:
			return false
	return true

# 考虑到玩家体验，避免太过于频繁的战争
# @return true 表示应避免
func avoid_too_many_wars(fromCityId:int, targetCityId:int)->bool:
	var fromCity = clCity.city(fromCityId)
	var fromVstateId = fromCity.get_vstate_id()
	var targetCity = clCity.city(targetCityId)
	if DataManager.get_actor_controlNo(targetCity.get_lord_id()) < 0:
		# 是 AI 城，不管
		return false
	# 是玩家城，玩家被攻击体验逻辑介入
	# 统计历史攻击次数
	var allAttacked = 0
	var vstateAttacked = 0
	var cityAttacked = 0
	var cur = DataManager.year * 12 + DataManager.month
	var rows = DataManager.war_history.duplicate(true)
	rows.invert()
	for row in rows:
		if row.size() < 7:
			continue
		var year = int(row[0])
		var month = int(row[1])
		# 忽略旧记录
		var timing = year * 12 + month
		if timing <= cur - 3:
			continue
		#var vstateIndex = int(row[2])
		var historyFromCityId = int(row[3])
		var historyTargetCityId = int(row[4])
		var historyFromVstateId = int(row[5])
		#var targetVstateId = int(row[6])
		if historyTargetCityId != targetCity.ID:
			continue
		allAttacked += 1
		if historyFromCityId == fromCity.ID:
			cityAttacked += 1
		if historyFromVstateId == fromVstateId:
			vstateAttacked += 1
	# 统计当前城市的兵备情况
	var total = 0
	var current = 0
	var i = 0
	for actorId in targetCity.get_actor_ids():
		if i >= 10:
			break
		i += 1
		var actor = ActorHelper.actor(actorId)
		total += DataManager.get_actor_max_soldiers(actorId)
		current += actor.get_soldiers()
	# 根据兵备满员程度决定承受的攻击频次
	var timesSet = [
		[2 + randi() % 2, 3 + randi() % 2, 5 + randi() % 4],
		[1 + randi() % 2, 2 + randi() % 2, 3 + randi() % 2],
	]
	var fullRate = 0 if total <= 0 else int(current * 100 / total)
	var times = timesSet[0] if fullRate < 90 else timesSet[1]
	if cityAttacked >= times[0]:
		return true
	if vstateAttacked > times[1]:
		return true
	if allAttacked >= times[2]:
		return true
	return false
