extends "res://script/event_base.gd"

# 子龙救徐母事件-2

const XUSHU = StaticManager.ACTOR_ID_XUSHU
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const WOLONG = StaticManager.ACTOR_ID_ZHUGELIANG
const ZILONG = StaticManager.ACTOR_ID_ZHAOYUN

func _init():
	LoadControl.view_model_name = "玩家-事件"
	name = "zilong_jiuxu_2"
	timing = [20702]
	players = [LIUBEI]
	vstates = {
		StaticManager.VSTATEID_LIUBEI: LIUBEI,
	}
	cities = {
	}
	actors = {
		LIUBEI: -1,
		# -3 表示被禁用
		XUSHU: -3,
		ZILONG: -3,
	}
	prevEvents = ["zilong_jiuxu"]
	dialogs = [
		[-99, ZILONG, "主公，军师回来了！", 1],
		[-99, LIUBEI, "子龙！元直！\n吾望眼欲穿矣\n此行究竟如何？", 1],
		[-99, XUSHU, "主公明鉴，确是程昱使诈\n幸得子龙识破奸计\n又潜入许都，巧作安排", 2],
		[-99, XUSHU, "老母深责我临事糊涂\n子龙冒险搭救，一路护送\n今已脱离虎口。元直惭愧！", 3],
		[-99, WOLONG, "此人之常情尔，非元直之过\n元直若真绝情绝性之人\n不若真去投那曹操便了", 1],
		[-99, LIUBEI, "孔明所言是也\n尊母无恙，元直回返\n此天不弃我。当共庆之！", 1],
		[-99, -2, "是夜，宰羊治酒，众人皆贺\n赵云与徐庶俱大醉", 1],
	]

	return

func event_settle()->void:
	# 刘备所在城市
	var cityId = DataManager.get_office_city_by_actor(LIUBEI)
	var city = clCity.city(cityId)
	# 徐庶
	var xs = ActorHelper.actor(XUSHU)
	clCity.move_out(xs.actorId)
	xs.set_status_officed()
	city.add_actor(xs.actorId)
	xs.set_loyalty(99)
	# 赵云
	var zl = ActorHelper.actor(ZILONG)
	zl.set_status_officed()
	city.add_actor(zl.actorId)
	zl.set_loyalty(99)
	DataManager.twinkle_citys = [city.ID]
	var msg = "{0}与{1}回到{2}".format([
		xs.get_name(), zl.get_name(), city.get_full_name(),
	])
	SceneManager.show_vstate_dialog(msg)
	LoadControl.set_view_model(2999)
	return

