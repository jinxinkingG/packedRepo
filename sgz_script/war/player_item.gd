extends "war_base.gd"

const msg = "选择哪件物品？"

#道具
func _init() -> void:
	LoadControl.view_model_name = "战争-玩家-步骤";
	FlowManager.bind_signal_method("player_item_start", self)
	FlowManager.bind_signal_method("player_item_options", self)
	FlowManager.bind_signal_method("player_item_trans", self)
	FlowManager.bind_signal_method("player_item_use", self)
	FlowManager.bind_signal_method("player_item_give", self)

#按键操控
func _input_key(delta: float):
	var view_model = LoadControl.get_view_model();
	var top = SceneManager.lsc_menu_top;
	match view_model:
		0:
			wait_for_confirmation()
		3000: #选择物品
			var description_visible = top.get_TopMsg_visible();
			if not description_visible:
				var selected = wait_for_choose_item("player_ready")
				var value_array = DataManager.common_variable["列表值"]
				if selected < 0 or selected >= value_array.size():
					var option = top.lsc.cursor_index
					if Input.is_action_just_pressed("EMU_SELECT"):
						var actorId = DataManager.player_choose_actor
						var item_id:int = int(value_array[option]);
						var info = ItemHelper.getItem(item_id)
						var item_num = info.getCount(actorId);
						var top_msg = "[center][color=yellow]【{0}】[/color][/center]\n".format([info.name]);
						top_msg += "{0}\n".format([info.desc])
						top_msg += "[center]------------------------------------[/center]\n"
						top_msg += "[color=#00FFFF]持有数量:{0}[/color]".format([item_num])
						
						top.set_TopMsg_text(top_msg);
						top.set_TopMsg_visible(true);
					return
				DataManager.common_variable["战争.物品"] = value_array[selected]
				FlowManager.add_flow("player_item_options")
			else:
				if(Input.is_action_just_pressed("EMU_SELECT") or Global.is_action_pressed_BY()):
					top.set_TopMsg_visible(false);
					var actorId = DataManager.player_choose_actor
					SceneManager.show_unconfirm_dialog(msg,actorId)
					top.show();
		3001: #处理物品
			wait_for_options(["player_item_use", "player_item_trans"], "player_item_start")
		3002: #选择目标武将
			if not wait_for_choose_actor("player_item_options"):
				return
			FlowManager.add_flow("player_item_give")

func player_item_start():
	SceneManager.hide_all_tool()
	var page = 0;
	if DataManager.common_variable.has("列表页码"):
		page = int(DataManager.common_variable["列表页码"])
	var page_nums = 12
	var menu_array = []
	var value_array = []
	var actorId = DataManager.player_choose_actor
	var items = ItemHelper.getActorItems(actorId)
	if items.empty():
		LoadControl._error("暂无可用物品")
		return
	for itemInfo in items:
		if menu_array.size() >= page_nums:
			break
		var item = itemInfo[0]
		var cnt = itemInfo[1]
		value_array.append(item.id)
		menu_array.append("{0} x{1}".format([item.name, cnt]))
	DataManager.common_variable["列表值"] = value_array
	SceneManager.lsc_menu_top.set_lsc()
	SceneManager.lsc_menu_top.lsc.columns = 2
	SceneManager.lsc_menu_top.lsc.items = menu_array
	SceneManager.lsc_menu_top.lsc._set_data()
	SceneManager.show_unconfirm_dialog(msg,actorId)
	SceneManager.lsc_menu_top.set_memo("查看物品说明");
	SceneManager.lsc_menu_top.show()
	LoadControl.set_view_model(3000)
	return

func player_item_options():
	SceneManager.hide_all_tool();
	var menu_array = ["使用", "转交"];
	DataManager.common_variable["列表值"] = menu_array

	SceneManager.lsc_menu.lsc.items = menu_array;
	SceneManager.lsc_menu.lsc.columns = 1;
	SceneManager.lsc_menu.set_lsc()
	SceneManager.lsc_menu.lsc._set_data();

	var itemId = int(DataManager.common_variable["战争.物品"])
	var msg = "如何处理 「{0}」？".format([ItemHelper.getItem(itemId).name])
	SceneManager.lsc_menu.show_msg(msg)
	SceneManager.lsc_menu.show()
	LoadControl.set_view_model(3001)
	return

func player_item_use():
	var itemId = int(DataManager.common_variable["战争.物品"])
	var actorId = DataManager.player_choose_actor
	var msgs = ItemHelper.getItem(itemId).use(actorId)
	if msgs.empty():
		LoadControl._error("无法使用")
		return
	SceneManager.show_confirm_dialog("\n".join(msgs), actorId)
	LoadControl.set_view_model(0)
	return

func player_item_trans():
	var actorId = DataManager.player_choose_actor
	var itemId = int(DataManager.common_variable["战争.物品"])
	var item = ItemHelper.getItem(itemId)
	if not item.canTransfer:
		LoadControl._error("「{0}」不可转交".format([item.name]))
		return
	var me = DataManager.get_war_actor(actorId)

	var targets = []
	var wf = DataManager.get_current_war_fight()
	for wa in me.get_teammates(false, true):
		if Global.get_distance(wa.position, me.position) > 6:
			continue
		targets.append(wa.actorId)
	if not show_actor_targets(actorId, targets):
		return
	LoadControl.set_view_model(3002)
	return

func player_item_give():
	var actorId = DataManager.player_choose_actor
	var itemId = int(DataManager.common_variable["战争.物品"])
	var targetId = int(DataManager.common_variable["武将"])
	var item = ItemHelper.getItem(itemId)
	if item.getCount(actorId) <= 0:
		LoadControl._error("物品数量不足")
		return
	item.transfer(actorId, targetId)
	SceneManager.show_confirm_dialog("已将「{0}」交给{1}".format([
		item.name, ActorHelper.actor(targetId).get_name()
	]))
	LoadControl.set_view_model(0)
	return
