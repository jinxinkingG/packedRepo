extends "effect_10000.gd"

#周转主动技
#【周转】内政，主动技。可选择装备库中的一件S级装备，卖给史莱姆神，获得2000金；或以5000金的价格向史莱姆神购买之前卖出的装备。每月限1次。

const EFFECT_ID = 10144
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SELL_PRICE = 2000
const BUY_PRICE = 5000
const PAGE_SIZE = 10
const CD = 1

func effect_10144_start() -> void:
	# 获取已卖出的装备列表
	# 这里用史莱姆神的技能变量来统一存储
	var sold = ske.affair_get_skill_val_array(-1, StaticManager.ACTOR_ID_SLIME_GOD)

	var options = ["卖出", "赎回"]
	var msg = "哦，是{0}啊！\n".format([actor.get_name()])
	if not sold.empty():
		msg += "宝贝们都好好保管着呢！\n"
	else:
		options = ["卖出", "算了"]
	msg += "今天想做什么生意？"

	DataManager.set_env("{0}翻页".format([ske.skill_name]), 0)
	SceneManager.show_yn_dialog(msg, StaticManager.ACTOR_ID_SLIME_GOD, 2, options)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_sell", FLOW_BASE + "_buy", false)
	return

func effect_10144_sell() -> void:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	var vs = clVState.vstate(vstateId)
	var items = []
	var values = []
	for item in vs.list_stored_equipments():
		var equip = item[0]
		if equip.level() != "S":
			continue
		items.append(equip.name() + "#D40000")
		values.append([equip.id, equip.type])
	if values.empty():
		var msg = "咦？你好像没有S级装备呢……\n要不下次带着宝贝再来？"
		play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2999)
		return
	var maxPage = max(0, (values.size() - 1) / PAGE_SIZE)
	var page = DataManager.get_env_int("{0}翻页".format([ske.skill_name]))
	if page < 0:
		page = 0
	if page > maxPage:
		page = maxPage
	items = items.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)
	values = values.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)
	for i in range(items.size(), PAGE_SIZE):
		items.append("")
		values.append([-1, -1])
	if page < maxPage:
		items.append("下一页")
		values.append([-1, page + 1])
	if page > 0:
		items.append("上一页")
		values.append([-1, page - 1])

	var msg = "选择要卖出的装备"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, values, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_item(FLOW_BASE + "_sell_selected")
	return

func effect_10144_sell_selected() -> void:
	# 选择买卖类型
	var item = DataManager.get_env_array("目标项")
	if item[0] == -1:
		var page = int(item[1])
		DataManager.set_env("{0}翻页".format([ske.skill_name]), page)
		goto_step("sell")
		return
	var equip = clEquip.equip(int(item[0]), item[1])
	var msg = "哇！<{0}>！\n这可是稀世珍宝啊！\n我出{1}金收购，成交吗？".format([equip.name(), SELL_PRICE])
	play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2002, true)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_sell_confirmed", FLOW_BASE + "_sell_cancelled", false)
	return

func effect_10144_sell_confirmed() -> void:
	var item = DataManager.get_env_array("目标项")
	var equip = clEquip.equip(int(item[0]), item[1])
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())
	vs.remove_stored_equipment(equip)
	var gold = city.add_gold(SELL_PRICE)
	var sold = ske.affair_get_skill_val_array(-1, StaticManager.ACTOR_ID_SLIME_GOD)
	sold.insert(0, [equip.id, equip.type])
	ske.affair_set_skill_val(sold, 99999, -1, StaticManager.ACTOR_ID_SLIME_GOD)
	ske.affair_cd(CD)

	var msg = "成交！<{0}>归我了！\n嘿嘿，我会好好珍惜的～\n（获得{1}金".format([equip.name(), SELL_PRICE])
	play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2999)
	return

func effect_10144_sell_cancelled() -> void:
	var msg = "那就下回再聊吧！\n我等你带着宝贝再来哦！"
	play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2999)
	return

func effect_10144_buy() -> void:
	var sold = ske.affair_get_skill_val_array(-1, StaticManager.ACTOR_ID_SLIME_GOD)
	if sold.empty():
		FlowManager.add_flow("player_ready")
		return

	# 检查金钱
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	if city.get_gold() < BUY_PRICE:
		var msg = "想赎回宝贝？\n那可要{0}金哦！\n你的钱好像不够呢……".format([BUY_PRICE])
		play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2999)
		return

	var items = []
	var values = []
	for item in sold:
		var equip = clEquip.equip(int(item[0]), item[1])
		items.append(equip.name() + "#D40000")
		values.append([equip.id, equip.type])
	var maxPage = max(0, (values.size() - 1) / PAGE_SIZE)
	var page = DataManager.get_env_int("{0}翻页".format([ske.skill_name]))
	if page < 0:
		page = 0
	if page > maxPage:
		page = maxPage
	items = items.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)
	values = values.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1)
	for i in range(items.size(), PAGE_SIZE):
		items.append("")
		values.append([-1, -1])
	if page < maxPage:
		items.append("下一页")
		values.append([-1, page + 1])
	if page > 0:
		items.append("上一页")
		values.append([-1, page - 1])

	var msg = "选择要赎回的装备"
	SceneManager.show_unconfirm_dialog(msg, StaticManager.ACTOR_ID_SLIME_GOD)
	SceneManager.bind_top_menu(items, values, 2)
	LoadControl.set_view_model(2003)
	return

func on_view_model_2003() -> void:
	wait_for_choose_item(FLOW_BASE + "_buy_selected")
	return

func effect_10144_buy_selected() -> void:
	var item = DataManager.get_env_array("目标项")
	if item[0] == -1:
		var page = int(item[1])
		DataManager.set_env("{0}翻页".format([ske.skill_name]), page)
		goto_step("buy")
		return
	var equip = clEquip.equip(int(item[0]), item[1])
	var msg = "想赎回 <{0}>？\n那可要{1}金哦！".format([equip.name(), BUY_PRICE])
	play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2004, true)
	return

func on_view_model_2004() -> void:
	wait_for_yesno(FLOW_BASE + "_buy_confirmed", FLOW_BASE + "_buy_cancelled", false)
	return

func effect_10144_buy_confirmed() -> void:
	var item = DataManager.get_env_array("目标项")
	var equip = clEquip.equip(int(item[0]), item[1])
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())
	vs.add_stored_equipment(equip)
	var gold = city.add_gold(-BUY_PRICE)
	var sold = ske.affair_get_skill_val_array(-1, StaticManager.ACTOR_ID_SLIME_GOD)
	var updated = []
	for s in sold:
		if int(s[0]) == equip.id and s[1] == equip.type:
			continue
		updated.append(s)
	ske.affair_set_skill_val(updated, 99999, -1, StaticManager.ACTOR_ID_SLIME_GOD)
	ske.affair_cd(CD)

	var msg = "好吧好吧，既然你这么想要……\n给你啦！记得再来哦！\n（<{0}>已放入装备库".format([
		equip.name(), abs(gold)])
	play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2999)
	return

func effect_10144_buy_cancelled() -> void:
	var msg = "那就下回再聊吧！\n记得来晚了可就没了哦！"
	play_dialog(StaticManager.ACTOR_ID_SLIME_GOD, msg, 2, 2999)
	return
