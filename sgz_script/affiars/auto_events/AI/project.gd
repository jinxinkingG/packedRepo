extends Resource

var ias

#AI-人员规划
func _init() -> void:
	ias = Global.load_script(DataManager.mod_path+"sgz_script/affiars/auto_events/AI/IAffiarsStrategy.gd")

	LoadControl.view_model_name = "内政-AI-步骤";
	FlowManager.bind_signal_method("AI_Project",self,"AI_Project");
	
	FlowManager.clear_pre_history.append("AI_Project");
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	return

func AI_Project():
	LoadControl.set_view_model(100)
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var lord = ActorHelper.actor(vs.get_lord_id())

	DataManager.grouped_trace_dic.clear()
	for city in clCity.all_cities([vstateId]):
		var isFrontier = city.get_connected_city_ids([], [vstateId]).size() > 0
		#为君主找主城
		var way:Array = ias.search_way(vstateId, city.ID, vs.get_target_city_id());
		if(way.empty()):
			continue;
		way.invert();
		way.insert(0, vs.get_target_city_id());
		var lordCityId = DataManager.get_actor_at_cityId(lord.actorId);
		for wayCityId in way:
			var wayCity = clCity.city(wayCityId)
			if wayCity.get_vstate_id() != vstateId:
				continue
			if lordCityId == wayCityId:
				break
			if wayCity.get_actor_ids().empty():
				continue
			#君主和新主城太守交换城池
			var oldSatrapId = wayCity.get_actor_ids()[0]
			clCity.move_to(lord.actorId, wayCity.ID)
			clCity.move_to(oldSatrapId, lordCityId)
			vs.set_capital_id(wayCity.ID)
			break;
		#1.任命太守:优先君主，再继承人，之后是德和自己最相近的
		var new_satrap:int = -1;
		var max_score = -20000;
		var candidates = []
		for id in vs.get_inheritage_candidates():
			candidates.append(int(id))
		candidates.invert();#继承人逆序排列
		candidates.append(lord.actorId);
		
		var actorIds = city.get_actor_ids()
		if actorIds.empty():
			FlowManager.add_flow("AI_next")
			return
		DataManager.grouped_trace("")
		for actorId in actorIds:
			var actor = ActorHelper.actor(actorId)
			# 如果是前线城市，遍历顺便征兵
			if isFrontier:
				var max_sodiers = DataManager.get_actor_max_soldiers(actorId);
				DataManager.grouped_trace("士兵上限")
				actor.set_soldiers(min(max_sodiers, actor.get_soldiers()+Global.get_random(5,9)*100))
			if actor.get_loyalty() < 70:
				continue
			# 根据统决定太守
			var score = actor.get_leadership() - 1000
			#如果是继承人，评分为正数
			if actorId in candidates:
				#检索继承人
				var index = candidates.rfind(actorId) + 1
				score = index*1000;
			if score > max_score:
				#替换最高分
				max_score = score
				new_satrap = actorId
		if actorIds.size() > 1 and new_satrap >= 0:
			clCity.move_out(new_satrap)
			city.insert_actor(0,new_satrap)
		var adjusted = city.get_actor_ids()
		if lord.actorId in adjusted and lord.actorId != adjusted[0]:
			pass
		DataManager.grouped_trace("选太守")

		#2.招募监狱人员
		var satrap = ActorHelper.actor(city.get_actor_ids()[0])
		for ceilActorId in city.get_ceil_actor_ids():
			var ceilActor = ActorHelper.actor(ceilActorId)
			# 如果是原势力武将，直接同意，且忠至少90
			var rate = 100
			var loyalty = min(90, ceilActor.get_loyalty())
			if ceilActor.get_prev_vstate_id() != vstateId:
				#非原势力，进入招揽成功率计算
				loyalty = max(0, 79 - ceilActor.get_loyalty())
				rate = PolicyCommand.get_canvass_rate(
					satrap.actorId,
					ceilActor.actorId,
					satrap.get_politics(),
					satrap.get_moral(),
					satrap.get_level()
				)
			if Global.get_rate_result(rate):
				clCity.move_out(ceilActorId)
				clCity.move_to(ceilActorId, city.ID)
				ceilActor.set_status_officed()
				ceilActor.set_loyalty(loyalty)
		DataManager.grouped_trace("俘虏招募")

		#防守当前城计算：计算当前城周围敌城的最大人数
		var max_actors_num = 0
		var enemyCityIdsAround = city.get_connected_city_ids([], [-1, vstateId])
		for enemyCityId in enemyCityIdsAround:
			var enemyCity = clCity.city(enemyCityId)
			var total_score=0;
			var actors_num = enemyCity.get_actors_count()
			if actors_num > max_actors_num:
				max_actors_num = actors_num
		max_actors_num = min(10, max_actors_num)
		DataManager.grouped_trace("人数计算")

		#简单难度下，最少3人守城
		if(DataManager.diffculities==0):
			max_actors_num = max(3, max_actors_num);
		
		#普通难度下，最少2人守城
		if(DataManager.diffculities==1):
			max_actors_num = max(2, max_actors_num);
		
		#其他难度，至少1人守城
		max_actors_num = max(1, max_actors_num);
		
		#相邻敌城数量为0时，只需一个人守
		if enemyCityIdsAround.empty():
			max_actors_num = 1

		if city.get_actors_count() > max_actors_num:
			var cityActorIds = city.get_actor_ids()
			var waitActorIds = []
			var maxWait = cityActorIds.size() - max_actors_num
			# 遍历武将，加入可调动列表，跳过太守
			for i in range(1, cityActorIds.size()):
				if waitActorIds.size() >= maxWait:
					break
				waitActorIds.append(cityActorIds[i])
			for nearCityId in _get_all_link_city(city.ID, city.get_vstate_id()):
				var nearCity = clCity.city(nearCityId)
				var enemyCityIds = nearCity.get_connected_city_ids([], [-1, vstateId])
				if enemyCityIds.empty():
					continue
				var total_score = 0;
				if nearCity.get_actors_count() >= 10:
					# 满10人不需要继续添加人员
					continue;
				for actorId in nearCity.get_actor_ids():
					var actor = ActorHelper.actor(actorId)
					var actor_score = (actor.get_power()+actor.get_wisdom()+actor.get_leadership())/3 * max(1,actor.get_soldiers())/10;
					total_score+=actor_score;
				var max_enemy_score = 0;
				for enemyCityId in enemyCityIds:
					var enemyCity = clCity.city(enemyCityId)
					var total_enemy_score = 0;
					for actorId in enemyCity.get_actor_ids():
						var actor = ActorHelper.actor(actorId)
						var actor_score = (actor.get_power()+actor.get_wisdom()+actor.get_leadership())/3 * max(1,actor.get_soldiers())/10;
						total_enemy_score+=actor_score;
					if(total_enemy_score>max_enemy_score):
						max_enemy_score = total_enemy_score;
				# 持续补充武将，直到分数足够，或可用武将为空，或满10人
				while max_enemy_score > total_score and nearCity.get_actors_count() < 10 and not waitActorIds.empty():
					var actorId = waitActorIds.pop_front()
					clCity.move_to(actorId, nearCity.ID)
					if city.get_actors_count() == 0:
						city.change_vstate(-1)
					var actor = ActorHelper.actor(actorId)
					var actor_score = (actor.get_power()+actor.get_wisdom()+actor.get_leadership())/3 * max(1,actor.get_soldiers())/10;
					total_score+=actor_score;
		DataManager.grouped_trace("武将调度")
	# 取消下面这行的注释，可以看到分组统计耗时
	DataManager.grouped_trace_output()
	DataManager.game_trace("  {0}AI内政任命调动结束，命令书{1}".format([
		vs.get_lord_name(), DataManager.orderbook,
	]))
	FlowManager.add_flow("AI_next")
	return

#无视距离获取相邻的己方城
func _get_all_link_city(fromCityId:int, vstateId:int)->PoolIntArray:
	var found = []
	var toCheck = [fromCityId]
	var checked = []
	
	while not toCheck.empty():
		var cityId = toCheck.pop_front()
		checked.append(cityId)
		var city = clCity.city(cityId)
		for nearCityId in city.get_connected_city_ids([vstateId]):
			if checked.has(nearCityId):
				continue
			found.append(nearCityId)
			toCheck.append(nearCityId)
	return found
