extends "affairs_base.gd"

#治疗价格（默认50）
func get_cost(actorId:int):
	return 50;

#医馆
func _init() -> void:
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_signal_method("hospital_check_injury", self)
	FlowManager.bind_signal_method("hospital_choose_actor", self)
	FlowManager.bind_signal_method("hospital_money", self)
	FlowManager.bind_signal_method("hospital_use_orderbook_start", self)
	FlowManager.bind_signal_method("hospital_use_orderbook_end", self)
	FlowManager.bind_signal_method("hospital_actor_confirm_1", self)
	FlowManager.bind_signal_method("hospital_animation", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var view_model = LoadControl.get_view_model();
	match view_model:
		432:#选人
			if not wait_for_choose_actor("enter_fair_menu"):
				return
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor();
			DataManager.common_variable["花费"] = get_cost(DataManager.player_choose_actor);
			FlowManager.add_flow("hospital_money");
		433:#确认金额
			wait_for_confirmation("hospital_use_orderbook_start", "enter_fair_menu")
		434:#命令书
			wait_for_yesno("hospital_use_orderbook_end", "enter_fair_menu")
		436:#确认对话1
			wait_for_confirmation("hospital_animation")
	return

#判断存在受伤者
func hospital_check_injury():
	LoadControl.set_view_model(431);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	if(AutoLoad.playerNo != FlowManager.controlNo):
		return;
	var city = clCity.city(DataManager.player_choose_city)
	var injured = [];
	for actorId in city.get_actor_ids():
		var actor = ActorHelper.actor(actorId)
		if not actor.is_injured():
			continue
		injured.append(actorId)
	if injured.empty():
		LoadControl._affiars_error("此城内并无受伤武将\n请下达其他命令")
		return
	DataManager.common_variable["列表值"] = injured
	FlowManager.add_flow("hospital_choose_actor")
	return

#选人
func hospital_choose_actor():
	LoadControl.set_view_model(432);
	var injurys = PoolIntArray(DataManager.common_variable["列表值"]);
	SceneManager.show_actorlist_army(injurys,false,"让何人去医馆？",false);

#提示金额
func hospital_money():
	LoadControl.set_view_model(433);
	var cost = int(DataManager.common_variable["花费"]);
	SceneManager.show_confirm_dialog("需{0}两金".format([cost]));
	SceneManager.show_cityInfo(true);

#命令书
func hospital_use_orderbook_start():
	var cost = int(DataManager.common_variable["花费"]);
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_gold() < cost:
		LoadControl._affiars_error("现如今城内并无足够金钱\n请下达其他命令");
		return

	LoadControl.set_view_model(434);
	#命令书确认
	SceneManager.show_yn_dialog("消耗1枚命令书可否");
	SceneManager.show_cityInfo(true);

#命令书消耗动画
func hospital_use_orderbook_end():
	LoadControl.set_view_model(435);
	SceneManager.dialog_use_orderbook_animation("hospital_actor_confirm_1");

#伤者确认
func hospital_actor_confirm_1():
	LoadControl.set_view_model(436);
	SceneManager.show_confirm_dialog("既如此\n就暂时疗养一番",DataManager.player_choose_actor);
	SceneManager.show_cityInfo(true);

#动画
func hospital_animation():
	LoadControl.set_view_model(437);
	var cost = int(DataManager.common_variable["花费"]);
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var city = clCity.city(DataManager.player_choose_city)
	city.add_gold(-cost)
	var recover = Global.get_random(35, 45)
	recover = actor.recover_hp(recover)
	
	var msg = "{0}体力恢复{1}点\n现为{2}".format([
		actor.get_name(), recover, int(actor.get_hp()),
	])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg);
	SceneManager.play_affiars_animation("Fair_Hospital", "confirm_to_ready");
	return
