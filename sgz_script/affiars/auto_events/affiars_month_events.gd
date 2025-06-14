extends Resource

const current_step_name = "内政-月事件-当前步骤"
const next_step_name = "内政-月事件-下个步骤"

# 灾害判断脚本
var disater_events

#读取当前步骤
func get_current_step() -> int:
	return DataManager.get_env_int(current_step_name)

#设置当前步骤
func set_current_step(step:int) -> void:
	DataManager.set_env(current_step_name, step)
	return

#读取下个步骤
func get_next_step() -> int:
	return DataManager.get_env_int(next_step_name)

#设置下个步骤
func set_next_step(step:int) -> void:
	DataManager.set_env(next_step_name, step)
	return

func _init() -> void:
	FlowManager.bind_import_flow("month_banished_actors_trigger", self)
	FlowManager.bind_import_flow("month_auto_events_begin", self)
	FlowManager.bind_import_flow("month_auto_events_end", self)
	FlowManager.bind_import_flow("harvest_finish", self)
	FlowManager.bind_import_flow("extra_harvest_gold", self)
	
	disater_events = Global.load_script(DataManager.mod_path+"sgz_script/affiars/auto_events/affiars_disater_events.gd")
	return

func start() -> void:
	DataManager.game_trace("--月事件开始--");
	DataManager.unset_env("每月赋税势力")
	SceneManager.hide_all_tool()
	set_next_step(-1)
	set_current_step(-1)
	if DataManager.check_env(["内政.MONTHLY.流放武将触发"]):
		return
	var exiled = []
	for actor in ActorHelper.all_exiled_actors():
		exiled.append(actor.actorId)
	DataManager.set_env("内政.MONTHLY.流放武将触发", exiled)
	FlowManager.add_flow("month_banished_actors_trigger")
	return

func end() -> void:
	DataManager.game_trace("--月事件结束--")
	SceneManager.hide_all_tool()
	set_next_step(-1)
	FlowManager.add_flow("vstate_init")
	return

func _process(delta: float) -> void:
	var nextStep:int = get_next_step()
	var currentStep:int = get_current_step()
	if nextStep < 0:
		return
	if nextStep == currentStep:
		disater_events._process(delta)
		return
	set_current_step(nextStep)
	month_auto_events_begin()
	return

# 流放武将的技能触发
func month_banished_actors_trigger():
	var exiled = DataManager.get_env_int_array("内政.MONTHLY.流放武将触发")
	while not exiled.empty():
		var actorId = exiled.pop_front()
		DataManager.set_env("内政.MONTHLY.流放武将触发", exiled)
		if SkillHelper.auto_trigger_skill(actorId, 10009, "month_banished_actors_trigger"):
			return
	set_current_step(-1)
	set_next_step(0)
	return

#月事件（收金、收米、灾害、暴动、统一）
func month_auto_events_begin():
	var current_step = get_current_step()
	var month = DataManager.month
	DataManager.game_trace("月事件步骤：" + str(current_step))
	
	match current_step:
		0:#@since 1.810，经济改革判断
			city_data_deal()

			var triggered = DataManager.get_env_int_array("每月赋税势力")
			var triggeredNames = []
			var monthLeft = 0
			for vs in clVState.all_vstates():
				if vs.is_perished():
					continue
				if vs.id in triggered:
					continue
				for buff in SkillRangeBuff.find_for_vstate("每月赋税", vs.id):
					monthLeft = max(monthLeft, int(buff.effectTagVal))
					if monthLeft <= 0:
						continue
					triggered.append(vs.id)
					triggeredNames.append(vs.get_lord_name())
					DataManager.set_env("每月赋税势力", triggered)
					break
			if triggered.size() > 0:
				var names = "、".join(triggeredNames)
				if triggeredNames.size() > 3:
					triggeredNames = triggeredNames.slice(0, 3)
					names = "、".join(triggeredNames)
					names += "等"
				var msg = "{0}势力币制改革\n剩余：{1}月\n持有金少量增加".format([
					names, monthLeft
				])
				SceneManager.play_affiars_animation("CollectMoney", "extra_harvest_gold", false, msg)
				return
			set_next_step(current_step+1)
		1:#收金收米判断
			var resurrectMonth = -1
			var resurrectSetting = DataManager.get_game_setting("自动复活")
			match resurrectSetting:
				"全年":
					resurrectMonth = month
				"无":
					pass
				_:
					resurrectMonth = int(resurrectSetting.replace("月", ""))

			DataManager.game_trace("== 每月武将轮询 BEGIN。")
			var resurrected = []
			var resurrectedScore = -1
			if month == resurrectMonth:
				#复活月份
				for actor in ActorHelper.all_dead_actors():
					actor.set_status_exiled(-1, -1)
					actor.set_hp(1)
					# 复活后不会在今年老死
					actor.set_life_limit(max(actor.get_life_limit(), DataManager.year + 1))
					actor.set_loyalty(50)
					if actor.get_exiled_city_id() < 0:
						actor.set_exile_city(clCity.random_city_id())
					resurrected.append(actor.actorId)
					var score = actor.get_power_score()
					if score > resurrectedScore:
						resurrectedScore = score
						resurrected.erase(actor.actorId)
						resurrected.insert(0, actor.actorId)
			DataManager.game_trace("== 每月武将轮询 END。")

			var anim = ""
			var msg = str(month) + "月 "
			match month:
				4:
					anim = "CollectMoney"
					msg += "收取税金\n持有金增加";
				10:
					anim = "CollectRice"
					msg += "稻米收成\n持有米增加"
				_:
					if resurrected.size() > 0:
						anim = "Town_Move"
						msg += "死者复生之季节"
			if anim != "":
				if resurrected.size() > 0:
					#事件动画一定显示在左侧
					DataManager.player_choose_city = 0
					var actor = ActorHelper.actor(resurrected[0])
					if resurrected.size() == 1:
						msg += "\n{0}已转生".format([
							actor.get_name(),
						])
					else:
						msg += "\n{0}等{1}人已转生".format([
							actor.get_name(), resurrected.size(),
						])
				SceneManager.play_affiars_animation(anim, "harvest_finish", false, msg)
				return
			set_next_step(current_step + 1)
		2:#灾害&&暴动
			disater_events.start()
		3:#统一
			for vs in clVState.all_vstates():
				if vs.is_perished():
					continue;
				var cityNum = DataManager.get_city_num_by_vstate(vs.id);
				if cityNum < clCity.all_city_ids().size():
					continue;
				#占领全部城池后，显示统一画面
				SceneManager.hide_all_tool()
				set_next_step(-1)
				SceneManager.over_animation.play_unify(vs.id);
				return;
			set_next_step(current_step+1);
		4:#流放武将检查是否跑路
			for actor in ActorHelper.all_exiled_actors():
				var cityId = actor.get_exiled_city_id()
				if cityId < 0:
					continue
				if actor.get_dislike_vstate_id() == clCity.city(cityId).get_vstate_id():
					clCity.find_new_home(actor.actorId)
			set_next_step(current_step+1);
		5:#结束
			end();
	return

func harvest_finish():
	SceneManager.cleanup_animations()
	set_current_step(1)
	set_next_step(1)
	FlowManager.add_flow("month_auto_events_end")
	return

# 每月赋税
func extra_harvest_gold():
	SceneManager.cleanup_animations()
	FlowManager.flows_history_list.clear()
	var triggered = DataManager.get_env_int_array("每月赋税势力")
	for city in clCity.all_cities():
		if not city.get_vstate_id() in triggered:
			continue
		var money = _get_collect_money(city)
		money = int(ceil(money * 0.1))
		city.add_gold(money)
	set_current_step(0)
	set_next_step(1)
	return

#动画播放结束，具体效果实施
func month_auto_events_end():
	FlowManager.flows_history_list.clear();
	var current_step:int = get_current_step();
	match current_step:
		1:#收金米
			if DataManager.month == 4:
				var triggered = DataManager.get_env_int_array("每月赋税势力")
				for city in clCity.all_cities():
					if city.get_vstate_id() in triggered:
						continue
					var money = _get_collect_money(city);
					city.add_gold(money)
			elif DataManager.month == 10:
				for city in clCity.all_cities():
					var rice = _get_collect_rice(city);
					city.add_rice(rice)
		2:#灾害
			pass
	set_next_step(current_step+1);
	FlowManager.set_current_control_playerNo(0);
	return

#获取4月可收取的金
func _get_collect_money(city)->int:
	var p_x = 50;
	var loy = city.get_loyalty()
	if loy >= 100:
		p_x = 100;
	elif loy >= 91:
		p_x = 90;
	elif loy >= 81:
		p_x = 80;
	elif loy >= 71:
		p_x = 70;
	elif loy >= 51:
		p_x = 60;
	var money = int((city.get_eco()/3+100)*city.get_pop()/100/80*p_x/100);
	return money;

#获取10月可收取的米
func _get_collect_rice(city)->int:
	var p_x = 50;
	var loy = city.get_loyalty()
	if loy >= 100:
		p_x = 100;
	elif loy >= 91:
		p_x = 90;
	elif loy >= 81:
		p_x = 80;
	elif loy >= 71:
		p_x = 70;
	elif loy >= 51:
		p_x = 60;
	var rice = int((city.get_land()/4+60)*city.get_pop()/100/60*p_x/100);
	return rice;


func city_data_deal()->void:
	var month = DataManager.month;
	for city in clCity.all_cities():
		#每过1个月，战乱度-2
		var chaos = city.add_chaos_score(-2)
		if(month == 1):
			chaos = city.add_chaos_score(-max(10, chaos*0.2))
		var point = int(100/max(1, chaos))*0.001 / 12 *(city.get_loyalty()/100.0)
		city.add_city_property("人口", int(city.get_pop()*point))
		#DataManager.game_trace("--循环武将开始--");
		#处理出仕武将
		var actorIds = city.get_actor_ids()
		var leaderId = -1
		if actorIds.size() > 0:
			leaderId = actorIds[0]
			#遍历所有已记录的城门
			for door_position in city.get_all_door_position():
				var actor = ActorHelper.actor(leaderId);
				var door_hp = city.get_door_hp(door_position.x,door_position.y);
				door_hp += actor.get_politics()
				city.set_door_hp(door_position.y, door_position.x, door_hp);
			# 触发太守技
			SkillHelper.auto_trigger_skill(leaderId, 10006, "")
			
		for actorId in actorIds:
			var actor = ActorHelper.actor(actorId)
			if actorId == city.get_lord_id():
				var vs = clVState.vstate(city.get_vstate_id())
				vs.set_capital_id(city.ID)
				actor.set_loyalty(100)
			else:
				actor.set_loyalty(min(99, actor.get_loyalty()))
			if not actor._has_attr("内政.离间"):
				if actor.get_loyalty() >=30 and actor.get_loyalty() < 70:
					actor.add_loyalty(3)
			actor._remove_attr("内政.离间")
			actor.set_status_officed(city.get_vstate_id())
			actor.set_dislike_vstate_id(-2)
			actor.set_exile_city(city.ID)
			actor.recover_hp(20)
		#DataManager.game_trace("--循环武将结束--");
		#DataManager.game_trace("--循环监狱开始--");
		#处理监狱武将
		for c_actorId in city.get_ceil_actor_ids():
			var c_actor = ActorHelper.actor(c_actorId)
			if c_actor.get_prev_vstate_id() != city.get_vstate_id():
				var decrease = min(5, 14 - int(c_actor.get_loyalty()/10))*2
				c_actor.add_loyalty(-decrease)
				c_actor.recover_hp(5)
				c_actor.set_soldiers(0)
			else:
				#原势力=当前势力的，过月时自动从监狱释放出来
				clCity.move_out(c_actorId);
				clCity.move_to(c_actorId,city.ID);
				c_actor.set_status_officed()
				if c_actor.get_loyalty() > 90:
					#防止原君主忠--
					c_actor.set_loyalty(90)
		#DataManager.game_trace("--循环监狱结束--");

	DataManager.set_env("大限检查", [])
	return
