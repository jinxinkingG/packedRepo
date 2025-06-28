extends "res://script/clEnvBase.gd"

#AI-发展
func _init() -> void:
	LoadControl.view_model_name = "内政-AI-步骤";
	FlowManager.bind_import_flow("AI_work",self,"AI_work");

#按键操控
func _input_key(delta: float):
	return

func AI_work():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var method_array = ["AI_Develop","AI_Develop",
						"AI_Search","AI_Search",
						"AI_BuyEquip","AI_BuyRice"];
	method_array.shuffle();
	for method in method_array:
		var b = call(method)
		DataManager.game_trace("  {0}AI内政开发{1}结束，命令书{2}".format([
			vs.get_lord_name(), method, DataManager.orderbook,
		]))
		if b or DataManager.orderbook <= 0:
			break
	FlowManager.add_flow("AI_next")
	return

func AI_Develop()->bool:
	LoadControl.set_view_model(100);
	var up_values_array = [5,10,10,10,10];#根据难度，得到AI发展基数
	var add_value = up_values_array[DataManager.diffculities];
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	#最低征兵人口
	var min_sodiers_con = 10000;
	
	var random_array = Array(PoolIntArray(DataManager.common_variable["内政.AI城池"]));
	random_array.shuffle();
	random_array.slice(0,min(7,random_array.size()))
	for id in random_array:
		var city = clCity.city(id)
		if city.get_vstate_id() != vstateId:
			continue;
		var cost_money = 0;
		#发展
		cost_money = add_value/3;
		if cost_money <= city.get_gold():
			city.add_gold(-cost_money)
		
			if(DataManager.month>=4 && DataManager.month<10):
				if city.get_land() < 500:
					city.add_city_property("土地", Global.get_random(1,3)*add_value*2)
			else:
				if city.get_eco() < 500:
					city.add_city_property("产业", Global.get_random(1,3)*add_value*2)
			
			#人口达到3W就不再发展人口
			if city.get_pop() < 30000:
				city.add_city_property("人口", Global.get_random(1,3)*add_value*100)
			
			var sodiers_need_pop = min_sodiers_con + Global.get_random(5,20)*100;
			
			if city.get_pop() <= sodiers_need_pop:
				city.set_property("人口", sodiers_need_pop)
			
			city.add_loyalty(add_value)
		#防灾
		var real_add_value = int(add_value+Global.get_random(0,9));
		cost_money = int(5+real_add_value/3);
		if cost_money <= city.get_gold():
			city.add_gold(-cost_money)
			city.add_city_property("防灾", real_add_value)
		
		for actorId in city.get_actor_ids():
			var actor = ActorHelper.actor(actorId)

			#征兵
			var max_sodiers = DataManager.get_actor_max_soldiers(actorId)
			if actor.get_soldiers() < max_sodiers:
				var add_sodiers = (Global.get_random(0,4)+add_value)*100;
				add_sodiers = max(0,min(city.get_pop()-min_sodiers_con, add_sodiers));
				real_add_value = min(add_sodiers, max_sodiers - actor.get_soldiers())
				cost_money = int(real_add_value/50);
				if cost_money <= city.get_gold():
					city.add_gold(-cost_money)
					actor.set_soldiers(actor.get_soldiers()+real_add_value)
					city.add_city_property("人口", -real_add_value)

			#治疗
			if actor.is_injured():
				cost_money = 50;
				if cost_money <= city.get_gold():
					city.add_gold(-cost_money)
					actor.recover_hp(add_value * 10)

			#赏赐，每个月仅一次
			if actor.get_loyalty() < 70:
				var awarded = DataManager.get_env_int_array("内政.MONTHLY.AI赏赐武将")
				if not actor.actorId in awarded:
					cost_money = 10;
					if cost_money <= city.get_gold():
						city.add_gold(-cost_money)
						actor.set_loyalty(actor.get_loyalty()+add_value+Global.get_random(0,4))
						awarded.append(actor.actorId)
						DataManager.set_env("内政.MONTHLY.AI赏赐武将", awarded)

	DataManager.orderbook-=3*random_array.size();
	return true;


func AI_Search()->bool:
	LoadControl.set_view_model(100);
	var up_values_array = [0,1,3,5,5];#根据难度，得到AI加忠基数
	var add_value = up_values_array[DataManager.diffculities];
	var vstateId = int(DataManager.vstates_sort[DataManager.vstate_no])
	var random_array = DataManager.get_env_int_array("内政.AI城池")
	random_array.shuffle()
	random_array.slice(0, min(7, random_array.size() - 1))
	for id in random_array:
		var city = clCity.city(id)
		if city.get_vstate_id() != vstateId:
			continue
		if city.get_gold() < 800:
			city.add_gold(Global.get_random(30, 70))
		if city.get_rice() < 800:
			city.add_rice(Global.get_random(50, 90))
		var unoffices = clCity.get_unoffice_actors(city.ID)
		if unoffices.empty():
			continue
		# 模拟执行，有 30% 的概率找到人
		if not Global.get_rate_result(30):
			continue
		# 这里不用全局 search_command
		# 避免污染玩家数据
		var cmd = SearchCommand.new(city.ID, city.get_lord_id())
		cmd.result = 5
		cmd.foundActorId = unoffices[0]
		# 仇恨和易招揽都在这里处理了
		cmd.decide_actor_result()
		if cmd.actorJoin <= 0:
			continue
		cmd.accept_actor()
		var msg = "AI找人：{0}加入{1}的{2}，忠{3}".format([
			cmd.found_actor().get_name(), cmd.vstate().get_lord_name(),
			cmd.city().get_name(), cmd.found_actor().get_loyalty(),
		])
		DataManager.game_trace(msg)
	DataManager.orderbook -= min(15, 3 * random_array.size())
	if DataManager.orderbook <= 0:
		return false
	return true

func AI_BuyRice()->bool:
	LoadControl.set_view_model(100);
	var up_values_array = [7,15,20,30,30];#根据难度，得到AI发展基数
	var add_value = up_values_array[DataManager.diffculities];
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var random_array = Array(PoolIntArray(DataManager.common_variable["内政.AI城池"]));
	random_array.shuffle();
	random_array.slice(0,min(3,random_array.size()))
	for id in random_array:
		var city = clCity.city(id)
		if city.get_vstate_id() != vstateId:
			continue;
		
		var need_rice = 0;
		for actorId in city.get_actor_ids():
			var actor = ActorHelper.actor(actorId)
			need_rice+=int(actor.get_soldiers()/1000.0*4*10);
		if need_rice > city.get_rice():
			#城内米不足时，买米
			var up = int((need_rice - city.get_rice())/2);
			city.add_rice(up)
			city.add_gold(-int(up*0.6))
		DataManager.orderbook-=3;
		if(DataManager.orderbook<=0):
			return false;
	return true;

#AI换装备
func AI_BuyEquip():
	LoadControl.set_view_model(100);
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var equipTypes = StaticManager.EQUIPMENT_TYPES.duplicate(true)
	var random_array = get_env_int_array("内政.AI城池")
	random_array.shuffle();
	random_array.slice(0,min(3,random_array.size()))
	for cityId in random_array:
		var city = clCity.city(cityId)
		if city.get_vstate_id() != vstateId:
			continue
		for actorId in city.get_actor_ids():
			if city.get_gold() < 3000:
				break
			var actor = ActorHelper.actor(actorId)
			equipTypes.shuffle()
			for type in equipTypes:
				var equip = actor.get_equip(type)
				if equip.level() == "S":
					# AI 不买 S 装
					continue
				#获得当前城可购买的装备
				var best = city.better_equip(equip, actorId)
				if best == null:
					continue
				if best.level_score() <= equip.level_score():
					continue
				if best.remaining() >= 0:
					best.dec_count(1)
				city.add_gold(-best.price())
				# 直接替换，不进装备库
				actor.set_equip(best)
				break
		DataManager.orderbook-=2;
		if(DataManager.orderbook<=0):
			return false;
	return true;
