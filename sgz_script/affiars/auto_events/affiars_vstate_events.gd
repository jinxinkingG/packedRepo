extends Resource

const current_step_name = "内政-势力事件-当前步骤";
const next_step_name = "内政-势力事件-下个步骤";


#读取当前步骤
func get_current_step():
	if(!current_step_name in DataManager.common_variable):
		return -1;
	return int(DataManager.common_variable[current_step_name]);

#设置当前步骤
func set_current_step(step:int):
	DataManager.common_variable[current_step_name]=int(step);
	
#读取下个步骤
func get_next_step():
	if(!next_step_name in DataManager.common_variable):
		return -1;
	return int(DataManager.common_variable[next_step_name]);

#设置下个步骤
func set_next_step(step:int):
	DataManager.common_variable[next_step_name]=int(step);


func _init() -> void:
	FlowManager.bind_signal_method("next_vstate_events",self,"next_vstate_events");
	pass

func start():
	_show_vstateinfo();
	set_next_step(0);
	set_current_step(-1);
	pass

func end():
	_show_vstateinfo();
	set_next_step(-1);
	FlowManager.add_flow("vstate_control_init")
	return

func _show_vstateinfo():
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no];
	var vs = clVState.vstate(vstateId)
	var lord_controlNo = DataManager.get_actor_controlNo(vs.get_lord_id());
	if(lord_controlNo<0):
		SceneManager.show_vstate_dialog(vs.get_dynasty_title_or_lord_name()+" 军 战略中");
	else:
		SceneManager.hide_all_tool();
	return

func _process(delta: float) -> void:
	if(AutoLoad.playerNo != FlowManager.controlNo):
		return;
	var next_step:int = get_next_step();
	var current_step:int = get_current_step();
	if(next_step<0):
		return;
	if(next_step == current_step):
		return;
	set_current_step(next_step);
	current_step = get_current_step();
	match current_step:
		0:#自动跟随
			# 随机出仕没有跟随武将
			if DataManager.get_game_setting("出仕地点") != "随机":
				for dic in DataManager.actor_follower:
					var parent = ActorHelper.actor(int(dic["父将"]))
					var child = ActorHelper.actor(int(dic["子将"]))
					var appearYear = child.get_appear_year(int(dic["登场年"]))
					#子将不是在野状态或到登场年份，跳过
					if not child.is_status_unofficed() or appearYear > DataManager.year:
						continue;
					#处理父将死亡的情况
					if parent.is_status_dead():
						var other_parentId = _get_other_parentId(parent.actorId)
						#没有可作为父将的人，直接在父将流放地下野
						if other_parentId < 0:
							child.set_status_exiled(-1, parent.get_exiled_city_id())
							continue;
						#有可作为新父将的人，作为新父将
						parent = ActorHelper.actor(other_parentId)
					#其他情况不考虑非出仕武将
					if not parent.is_status_officed():
						continue;
					var parentCityId = DataManager.get_actor_at_cityId(parent.actorId);
					var parentCity = clCity.city(parentCityId)
					if parentCity.get_vstate_id() != DataManager.vstates_sort[DataManager.vstate_no]:
						continue;
					#自动加入
					clCity.move_to(child.actorId, parentCity.ID);
					child.set_soldiers(0)
					child.set_status_officed()
					
					#若是玩家操控的武将，还需对话汇报
					var actor_playerNo:int = DataManager.get_actor_controlNo(child.actorId)
					if(actor_playerNo>=0):
						#用户处理
						_call_player_handle_follower(actor_playerNo,parent.actorId,child.actorId,parentCity.ID);
						return;
					var vs = clVState.vstate(parentCity.get_vstate_id())
					var lord_playerNo:int = DataManager.get_actor_controlNo(vs.get_lord_id());
					if(lord_playerNo>=0):
						#用户处理
						_call_player_handle_follower(lord_playerNo,parent.actorId,child.actorId,parentCity.ID)
						return;
					break;
			next_vstate_events()
		1:#势力事件结束
			end()
	return

#进入下一个事件
func next_vstate_events():
	DataManager.twinkle_citys.clear()
	set_next_step(get_current_step()+1);
	return

func _call_player_handle_follower(actor_playerNo:int,parentId:int,childId:int,cityId:int):
	DataManager.set_env("自动跟随.父", parentId)
	DataManager.set_env("自动跟随.子", childId)
	DataManager.set_env("自动跟随.城市", cityId)
	FlowManager.set_current_control_playerNo(actor_playerNo)
	FlowManager.add_flow("player_actor_follower")
	return

#获取父将下最早出仕子将作为新的父将
func _get_other_parentId(parentId:int)->int:
	var min_year = 10000;
	var new_parentId = -1;
	for dic in DataManager.actor_follower:
		var parent = ActorHelper.actor(int(dic["父将"]))
		if(parentId!=parent.actorId):
			continue;
		var child = ActorHelper.actor(int(dic["子将"]))
		var appearYear = child.get_appear_year(int(dic["登场年"]))
		if not child.is_status_officed() \
			and not child.is_status_exiled() \
			and not child.is_status_unofficed():
			continue;
		if appearYear < min_year:
			min_year = appearYear
			new_parentId = child.actorId
	return new_parentId;
