extends "affairs_base.gd"


var prev_view_model_name = ""

func _init()->void:
	prev_view_model_name = LoadControl.view_model_name
	LoadControl.view_model_name = "内政-玩家-步骤";
	FlowManager.bind_import_flow("wh_equip_init", self, "wh_equip_init");
	FlowManager.bind_import_flow("wh_equip_menu", self, "wh_equip_menu");
	FlowManager.bind_import_flow("wh_equip_deal_menu", self, "wh_equip_deal_menu");
	FlowManager.bind_import_flow("wh_equip_start", self, "wh_equip_start");
	FlowManager.bind_import_flow("wh_equip_animation", self, "wh_equip_animation");
	FlowManager.bind_import_flow("wh_equip_confirm_gave", self, "wh_equip_confirm_gave");

	FlowManager.bind_import_flow("wh_equip_before_drop", self)
	FlowManager.bind_import_flow("wh_equip_before_drop_all", self)
	FlowManager.bind_import_flow("wh_equip_drop", self)
	FlowManager.bind_import_flow("equip_finish", self)
	FlowManager.bind_import_flow("go_study", self)
	return

func _input_key(delta:float):
	var top = SceneManager.lsc_menu_top
	var bottom = SceneManager.lsc_menu
	match LoadControl.get_view_model():
		329:
			wait_for_confirmation("wh_equip_menu", "equip_finish")
		330:
			var list = DataManager.get_env_array("列表值")
			if list.empty():
				LoadControl.set_view_model(-1)
				LoadControl._affiars_error("现如今并无多余的装备库存")
				return
			if Global.wait_for_choose_equip("", "equip_finish", "warehouse"):
				var selected = DataManager.get_env_dict("目标项")
				DataManager.set_env("选定装备", selected)
				DataManager.set_env("CURSOR", top.lsc.cursor_index)
				FlowManager.add_flow("wh_equip_deal_menu")
		331:
			DataManager.set_env("批量丢弃", 0)
			wait_for_options(["wh_equip_start", "wh_equip_before_drop", "wh_equip_before_drop_all"], "wh_equip_menu")
		332: # 选择给予哪个武将
			var item = DataManager.get_env_dict("选定装备")
			var equip = clEquip.equip(int(item["ID"]), item["类型"])
			if not wait_for_choose_actor("wh_equip_menu"):
				return
			var msg = DataManager.get_env_str("装备提示")
			if msg != "" and SceneManager.actorlist.rtlMessage.text != msg:
				SceneManager.actorlist.speak(msg)
			var actorId = SceneManager.actorlist.get_select_actor();
			if actorId == -1:
				var actorIds = SceneManager.actorlist.get_picked_actors()
				if not actorIds.empty():
					DataManager.set_env("装备武将", actorIds)
					FlowManager.add_flow("wh_equip_confirm_gave")
				else:
					FlowManager.add_flow("wh_equip_menu")
				return
			if not equip.actor_can_use(actorId):
				SceneManager.actorlist.speak("{0}尚无法运用{1}".format([
					ActorHelper.actor(actorId).get_name(), equip.name(),
				]))
				return
			if int(item["装备库数量"]) == 1:
				DataManager.set_env("装备武将", [actorId])
				FlowManager.add_flow("wh_equip_confirm_gave")
				return
			SceneManager.actorlist.set_actor_picked(actorId, int(item["装备库数量"]))
		335:
			wait_for_confirmation("wh_equip_menu")
		336:
			wait_for_yesno("go_study", "wh_equip_menu")
		338:
			wait_for_confirmation("wh_equip_menu")
		339:
			wait_for_confirmation("wh_equip_menu")
		341:
			wait_for_yesno("wh_equip_animation", "wh_equip_menu")
	return

func wh_equip_init():
	var vstateId = get_current_vstate_id()
	SceneManager.hide_all_tool()
	match DataManager.get_current_scene_id():
		10000:
			SceneManager.current_scene().cursor.hide();
			DataManager.twinkle_citys = [DataManager.player_choose_city]
			var vstate = clVState.vstate(vstateId)
			if vstate.get_stored_equipments().empty():
				LoadControl._affiars_error("现如今并无多余的装备库存")
				return
	DataManager.set_env("列表页码", 0)
	DataManager.set_env("CURSOR", -1)
	SceneManager.show_confirm_dialog("此处是装备仓库")
	_bind_menu(vstateId)
	LoadControl.set_view_model(329)
	return

func _bind_menu(vstateId:int)->void:
	var sceneId = DataManager.get_current_scene_id()
	var ret = clCity.list_stored_equipments_paged(vstateId, sceneId < 20000)
	var items = ret[0]
	var values = ret[1]
	DataManager.set_env("列表值", values)
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 2;
	SceneManager.lsc_menu_top.lsc.items = items
	SceneManager.lsc_menu_top.lsc._set_data(32)
	var page = DataManager.get_env_int("列表页码")
	var maxPage = DataManager.get_env_int("列表页数")
	if maxPage > 0:
		SceneManager.lsc_menu_top.lsc.set_pager(page, maxPage)
	SceneManager.lsc_menu_top.show()
	SceneManager.lsc_menu_top.lsc.cursor_index = -1
	return

func wh_equip_menu():
	var vstateId = get_current_vstate_id()
	SceneManager.hide_all_tool();
	_bind_menu(vstateId)
	var menu = SceneManager.lsc_menu_top
	menu.lsc.set_cursor(DataManager.get_env_int("CURSOR"))
	menu.show()
	DataManager.set_env("CURRENT_FLOW", "wh_equip_menu")
	LoadControl.set_view_model(330)
	return

func wh_equip_deal_menu():
	var vstateId = get_current_vstate_id()
	SceneManager.hide_all_tool()
	_bind_menu(vstateId)
	var menu_array = ["交予", "丢弃"]
	var dic = DataManager.get_env_dict("选定装备")
	var equip = clEquip.equip(int(dic["ID"]), dic["类型"])
	var cnt = int(dic["装备库数量"])
	if cnt > 1:
		menu_array.append("全部丢弃")
	if dic.has("装备武将"):
		menu_array = ["交换"]

	DataManager.set_env("列表值", menu_array)
	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.lsc.columns = 1;
	SceneManager.lsc_menu.set_lsc(Vector2(40, 0));
	SceneManager.lsc_menu.lsc._set_data(32);
	SceneManager.lsc_menu.lsc.cursor_index = 0

	var msg = "{0} 如何处理？".format([equip.name()])
	if cnt > 1:
		msg = "{0}x{1} 如何处理？".format([equip.name(), cnt])
	SceneManager.lsc_menu.show_msg(msg);
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(331)
	return

func wh_equip_start():
	var item = DataManager.get_env_dict("选定装备")
	var equip = clEquip.equip(int(item["ID"]), item["类型"])
	var cnt = int(item["装备库数量"])
	var msg = "将{0}交予何人？".format([equip.name()])
	if cnt > 1:
		msg = "将{1}交予何人？(库存{0})".format([cnt, equip.name()])
	if item.has("装备武将"):
		msg = "何人与{0}换装{1}？".format([
			ActorHelper.actor(int(item["装备武将"])).get_name(), equip.name(),
		])
	DataManager.set_env("装备提示", msg)
	var targets = []
	var actors = []
	match DataManager.get_current_scene_id():
		10000:
			SceneManager.current_scene().cursor.hide()
			var city = clCity.city(DataManager.player_choose_city)
			actors.append_array(city.get_actor_ids())
			actors.append_array(city.get_ceil_actor_ids())
			SceneManager.current_scene().cursor.hide()
			DataManager.twinkle_citys = [city.ID]
		20000:
			var wf = DataManager.get_current_war_fight()
			DataManager.player_choose_city = wf.target_city().ID
			SceneManager.lsc_menu.show_orderbook(false)
			SceneManager.show_cityInfo(false)
			if DataManager.endless_model:
				actors.append_array(EndlessGame.player_actors)
	for actorId in actors:
		if ActorHelper.actor(actorId).get_equip(equip.type).equals(equip):
			continue
		targets.append(actorId)
	if equip.type == "道具" \
		and equip.id in [
			StaticManager.JEWELRY_ID_JIEZISHU,
			StaticManager.JEWELRY_ID_HANFEIZI,
		]:
		SceneManager.show_actorlist_learning(targets, cnt > 1, msg);
	else:
		SceneManager.show_actorlist_equip(targets, cnt > 1, msg, equip)
	LoadControl.set_view_model(332)
	return

func wh_equip_confirm_gave():
	var vstateId = get_current_vstate_id()
	var actorIds = DataManager.get_env_int_array("装备武将")
	var actor = ActorHelper.actor(actorIds[0])
	var dic = DataManager.get_env_dict("选定装备")
	var equip = clEquip.equip(int(dic["ID"]), dic["类型"])
	var msg = "将{1}\n交给{2}".format([dic["装备库数量"], equip.name(), actor.get_name()])
	if actorIds.size() > 1:
		msg += "等{0}人".format([actorIds.size()])
	if dic.has("装备武将"):
		var fromId = int(dic["装备武将"])
		var fromActor = ActorHelper.actor(fromId)
		msg = "{0}现装备{1}\n{2}现装备{3}\n互换{4}可否？".format([
			actor.get_name(), actor.get_equip(equip.type).name(),
			fromActor.get_name(), fromActor.get_equip(equip.type).name(),
			equip.type,
		])
	SceneManager.show_yn_dialog(msg)
	_bind_menu(vstateId)
	LoadControl.set_view_model(341)
	return

#执行和动画
func wh_equip_animation():
	var sceneId = DataManager.get_current_scene_id()
	var vstateId = get_current_vstate_id()
	var vstate = clVState.vstate(vstateId)
	var actorIds = DataManager.get_env_int_array("装备武将")
	var dic = DataManager.get_env_dict("选定装备")
	var equip = clEquip.equip(int(dic["ID"]), dic["类型"])

	var msg = ""

	if dic.has("装备武将"):
		# 分支：装备交换
		# 基本检查
		if actorIds.size() != 1:
			FlowManager.add_flow("equip_finish")
			return
		var actor = ActorHelper.actor(actorIds[0])
		var fromId = int(dic["装备武将"])
		var fromActor = ActorHelper.actor(fromId)
		if fromActor.get_equip(equip.type).id != equip.id:
			FlowManager.add_flow("equip_finish")
			return
		var current = actor.get_equip(equip.type)
		actor.set_equip(equip)
		fromActor.set_equip(current)
		msg = "{0}已换装{1}\n{2}已换装{3}".format([
			actor.get_name(), actor.get_equip(equip.type).name(),
			fromActor.get_name(), fromActor.get_equip(equip.type).name(),
		])
	else:
		# 分支：装备分配
		var currentEquipped = null
		for actorId in actorIds:
			var actor = ActorHelper.actor(actorId)
			currentEquipped = actor.get_equip(equip.type)
			vstate.add_stored_equipment(currentEquipped)
			vstate.remove_stored_equipment(equip)
			actor.set_equip(equip)
			#更新体力上限
			actor.set_hp(min(actor.get_max_hp(), actor.get_hp()))
		msg = "已将{0}交给{1}".format([
			equip.name(), ActorHelper.actor(actorIds[0]).get_name(),
		])
		if actorIds.size() > 1:
			msg += "等人"
		elif currentEquipped != null:
			msg += "\n{0}置入装备库".format([
				currentEquipped.name()
			])
	if DataManager.get_current_scene_id() == 10000 \
		and actorIds.size() == 1 \
		and equip.id == StaticManager.JEWELRY_ID_JIEZISHU \
		and equip.type == "道具":
		msg += "\n是否进入学问馆？"
		DataManager.player_choose_actor = actorIds[0]
		SceneManager.show_yn_dialog(msg)
		LoadControl.set_view_model(336)
		return
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg)
	if sceneId == 20000 and DataManager.endless_model:
		_bind_menu(vstateId)
	SceneManager.play_affiars_animation("Warehouse_AwardActor", "")
	LoadControl.set_view_model(335)
	return

func wh_equip_before_drop_all():
	DataManager.set_env("批量丢弃", 1)
	FlowManager.add_flow("wh_equip_before_drop")
	return

#丢弃：检查是否S级
func wh_equip_before_drop():
	var vstateId = get_current_vstate_id()
	var vstate = clVState.vstate(vstateId)
	var dic = DataManager.get_env_dict("选定装备")
	var equip = clEquip.equip(int(dic["ID"]), dic["类型"])
	if equip.level_score() < 9:
		FlowManager.add_flow("wh_equip_drop");
		return
	SceneManager.show_confirm_dialog("{0}不可多得\n望主公三思".format([equip.name()]))
	LoadControl.set_view_model(338)
	return

#扔掉武器
func wh_equip_drop():
	var vstateId = get_current_vstate_id()
	var vstate = clVState.vstate(vstateId)
	var dic = DataManager.get_env_dict("选定装备")
	var equip = clEquip.equip(int(dic["ID"]), dic["类型"])
	var batch = DataManager.get_env_int("批量丢弃")
	var removed = vstate.remove_stored_equipment(equip, batch > 0)

	if batch > 0 and removed > 1:
		SceneManager.show_confirm_dialog("全部{0}件{1}已丢弃".format([removed, equip.name()]))
	else:
		SceneManager.show_confirm_dialog("{0}已丢弃".format([equip.name()]))
	_bind_menu(vstateId)
	LoadControl.set_view_model(339)
	return

# 返回前序流程
func equip_finish():
	LoadControl.view_model_name = prev_view_model_name
	match DataManager.get_current_scene_id():
		10000:
			DataManager.set_env("内政.集市选项", 1)
			FlowManager.add_flow("enter_warehouse_menu")
		20000:
			LoadControl.end_script()
			LoadControl.load_script("war/player_over_settle.gd")
			FlowManager.add_flow("war_equip_done")
	return

func get_current_vstate_id()->int:
	match DataManager.get_current_scene_id():
		10000:
			return DataManager.vstates_sort[DataManager.vstate_no]
		20000:
			if DataManager.endless_model:
				return EndlessGame.player_vstateId
			return DataManager.vstates_sort[DataManager.vstate_no]
	return -1

func go_study():
	FlowManager.add_flow("load_script|affiars/fair_school.gd")
	FlowManager.add_flow("school_2")
	return
