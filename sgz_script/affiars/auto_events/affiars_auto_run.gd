extends Node

const VIEW_MODEL_NAME = "内政-步骤-月初"

var player_control;
var AI_control;
var month_events;
var vstate_events;

func _init() -> void:
	FlowManager.clear_pre_history.clear()
	LoadControl.end_script()
	FlowManager.clear_bind_method()
	
	player_control = Global.load_script(DataManager.mod_path+"sgz_script/affiars/player_control.gd")
	month_events = Global.load_script(DataManager.mod_path+"sgz_script/affiars/auto_events/affiars_month_events.gd")
	vstate_events= Global.load_script(DataManager.mod_path+"sgz_script/affiars/auto_events/affiars_vstate_events.gd")
	AI_control = Global.load_script(DataManager.mod_path+"sgz_script/affiars/auto_events/affiars_AI_control.gd")

	FlowManager.bind_import_flow("month_init", self)
	FlowManager.bind_import_flow("month_init_vstates", self)
	FlowManager.bind_import_flow("month_event", self)
	FlowManager.bind_import_flow("vstate_init", self)
	FlowManager.bind_import_flow("vstate_event", self)
	FlowManager.bind_import_flow("vstate_control_init", self)
	FlowManager.bind_import_flow("back_from_war", self)
	FlowManager.bind_import_flow("back_from_war_trigger", self)
	FlowManager.bind_import_flow("check_actor_dead", self)
	FlowManager.bind_import_flow("turn_control_start", self)
	FlowManager.bind_import_flow("turn_control_end", self)
	FlowManager.bind_import_flow("vstate_end", self)
	FlowManager.bind_import_flow("month_end", self)

	# 星耀剧本逻辑
	FlowManager.bind_import_flow("stars_report", self)
	FlowManager.bind_import_flow("stars_report_vstates", self)
	FlowManager.bind_import_flow("stars_report_done", self)

	return

func get_view_model()->int:
	return DataManager.get_env_int(VIEW_MODEL_NAME, -1)

func set_view_model(vm:int)->void:
	DataManager.set_env(VIEW_MODEL_NAME, vm)
	return

func _process(delta: float) -> void:
	SoundManager.play_bgm();
	if FlowManager.has_task():
		return
	match get_view_model():
		100:
			Global.wait_for_confirmation("stars_report", VIEW_MODEL_NAME)
			return
		101:
			Global.wait_for_confirmation("stars_report_done", VIEW_MODEL_NAME)
			return
	player_control._process(delta)
	AI_control._process(delta)
	month_events._process(delta)
	vstate_events._process(delta)
	return

#月初始化
func month_init():
	DataManager.clear_common_variable(["内政.MONTHLY"])
	if DataManager.is_autoplay_mode() and Input.is_action_pressed("EMU_START"):
		DataManager.set_env("内政.中途加入.翻页", 0)
		FlowManager.add_flow("player_join")
		return
	# 加个战争日志清理
	DataManager.war_log.clear()
	# 内政技能回合初始化，减 CD
	SkillHelper.decrease_skill_cd(10000)
	SkillHelper.decrease_skill_variable(10000)
	SkillHelper.decrease_ban_actor_skill(10000)
	SkillHelper.decrease_actor_scene_skill(10000)
	
	# 更新持续性光环
	SkillHelper.update_continuous_buff()

	# 星耀剧本的特殊逻辑
	check_stars_month_init()
	return

func month_init_vstates()->void:
	#重置势力顺序
	SceneManager.current_scene().update_year_month()
	DataManager.vstate_no = 0
	DataManager.vstates_sort.clear()
	for vs in clVState.all_vstates():
		# 状态不是 "灭亡" 则强制修正为 "正常"
		if not vs.is_perished():
			vs.set_alive()
		if not vs.is_alive():
			continue
		DataManager.vstates_sort.append(vs.id)
	#打乱势力顺序
	DataManager.vstates_sort.shuffle()
	#空城一定在最后
	DataManager.vstates_sort.append(-1)
	# 判断是否有设定的优先势力
	var prioritized = DataManager.get_env_int_array("优先行动势力")
	if prioritized.size() == 2:
		var prioritizedVstateId = prioritized[0]
		var extraOrderbooks = prioritized[1]
		DataManager.vstates_sort.erase(prioritizedVstateId)
		DataManager.vstates_sort.insert(0, prioritizedVstateId)
		DataManager.set_env("额外命令书", extraOrderbooks)
	DataManager.unset_env("优先行动势力")
	#先改步骤再切换玩家
	FlowManager.add_flow("month_event")
	FlowManager.set_current_control_playerNo(0)
	return

#月事件
func month_event():
	month_events.start();

#势力初始化
func vstate_init():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	#初始化本势力的所有控制者
	DataManager.control_sort_no = 0;
	DataManager.control_sort.clear();
	if(vstateId!=-1):
		var vs = clVState.vstate(vstateId)
		if vs.is_perished():
			FlowManager.add_flow("vstate_end");
			return;
		#存在的势力，默认添加一个电脑君主
		DataManager.control_sort.append(-1);
		for playerNo in DataManager.players.size():
			var player:Player = DataManager.players[playerNo];
			if(player.actorId<0):
				continue;
			player.affiars_turn_end = false;
			if player.actorId == vs.get_lord_id():
				#如果玩家是君主，替换掉电脑君主的控制位
				DataManager.control_sort[0]=playerNo;
			else:
				#非君主时，只考虑单将
				if(player.belong_To_vstateId()==vstateId):
					DataManager.control_sort.append(playerNo);
	else:
		#在野时直接遍历玩家列表
		for playerNo in DataManager.players.size():
			var player:Player = DataManager.players[playerNo];
			if(player.actorId<0):
				continue;
			player.affiars_turn_end = false;
			#在野势力只考虑单将
			if(player.belong_To_vstateId()==vstateId):
				DataManager.control_sort.append(playerNo);

	DataManager.game_trace("VSTATE_INIT")
	if DataManager.control_sort.empty():
		FlowManager.add_flow("vstate_end")
		return
	FlowManager.add_flow("vstate_event")
	return
	
#势力事件
func vstate_event():
	vstate_events.start()
	return

#初始化控制器的命令书（每个月只调用一次）
func vstate_control_init():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	DataManager.unset_env("初始化")
	var vstate_controlNo = DataManager.get_current_control_sort()
	#初始化命令书在此进行
	DataManager.orderbook = 0
	if vstateId != -1:
		var cityNum = DataManager.get_city_num_by_vstate(vstateId, true);
		if cityNum == 0:
			FlowManager.add_flow("turn_control_end");
			return
		var city_order_books = StaticManager.get_orderbook_setting()
		if cityNum >= city_order_books.size():
			cityNum = city_order_books.size() - 1
		DataManager.orderbook = city_order_books[cityNum]
		if vstate_controlNo < 0:
			var difficuts = StaticManager.AI_ORDERBOOK_COUNT;#不同难度下，AI命令书的倍数不同
			var orderbook = city_order_books[cityNum] * difficuts[DataManager.diffculities]
			DataManager.orderbook = min(30, orderbook)
		else:
			var player:Player = DataManager.players[vstate_controlNo]
			var level = player.get_power_level()
			match level:
				Player.ActorLevelEnum.Normal:
					DataManager.orderbook = 2
				Player.ActorLevelEnum.Satrap:
					DataManager.orderbook = 3
	else:
		#在野势力，直接1枚命令
		DataManager.orderbook = 1
	var extraOrderbook = DataManager.get_env_int("额外命令书")
	if extraOrderbook > 0:
		DataManager.orderbook += extraOrderbook
		DataManager.unset_env("额外命令书")
	var skipping = DataManager.get_env_dict("内政.跳过内政")
	if str(vstateId) in skipping:
		var timing = skipping[str(vstateId)]
		if timing == DataManager.year * 12 + DataManager.month:
			DataManager.orderbook = 0
		skipping.erase(str(vstateId))
	DataManager.set_env("内政.跳过内政", skipping)
	DataManager.game_trace("TURN_CTRL_INIT")
	FlowManager.add_flow("check_actor_dead");
	return

#从战争回来
func back_from_war()->void:
	SoundManager.play_bgm()
	LoadControl.end_script()

	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	# 暂行方案，允许胜利方发动战后技能
	var wf = DataManager.get_current_war_fight()
	if wf.result == 2:
		# 攻方胜利，占城武将发动技能
		DataManager.set_env("内政.战后触发", wf.target_city().get_actor_ids())
		FlowManager.add_flow("back_from_war_trigger");
		return
	FlowManager.add_flow("check_actor_dead")
	return

#战后技能触发
#需要正确设定变量 "内政.战后触发" 数组
func back_from_war_trigger()->void:
	var actorIds = DataManager.get_env_int_array("内政.战后触发")
	while not actorIds.empty():
		var actorId = actorIds.pop_front()
		DataManager.set_env("内政.战后触发", actorIds)
		if SkillHelper.auto_trigger_skill(actorId, 10013, "back_from_war_trigger"):
			return
	FlowManager.add_flow("check_actor_dead")
	return

#检查君主是否死亡
func check_actor_dead():
	SoundManager.play_bgm()
	LoadControl.end_script()
	
	FlowManager.add_flow("load_script|affiars/auto_events/affiars_lord_dead.gd")
	FlowManager.add_flow("check_actor_dead_start")
	return

#回合控制开始
func turn_control_start():
	# 全量修复数据，其中包括了武将大限的判断
	DataManager.fix_data(true)
	DataManager.game_trace("FIX_DATA")
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	# 修复可能的错误数据
	if DataManager.control_sort.empty():
		FlowManager.add_flow("vstate_init")
		return
	var vstate_controlNo = DataManager.get_current_control_sort()
	if vstate_controlNo >= 0:
		var player:Player = DataManager.players[vstate_controlNo]
		#判断玩家是否结束本月行动
		if player.affiars_turn_end:
			FlowManager.add_flow("turn_control_end")
			return;
		var actor = ActorHelper.actor(player.actorId)
		#如果武将已经死了，直接结束
		if actor.is_status_dead():
			FlowManager.add_flow("turn_control_end")
			return;
		#如果武将不属于该势力了，直接结束
		if player.belong_To_vstateId() != vstateId:
			FlowManager.add_flow("turn_control_end")
			return
		#默认设置流程控制者：0
		FlowManager.set_current_control_playerNo(0)
	DataManager.game_trace("PLAYER_STATUS_CHECK")
	#AI回合
	if vstate_controlNo == -1:
		FlowManager.add_flow("AI_start");
	else:
		#玩家回合
		FlowManager.set_current_control_playerNo(vstate_controlNo);
		var initialized = DataManager.get_env_int("初始化")
		if initialized < 0:
			DataManager.set_env("初始化", 1)
			FlowManager.add_flow("player_before_start")
		else:
			FlowManager.add_flow("player_ready")
	return

#回合控制结束
func turn_control_end():
	LoadControl.end_script();
	if AutoLoad.get_local_id() != 1:
		return

	var vstate_controlNo = DataManager.get_current_control_sort()
	if vstate_controlNo >= 0 and vstate_controlNo < DataManager.players.size():
		var player:Player = DataManager.players[vstate_controlNo]
		player.affiars_turn_end = true
	DataManager.control_sort_no += 1
	DataManager.game_trace("TURN_CTRL_END")

	#如果当前势力内部的子控制者全部完成，本势力结束
	if DataManager.control_sort_no >= DataManager.control_sort.size():
		FlowManager.add_flow("vstate_end")
		return
	#否则进入下一个控制器判断
	FlowManager.add_flow("vstate_control_init")
	return

#势力结束
func vstate_end():
	DataManager.vstate_no+=1;
	if(DataManager.vstate_no>=DataManager.vstates_sort.size()):
		FlowManager.add_flow("month_end");
		return;
	FlowManager.add_flow("vstate_init")
	return

func month_end():
	DataManager.month+=1;
	if(DataManager.month>12):
		DataManager.month=1;
		DataManager.year+=1;
	#同盟月份递减
	for key in DataManager.vstates_alliance:
		var month:int = int(DataManager.vstates_alliance[key]);
		if(month>0):
			DataManager.vstates_alliance[key] = month-1;
	FlowManager.add_flow("month_init");
	DataManager.game_trace("MONTH_END")
	return

# 星耀剧本的特殊逻辑
func check_stars_month_init()->void:
	if not DataManager.is_stars_drama():
		FlowManager.add_flow("stars_report_done")
		return

	var candidates = ActorHelper.all_disabled_actors([StaticManager.ACTOR_ID_DIY, StaticManager.ACTOR_ID_LIUBIAN])
	if candidates.empty():
		# 所有人出仕完毕
		FlowManager.add_flow("stars_report_done")
		return

	var original = []
	for actor in candidates:
		if Global.intval(actor._get_attr("星耀")) > 0:
			continue
		original.append(actor)

	if not original.empty():
		# 历史武将未随机出仕完毕，他们优先
		# 复活和下野的再等等
		candidates = original

	# 武将乱序
	candidates.shuffle()
	# 所有首都和空城出仕一个禁用武将
	var cities = clCity.all_cities()
	# 城市乱序处理，避免总是按顺序扬旗
	cities.shuffle()
	# 每月最多出现三个新势力
	var createLimit = 3
	var createdVstateIds = DataManager.get_env_int_array("内政.MONTHLY.星耀势力")
	var joinedActors = DataManager.get_env_dict("内政.MONTHLY.星耀武将")
	for city in cities:
		var vstateId = city.get_vstate_id()
		# 空城检查数量限制
		if vstateId == -1 and createdVstateIds.size() >= createLimit:
			continue
		if vstateId >= 0:
			# 不是空城，要求是首都
			if clCity.get_capital_city(vstateId).ID != city.ID:
				continue
		var created = false
		var actor = candidates.pop_front()
		if actor == null:
			break
		# 加入城市
		clCity.move_out(actor.actorId)
		actor.set_hp(actor.get_max_hp())
		# 如果是空城，有概率创建一个新势力
		if vstateId == -1:
			vstateId = clVState.create_new_vstate(actor.actorId)
			created = true
			city.set_vstate_id(vstateId)
			city.set_property("金", 500)
			city.set_property("米", 800)
			city.add_actor(actor.actorId)
			actor.set_soldiers(1000)
			actor.set_loyalty(100)
			createdVstateIds.append(vstateId)
			DataManager.set_env("内政.MONTHLY.星耀势力", createdVstateIds)
		else:
			var lordId = city.get_lord_id()
			# 玩家可以关闭星耀出仕
			if DataManager.get_actor_controlNo(lordId) >= 0:
				if DataManager.get_game_setting("出仕时间") == "关闭":
					continue
			# 用搜索命令来模拟
			var cmd = SearchCommand.new(city.ID, lordId)
			cmd.force_actor_join(actor.actorId)
			# 初始兵力 500
			actor.set_soldiers(500)
			# 忠诚度固定为 70
			actor.set_loyalty(70)
			var key = str(city.ID)
			if not key in joinedActors:
				joinedActors[key] = []
			joinedActors[key].append(actor.actorId)
			DataManager.set_env("内政.MONTHLY.星耀武将", joinedActors)
	FlowManager.add_flow("stars_report")
	return

# 星耀武将汇报
func stars_report()->void:
	if not DataManager.is_stars_drama():
		FlowManager.add_flow("stars_report_done")
		return
	var reported = DataManager.get_env_int_array("内政.MONTHLY.星耀汇报")
	var attended = DataManager.get_env_dict("内政.MONTHLY.星耀武将")
	for p in DataManager.players:
		if p.actorId < 0 or p.actorId in reported:
			continue
		var cityId = DataManager.get_office_city_by_actor(p.actorId)
		if cityId < 0:
			continue
		if not str(cityId) in attended:
			continue
		var city = clCity.city(cityId)
		var vstateId = city.get_vstate_id()
		var names = []
		for actorId in attended[str(cityId)]:
			var actor = ActorHelper.actor(actorId)
			names.append(actor.get_name())
		if names.empty():
			continue
		if names.size() > 3:
			names[2] += "等{0}人".format([names.size()])
			names = names.slice(0, 2)
		var msg = "可喜可贺！\n{0}加入我军".format(["、".join(names)])
		DataManager.twinkle_citys = [city.ID]
		SceneManager.show_confirm_dialog(msg, p.actorId, 1)
		reported.append(p.actorId)
		DataManager.set_env("内政.MONTHLY.星耀汇报", reported)
		set_view_model(100)
		return
	FlowManager.add_flow("stars_report_vstates")
	return

# 星耀势力汇报
func stars_report_vstates()->void:
	if not DataManager.is_stars_drama():
		FlowManager.add_flow("stars_report_done")
		return
	# 势力汇报只有一个玩家汇报就 OK 了
	var reporter = -1
	for p in DataManager.players:
		if p.actorId < 0:
			continue
		reporter = p.actorId
		break
	if reporter < 0:
		FlowManager.add_flow("stars_report_done")
		return
	var names = []
	var cityIds = []
	for created in DataManager.get_env_int_array("内政.MONTHLY.星耀势力"):
		var vs = clVState.vstate(created)
		if not vs.is_alive():
			continue
		var capital = clCity.get_capital_city(vs.id)
		if capital == null:
			continue
		names.append(capital.get_full_name() + vs.get_lord_name())
		cityIds.append(capital.ID)
	if names.empty():
		FlowManager.add_flow("stars_report_done")
		return
	if names.size() > 3:
		names[2] += "等{0}人".format([names.size()])
		names = names.slice(0, 2)
	var msg = "据报：\n{0}扬旗称王\n正在招兵买马".format(["、".join(names)])
	SceneManager.show_confirm_dialog(msg, reporter, 2)
	DataManager.twinkle_citys = cityIds
	set_view_model(101)
	return

func stars_report_done()->void:
	DataManager.twinkle_citys = []
	FlowManager.add_flow("month_init_vstates")
	return

