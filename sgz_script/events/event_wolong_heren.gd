extends "res://script/event_base.gd"

# 曹操视角的卧龙出山事件

const XINYE = StaticManager.CITY_ID_XINYE

const XUSHU = StaticManager.ACTOR_ID_XUSHU
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const CAOCAO = StaticManager.ACTOR_ID_CAOCAO
const WOLONG = StaticManager.ACTOR_ID_ZHUGELIANG

func _init():
	name = "wolong_heren"
	timing = [20701]
	players = [CAOCAO]
	vstates = {
		StaticManager.VSTATEID_LIUBEI: LIUBEI,
		StaticManager.VSTATEID_CAOCAO: CAOCAO,
	}
	cities = {
		XINYE: StaticManager.VSTATEID_LIUBEI,
	}
	actors = {
		LIUBEI: XINYE,
		WOLONG: -2,
	}
	prevEvents = ["xushu_wuyan"]
	dialogs = [
		["BLACK"],
		[-99, -2, "旬日之间，探子来报\n刘备请得诸葛亮出山\n拜为军师", 2],
		[-99, CAOCAO, "诸葛亮何人也？\n元直尝居荆襄，想必知之？", 2],
		[-99, XUSHU, "亮字孔明，道号卧龙先生\n有经天纬地之才\n出鬼入神之计", 3],
		[-99, CAOCAO, "比公若何？", 2],
		[-99, XUSHU, "庶安敢比亮？\n庶如萤火之光\n亮乃皓月之明也", 3],
	]
	return

func event_settle()->void:
	var wolong = ActorHelper.actor(WOLONG)
	var xinye = clCity.city(XINYE)
	clCity.move_out(wolong.actorId)
	clCity.move_to(wolong.actorId, xinye.ID)
	wolong.set_status_officed()
	wolong.set_soldiers(1000)
	wolong.set_loyalty(99)
	DataManager.twinkle_citys = [xinye.ID]
	var msg = "{0}出仕于{1}".format([
		wolong.get_name(), xinye.get_full_name(),
	])
	SceneManager.show_vstate_dialog(msg)
	LoadControl.set_view_model(2999)
	return
