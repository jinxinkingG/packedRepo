extends "res://script/clEnvBase.gd"

const VIEW_MODEL_KEY = "AI-内政-步骤"

func set_view_model(val:int)->void:
	set_env(VIEW_MODEL_KEY, val)
	return

func get_view_model()->int:
	return get_env_int(VIEW_MODEL_KEY)

func _init() -> void:
	FlowManager.bind_signal_method("deal_AI_10001", self)
	FlowManager.bind_signal_method("AI_start", self)
	FlowManager.bind_signal_method("AI_next", self)
	FlowManager.bind_signal_method("AI_active_skill", self)
	FlowManager.bind_signal_method("AI_actions", self)
	FlowManager.bind_signal_method("AI_end", self)
	FlowManager.clear_pre_history.append("AI_start")
	FlowManager.clear_pre_history.append("AI_next")
	FlowManager.clear_pre_history.append("AI_active_skill")
	FlowManager.clear_pre_history.append("AI_actions")
	FlowManager.clear_pre_history.append("AI_end")
	return

#AI开始
func AI_start():
	SoundManager.play_bgm("", true, true)
	SkillHelper.update_all_skill_buff("AI_start")
	# 这是为了让 AI_start 可重入
	# 避免月度初始逻辑重复执行
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var vs = clVState.vstate(vstateId)
	if vs.is_perished():
		FlowManager.add_flow("AI_end")
		return
	SceneManager.show_vstate_dialog(vs.get_dynasty_title_or_lord_name()+" 军 战略中")

	var last = DataManager.get_env_str("当前内政AI")
	var current = "{0}-{1}-{2}".format([vs.id, DataManager.year, DataManager.month])
	if last == current:
		# 在同一个 AI 内政过程中，AI_start 重入了
		# 目前是由战争引起的
		# 直接进 AI_Project 调度后再 AI_next
		FlowManager.add_flow("load_script|affiars/auto_events/AI/project.gd")
		FlowManager.add_flow("AI_Project")
		return

	# 打开技能缓存
	SkillHelper.reset_skills_list_cache(true)

	DataManager.set_env("当前内政AI", current)
	DataManager.set_env("当前内政开始时间", Time.get_ticks_usec())
	DataManager.game_trace("--AI战略开始:{0} @{1}-{2}--".format([
		vs.get_lord_name(), DataManager.year, DataManager.month,
	]))
	DataManager.check_exists_Actors_BUG()
	DataManager.game_trace("  {0}bug检查结束".format([
		vs.get_lord_name()
	]))
	_update_ai_work()
	# 遍历所属城市的出仕武将
	var actorIds = [];
	for city in clCity.all_cities([vstateId]):
		actorIds.append_array(city.get_actor_ids())
	DataManager.set_env("待执行武将", actorIds)
	FlowManager.add_flow("deal_AI_10001")
	return

func deal_AI_10001():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var actorIds = DataManager.get_env_int_array("待执行武将")
	while not actorIds.empty():
		var actorId = actorIds.pop_front()
		DataManager.set_env("待执行武将", actorIds)
		if SkillHelper.auto_trigger_skill(actorId, 10001, "deal_AI_10001"):
			return
	DataManager.game_trace("  {0}月度技能结束".format([
		vs.get_lord_name()
	]))
	#AI全部逻辑都执行完毕才调用
	OrderHistory.reset(vstateId)
	var cities = []
	for city in clCity.all_cities([vstateId]):
		cities.append(city.ID)
	# @since 1.544
	# 在正式开始 AI 内政之前，判断是否发动主动技
	DataManager.set_env("AI.主动技城市", cities)
	FlowManager.add_flow("AI_active_skill")
	return

#等待结束
func AI_next():
	LoadControl.end_script()
	set_view_model(-1)
	
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)

	DataManager.set_env("内政.AI城池", [])
	var cities = []
	for city in clCity.all_cities():
		if city.get_vstate_id() != -1 and city.get_actors_count() == 0:
			city.set_vstate_id(-1)
			continue
		if city.get_vstate_id() == vstateId:
			cities.append(city.ID)
	DataManager.set_env("内政.AI城池", cities)
	DataManager.game_trace("  {0}内政扫描城池结束".format([
		vs.get_lord_name()
	]))

	FlowManager.add_flow("AI_actions")
	return

func AI_actions():
	LoadControl.end_script()
	set_view_model(-1)
	var ai_work = DataManager.get_env_array("内政.AI战略")
	ai_work.shuffle()
	#命令书为0时，结束回合
	if DataManager.orderbook < 0:
		if not ai_work.empty() \
			and not "战争" in ai_work \
			and DataManager.get_env_str("AI.当前事件") == "战争":
			DataManager.orderbook += ai_work.size() * 20
		else:
			FlowManager.add_flow("AI_end")
			return

	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var result = ai_work.pop_front()
	DataManager.set_env("AI.当前事件", result)
	DataManager.game_trace("  {0}AI内政行动准备:{1}，命令书{2}".format([
		vs.get_lord_name(), result, DataManager.orderbook,
	]))
	
	match result:
		"发展":
			FlowManager.add_flow("load_script|affiars/auto_events/AI/develop.gd");
			FlowManager.add_flow("AI_work")
		"战争":
			if DataManager.orderbook < 10:
				FlowManager.add_flow("AI_next")
				return
			DataManager.orderbook -= 10
			FlowManager.add_flow("load_script|affiars/auto_events/AI/think_war.gd")
			FlowManager.add_flow("AI_War")
		"策略":
			DataManager.orderbook -= 10
			FlowManager.add_flow("load_script|affiars/auto_events/AI/policy.gd");
			FlowManager.add_flow("AI_Policy")
		_:
			_update_ai_work()
			FlowManager.add_flow("AI_next")
	return

func AI_end():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var vs = clVState.vstate(vstateId)
	var elapsed = Time.get_ticks_usec() - DataManager.get_env_float("当前内政开始时间")
	elapsed = int(elapsed / 1000.0)
	DataManager.game_trace("--AI战略结束:{0} @{1}-{2}，总耗时{3}毫秒--".format([
		vs.get_lord_name(), DataManager.year, DataManager.month, elapsed,
	]))

	# 关闭技能缓存
	SkillHelper.reset_skills_list_cache(false)

	DataManager.common_variable.erase("AI.当前事件");
	SceneManager.hide_all_tool();
	FlowManager.add_flow("turn_control_end");
	return

func _process(delta: float) -> void:
	if(AutoLoad.playerNo != FlowManager.controlNo):
		return;
	match get_view_model():
		1: # 等待 AI 主动技完成
			return
	return

func _update_ai_work():
	var ai_work = [
		"策略", "发展", "战争", "发展", "策略",
	]
	DataManager.set_env("内政.AI战略", ai_work)
	return

func AI_active_skill()->void:
	LoadControl.end_script()
	set_view_model(-1)
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var cities = DataManager.get_env_int_array("AI.主动技城市")
	while not cities.empty():
		var cityId = cities.pop_front()
		DataManager.set_env("AI.主动技当前城市", cityId)
		var city = clCity.city(cityId)
		for actorId in city.get_actor_ids():
			for skill in SkillHelper.get_actor_active_skills(actorId):
				for effect in SkillHelper.get_skill_effects(actorId, skill, ["主动"]):
					if effect.sceneId > 10000:
						continue
					var gd = Global.load_script(effect.path)
					gd.actorId = actorId
					if not gd.check_AI_perform():
						continue
					var ske = effect.create_ske_for(actorId)
					SkillHelper.save_skill_effectinfo(ske)
					LoadControl.load_script(effect.path)
					FlowManager.add_flow("effect_{0}_AI_start".format([effect.id]))
					set_view_model(1)
					return
		# 本城处理完了，更新轮询队列
		DataManager.set_env("AI.主动技城市", cities)
	DataManager.game_trace("  {0}AI主动技结束".format([
		vs.get_lord_name()
	]))
	# @since 1.641
	# 为 AI 君主和太守增加经验
	AI_leader_add_exp()
	DataManager.game_trace("  {0}AI太守成长结束".format([
		vs.get_lord_name()
	]))
	# 优先规划人员
	FlowManager.add_flow("load_script|affiars/auto_events/AI/project.gd")
	FlowManager.add_flow("AI_Project")
	return

func AI_leader_add_exp():
	# 每月去重
	var processed = DataManager.get_env_int_array("内政.MONTHLY.AI太守经验")
	for cityId in DataManager.get_env_int_array("内政.AI城池"):
		var city = clCity.city(cityId)
		var leaderId = city.get_leader_id()
		if leaderId < 0:
			continue
		if leaderId in processed:
			continue
		processed.append(leaderId)
		DataManager.set_env("内政.MONTHLY.AI太守经验", processed)
		var leader = ActorHelper.actor(leaderId)
		var maxLevel = 7
		var maxExp = 20000
		var addExp = 200
		if leader.get_loyalty() == 100:
			maxExp = 30000
			addExp = 300
		if leader.get_level() > maxLevel:
			continue
		if leader.get_exp() < maxExp:
			leader.add_exp(addExp)
	return
