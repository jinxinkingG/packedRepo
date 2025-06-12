extends "affairs_base.gd"

var prev_view_model_name = ""

#装备店
func _init() -> void:
	prev_view_model_name = LoadControl.view_model_name
	LoadControl.view_model_name = "内政-玩家-步骤"
	FlowManager.bind_signal_method("equip_menu", self)
	FlowManager.bind_signal_method("equip_weapon_menu", self)
	FlowManager.bind_signal_method("equip_detail_menu", self)
	FlowManager.bind_signal_method("equip_start", self)
	FlowManager.bind_signal_method("equip_2", self)
	FlowManager.bind_signal_method("equip_3", self)
	FlowManager.bind_signal_method("equip_4", self)
	FlowManager.bind_signal_method("equip_5", self)
	FlowManager.bind_signal_method("equip_confirm", self)
	FlowManager.bind_signal_method("equip_done", self)
	FlowManager.bind_signal_method("equip_finish", self)
	return

#按键操控
func _input_key(delta: float):
	var scene_affiars:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	var exitFlow = "enter_fair_menu"
	if DataManager.get_current_scene_id() == 20000:
		exitFlow = "equip_finish"
	match LoadControl.get_view_model():
		401:#装备店菜单
			if not wait_for_options([], exitFlow):
				return
			var menu_array = DataManager.get_env_array("列表值")
			var type_name = menu_array[bottom.lsc.cursor_index]
			DataManager.set_env("大类型", type_name)
			if type_name == "武器":#如果是武器
				FlowManager.add_flow("equip_weapon_menu");
				return;
			
			DataManager.set_env("子类型", type_name)
			DataManager.set_env("装备数量", 1)
			DataManager.set_env("装备翻页", 0)
			FlowManager.add_flow("equip_detail_menu")
		415:
			if not wait_for_options([], "equip_menu"):
				return
			var menu_array = DataManager.get_env_array("列表值")
			var type_name = menu_array[bottom.lsc.cursor_index]
			DataManager.set_env("子类型", type_name)
			DataManager.set_env("装备数量", 1)
			DataManager.set_env("装备翻页", 0)
			FlowManager.add_flow("equip_detail_menu")
		410:#具体装备选择
			var menu = SceneManager.lsc_menu
			var all = DataManager.get_env_array("售卖装备")
			var curPage = DataManager.get_env_int("装备翻页")
			var maxPage = int((all.size() - 1) / 4)
			if maxPage > 0:
				if menu.lsc.cursor_index < 2 and Input.is_action_just_pressed("ANALOG_UP"):
					Input.action_release("ANALOG_UP")
					DataManager.set_env("装备翻页", curPage - 1)
				elif (menu.lsc.items.size() <= 2 or menu.lsc.cursor_index > 1) and Input.is_action_just_pressed("ANALOG_DOWN"):
					Input.action_release("ANALOG_DOWN")
					DataManager.set_env("装备翻页", curPage + 1)
			var page = DataManager.get_env_int("装备翻页")
			if page < 0:
				page = maxPage
			if page > maxPage:
				page = 0
			DataManager.set_env("装备翻页", page)
			if page != curPage:
				var items = []
				var values = []
				for i in range(page * 4, min(all.size(), page * 4 + 4)):
					var dic = all[i]
					items.append("{name}  \t{price}{color}{flag}".format(dic))
					values.append(dic["id"])
				DataManager.set_env("列表值", values)
				menu.lsc.items = items
				menu.lsc._set_data(28)
				var msg = "买哪个？（第{0}/{1}页）".format([
					page + 1, maxPage + 1,
				])
				menu.rtlMessage.text = msg
			var values = DataManager.get_env_int_array("列表值")
			wait_for_options([], "equip_menu")
			var equipId = values[menu.lsc.cursor_index]
			var equipType = DataManager.get_env_str("大类型")
			var equip = clEquip.equip(equipId, equipType)
			var lastEquipId = DataManager.get_env_int("检视装备")
			if lastEquipId != equipId:
				var conEquipInfo:Control = SceneManager.conEquipInfo
				conEquipInfo.show_equipinfo(equip, "shop")
				conEquipInfo.show()
				DataManager.set_env("检视装备", equipId)
			if not Global.is_action_pressed_AX():
				return
			if not menu.is_msg_complete():
				menu.show_all_msg()
				return
			LoadControl.set_view_model(-1)
			var actorId = DataManager.player_choose_actor
			var remaining = equip.remaining()
			if remaining == 0:
				_error("此装备已被卖完")
				return
			if not equip.actor_can_use(actorId):
				_error("无论如何\n亦无法掌握这等宝物", actorId, 3)
				return
			var price = get_equip_price(equip)
			var gold = get_available_gold()
			if price > gold:
				_error("军资不足以支付装备购买", actorId, 3)
				return
			DataManager.set_env("购买装备", equip.id)
			FlowManager.add_flow("equip_2")
		411:#选人
			if not wait_for_choose_actor("enter_fair_menu"):
				return
			DataManager.player_choose_actor = SceneManager.actorlist.get_select_actor()
			FlowManager.add_flow("equip_menu")
		4111:#输入数量
			if wait_for_number_input("equip_detail_menu"):
				LoadControl.set_view_model(-1)
				var cnt = SceneManager.input_numbers.get_current_input_node().get_number()
				DataManager.set_env("装备数量", cnt)
				FlowManager.add_flow("equip_confirm")
				return
		412:#命令书
			wait_for_yesno("equip_3", exitFlow)
	return

#装备店菜单
func equip_menu():
	var actorId = DataManager.player_choose_actor
	var menu = StaticManager.EQUIPMENT_TYPES.duplicate()
	DataManager.set_env("列表值", menu)
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = menu
	SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(0, 10), Vector2(190, 40))
	SceneManager.lsc_menu.lsc._set_data(32)
	SceneManager.hide_all_tool()
	var msg = "购买何种装备？"
	SceneManager.lsc_menu.show_msg(msg, Vector2.ZERO, 32)
	SceneManager.lsc_menu.show()
	match DataManager.get_current_scene_id():
		10000:
			SceneManager.current_scene().cursor.hide()
			DataManager.twinkle_citys = [DataManager.player_choose_city]
			SceneManager.show_cityInfo(true)
		20000:
			var map = SceneManager.current_scene().war_map
			map.cursor.hide()
			SceneManager.lsc_menu.show_orderbook(false)
			SceneManager.show_cityInfo(false)
	LoadControl.set_view_model(401)
	return

#武器菜单
func equip_weapon_menu():
	var actorId = DataManager.player_choose_actor
	var city = clCity.city(DataManager.player_choose_city)
	var shop_type = city.get_equip_shop_type()
	var equip_dic = StaticManager.get_equip_shop_setting()[str(shop_type)]
	var menu_array = []
	for weapon_type in ["剑","刀","枪","锤","斧"]:
		if not weapon_type in equip_dic:
			continue;
		if Array(equip_dic[weapon_type]).empty():
			continue
		menu_array.append(weapon_type)
	DataManager.set_env("列表值", menu_array)
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = menu_array
	SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(0, 10), Vector2(190, 40))
	SceneManager.lsc_menu.lsc._set_data(32)
	var msg = "购买何种武器？"
	SceneManager.lsc_menu.show_msg(msg, Vector2.ZERO, 32)
	SceneManager.lsc_menu.show()

	match DataManager.get_current_scene_id():
		10000:
			var scene_affiars:Control = SceneManager.current_scene()
			scene_affiars.cursor.hide()
			DataManager.twinkle_citys = [city.ID]
			SceneManager.show_cityInfo(true)
		20000:
			SceneManager.lsc_menu.show_orderbook(false)
			SceneManager.show_cityInfo(false)
	LoadControl.set_view_model(415)
	return

#装备店详细菜单
func equip_detail_menu():
	var actorId = DataManager.player_choose_actor
	var city = clCity.city(DataManager.player_choose_city)
	var big_equip_type = DataManager.get_env_str("大类型")
	var detail_equip_type = DataManager.get_env_str("子类型")
	var sellings = city.get_selling_equips()
	var selling = []
	if detail_equip_type in sellings:
		selling = sellings[detail_equip_type]

	var pageSize = 4
	DataManager.set_env("检视装备", -1)
	DataManager.set_env("装备翻页", 0)
	var items = []
	var values = []
	var all = []
	for equip in selling:
		var color = ""
		if equip.level() == "S":
			color = StaticManager.COLOR_CODE_SPECIAL_EQUIP
		var flag = ""
		if equip.remaining() == 0:
			flag = "@DEL"
		var dic = {
			"id": equip.id,
			"price": equip.price(),
			"name": equip.name(),
			"color": color,
			"flag": flag,
		}
		if items.size() < 4:
			items.append("{name}  \t{price}{color}{flag}".format(dic))
			values.append(equip.id)
		all.append(dic)

	DataManager.set_env("列表值", values)
	DataManager.set_env("售卖装备", all)
	SceneManager.lsc_menu.lsc.columns = 2
	SceneManager.lsc_menu.lsc.items = items
	SceneManager.lsc_menu.set_actor_lsc(actorId, Vector2(0, 10), Vector2(190, 40))
	SceneManager.lsc_menu.lsc._set_data(28)
	SceneManager.hide_all_tool()
	var msg = "买哪个？"
	if all.size() > items.size():
		msg += "（第1/{0}页）".format([1 + int((all.size() - 1) / 4)])
	SceneManager.lsc_menu.show_msg(msg, Vector2.ZERO, 32)
	SceneManager.lsc_menu.show()

	match DataManager.get_current_scene_id():
		10000:
			var scene_affiars:Control = SceneManager.current_scene()
			scene_affiars.cursor.hide()
			SceneManager.show_cityInfo(true)
			DataManager.twinkle_citys = [city.ID]
		20000:
			SceneManager.lsc_menu.show_orderbook(false)
			SceneManager.show_cityInfo(false)
	LoadControl.set_view_model(410)
	return

#选择武将
func equip_start():
	LoadControl.set_view_model(411);
	var scene_affiars:Control = SceneManager.current_scene();
	scene_affiars.cursor.hide();
	var city = clCity.city(DataManager.player_choose_city)
	DataManager.twinkle_citys = [city.ID]
	var props = ["体", "武", "知", "忠", "德", "兵力"]
	SceneManager.show_actorlist(city.get_actor_ids(), false, "为哪位更新装备？", false, props)
	return

#命令书
func equip_2():
	var actorId = DataManager.player_choose_actor
	var equipType = DataManager.get_env_str("大类型")
	var equipId = DataManager.get_env_int("购买装备")
	var equip = clEquip.equip(equipId, equipType)
	var price = get_equip_price(equip)
	var gold = get_available_gold()
	var limit = int(gold / price)
	limit = min(9, limit)
	if equip.remaining() > 0:
		limit = min(equip.remaining(), limit)
	if limit == 1:
		FlowManager.add_flow("equip_confirm")
		return
	var msg = "{0}需{1}金，购买几件?".format([equip.name(), price])
	SceneManager.show_input_numbers(msg, [equip.name()], [limit], [0])
	SceneManager.input_numbers.get_current_input_node().set_number(1)
	SceneManager.input_numbers.show_actor(actorId)
	LoadControl.set_view_model(4111)
	return

func equip_confirm():
	var actorId = DataManager.player_choose_actor
	var equipType = DataManager.get_env_str("大类型")
	var equipId = DataManager.get_env_int("购买装备")
	var equip = clEquip.equip(equipId, equipType)
	var price = get_equip_price(equip)
	var gold = get_available_gold()
	var cnt = DataManager.get_env_int("装备数量")
	match DataManager.get_current_scene_id():
		10000:
			#命令书确认
			var msg = "消耗1枚命令书\n花费{0}金\n购入{1}件{2}，可否？".format([
				cnt * price, cnt, equip.name(),
			])
			SceneManager.show_yn_dialog(msg, actorId)
			SceneManager.show_cityInfo(true)
		20000:
			var msg = "花费{0}金\n购入{1}件{2}，可否？".format([
				cnt * price, cnt, equip.name(),
			])
			SceneManager.show_yn_dialog(msg, actorId)
	LoadControl.set_view_model(412)
	return


#命令消耗动画
func equip_3():
	match DataManager.get_current_scene_id():
		10000:
			SceneManager.dialog_use_orderbook_animation("equip_4")
			LoadControl.set_view_model(413)
		20000:
			FlowManager.add_flow("equip_done")
	return

#动画
func equip_4():
	if DataManager.get_current_scene_id() == 20000:
		FlowManager.add_flow("equip_done")
		return
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var vs = clVState.vstate(vstateId)
	var actor = ActorHelper.actor(DataManager.player_choose_actor)
	var city = clCity.city(DataManager.player_choose_city)
	var cnt = DataManager.get_env_int("装备数量")
	var equipId = DataManager.get_env_int("购买装备")
	var equipType = DataManager.get_env_str("大类型")
	var equip = clEquip.equip(equipId, equipType)
	var price = get_equip_price(equip)
	if equip.remaining() > 0:
		cnt = min(equip.remaining(), cnt)
	var cost = price * cnt
	city.add_gold(-cost)
	if equip.remaining() >= 0:
		equip.dec_count(cnt)
	var msg = "花费{0}，{1}换装{2}".format([cost, actor.get_name(), equip.name()])
	# 身上装备入库
	var current = actor.get_equip(equip.type)
	vs.add_stored_equipment(current)
	# 替换装备
	actor.set_equip(equip)
	msg += "\n{0}置入装备仓库".format([current.name()])
	# 多余购买的装备入库
	var added = 0
	for i in range(1, cnt):
		vs.add_stored_equipment(equip)
		added += 1
	if added > 0:
		msg += "\n另{0}件{1}已入库".format([added, equip.name()])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg)
	SceneManager.play_affiars_animation("Fair_EquipShop", "confirm_to_ready")
	
	#更新体力上限
	actor.set_hp(min(actor.get_max_hp(), actor.get_hp()))
	LoadControl.set_view_model(414)
	return

# 带购物信息返回流程，战场进入专用
func equip_done():
	LoadControl.view_model_name = prev_view_model_name
	LoadControl.set_view_model(2007)
	return

# 无购物结束流程，战场进入专用
func equip_finish():
	LoadControl.view_model_name = prev_view_model_name
	LoadControl.set_view_model(2009)
	return

func get_equip_price(equip:clEquip.EquipInfo)->int:
	var price = equip.price()
	if equip.type == "道具" and equip.subtype() == "书":
		# 旧版治典有这个折扣，目前暂无技能实装此 buff
		var priceOff = SkillRangeBuff.max_val_for_city("书籍折扣", DataManager.player_choose_city)
		if priceOff > 0 and priceOff < 1:
			price = int(price * priceOff)
	return price

# 提示错误信息，兼容战场进入和内政进入的情况
func _error(msg:String, actorId:int=-1, mood:int=2)->void:
	match DataManager.get_current_scene_id():
		10000:
			LoadControl._error(msg, actorId, mood)
		20000:
			SceneManager.show_confirm_dialog(msg, actorId, mood)
			LoadControl.view_model_name = prev_view_model_name
			LoadControl.set_view_model(2008)
	return

func get_available_gold()->int:
	match DataManager.get_current_scene_id():
		10000:
			var city = clCity.city(DataManager.player_choose_city)
			return city.get_gold()
		20000:
			var wa = DataManager.get_war_actor(DataManager.player_choose_actor)
			if wa == null:
				return 0
			var wv = wa.war_vstate()
			if wv == null:
				return 0
			return wv.money
	return 0
