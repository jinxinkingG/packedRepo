extends "res://script/event_base.gd"

# 子龙救徐母事件

const WHERE = StaticManager.CITY_ID_XINYE
const XUSHU = StaticManager.ACTOR_ID_XUSHU
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const CAOCAO = StaticManager.ACTOR_ID_CAOCAO
const ZILONG = StaticManager.ACTOR_ID_ZHAOYUN

func _init():
	LoadControl.view_model_name = "玩家-事件"
	name = "zilong_jiuxu"
	timing = [20701]
	players = [LIUBEI]
	vstates = {
		StaticManager.VSTATEID_LIUBEI: LIUBEI,
		StaticManager.VSTATEID_CAOCAO: CAOCAO
	}
	cities = {
		WHERE: StaticManager.VSTATEID_LIUBEI,
	}
	actors = {
		LIUBEI: WHERE,
		XUSHU: WHERE,
		ZILONG: WHERE,
		# -1 表示在哪里都可以，寻找并更新其所在
		CAOCAO: -1,
	}
	prevEvents = ["xushu_bencao"]
	dialogs = [
		[WHERE, ZILONG, "军师且慢行\n主公，此中有诈！", 0],
		[WHERE, XUSHU, "子龙何意？\n莫非 ……", 2],
		[WHERE, ZILONG, "云四野巡检方归\n近日四野有曹军斥候异动\n云本已生疑", 2],
		[WHERE, ZILONG, "昨日归营\n听闻军师遭此变故\n暗中审查许昌来人", 2],
		[WHERE, ZILONG, "此人知军师将行，喜动颜色\n又潜出营帐，暗通讯号\n侦听方知，书信为程昱伪造", 2],
		[WHERE, XUSHU, "！！！", 0],
		[WHERE, XUSHU, "此必是逼迫老母不成\n老母教谕甚严，素重大义\n不得母命而往，必深责我", 2],
		[WHERE, ZILONG, "云当直言，军师休怪\n军师此去，不独尊母见责\n若有万一，恐遇难言之变", 3],
		[WHERE, LIUBEI, "这 …… ……\n然则如何是好\n…… ……", 3],
		[WHERE, ZILONG, "主公勿忧，云与军师同往\n相机而行，旬月便回", 2],
		[WHERE, XUSHU, "子龙胆大心细，此事可行\n只是有劳子龙了", 2],
	]
	return

func event_go()->void:
	SceneManager.black.hide()
	# 判断隐藏条件
	if not OrderHistory.orders_executed(StaticManager.VSTATEID_LIUBEI, ZILONG, ["搜索"]):
		event_settle_bad_end()
		return
	event_dialog()
	return

func event_settle_bad_end()->void:
	# 徐庶
	var xs = ActorHelper.actor(XUSHU)
	# 曹操所在城市
	var cityId = DataManager.get_office_city_by_actor(CAOCAO)
	var city = clCity.city(cityId)
	clCity.move_out(xs.actorId)
	clCity.move_to(xs.actorId, city.ID)
	xs.set_loyalty(40)
	var vs = clVState.vstate(city.get_vstate_id())
	DataManager.twinkle_citys = [WHERE, city.ID]
	var msg = "{0}转投{1}军\n出仕于{2}".format([
		xs.get_name(), vs.get_lord_name(), city.get_full_name(),
	])
	SceneManager.show_vstate_dialog(msg)
	LoadControl.set_view_model(2999)
	return

func event_settle()->void:
	# 徐庶
	var xs = ActorHelper.actor(XUSHU)
	clCity.move_out(xs.actorId)
	xs.set_status_disabled()
	# 赵云
	var zl = ActorHelper.actor(ZILONG)
	zl.set_status_disabled()
	clCity.move_out(zl.actorId)
	# 曹操所在城市
	var cityId = -1
	for city in clCity.all_cities():
		if CAOCAO in city.get_actor_ids():
			cityId = city.ID
	var city = clCity.city(cityId)
	DataManager.twinkle_citys = [WHERE, city.ID]
	var msg = "{0}与{1}暂时离开\n前往{2}".format([
		xs.get_name(), zl.get_name(), city.get_full_name(),
	])
	SceneManager.show_vstate_dialog(msg)
	LoadControl.set_view_model(2999)
	return
