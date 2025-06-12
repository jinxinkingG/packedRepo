extends "res://script/event_base.gd"

# 潜龙出渊事件
# 即其他君主眼中的徐庶奔曹和卧龙出山事件

const XINYE = StaticManager.CITY_ID_XINYE
const LONGZHONG = StaticManager.CITY_ID_XIANGYANG
const WHERE = [XINYE, LONGZHONG]

const WOLONG = StaticManager.ACTOR_ID_ZHUGELIANG
const XUSHU = StaticManager.ACTOR_ID_XUSHU
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const CAOCAO = StaticManager.ACTOR_ID_CAOCAO

func _init():
	name = "qianlong_chuyuan"
	timing = [20701]
	excludedPlayers = [LIUBEI, CAOCAO]
	vstates = {
		StaticManager.VSTATEID_LIUBEI: LIUBEI,
		StaticManager.VSTATEID_CAOCAO: CAOCAO,
	}
	cities = {
		XINYE: StaticManager.VSTATEID_LIUBEI,
	}
	actors = {
		LIUBEI: XINYE,
		XUSHU: XINYE,
		# -2 表示为在野状态
		WOLONG: -2,
	}
	prevEvents = []
	dialogs = [
		[WHERE, -1, "探报！\n新野刘备，新得军师诸葛亮\n出入不离，主臣甚欢", 2],
		[WHERE, -99, "刘玄德方得徐元直\n如何又换了军师？", 2],
		[WHERE, -1, "徐庶奉得母命\n已是投曹操去了\n临行前荐了诸葛亮", 2],
		[-99, -99, "未知这诸葛亮 ……\n何许人也？", 2],
		[-99, -90, "主公，这诸葛亮，字孔明\n琅琊人士，躬耕于南阳\n素与徐庶等人游学", 2],
		[-99, -90, "荆州寒士之间，颇有名气\n徐元直曾言\n孔明之才，百倍于之", 2],
		[-99, -99, "百倍之言，莫非太过\n徐元直欺刘玄德不知人邪？", 2],
		[-99, -90, "徐庶等人治学，务求精要\n孔明独观其大略\n传闻其人尝以管仲乐毅自比", 2],
		[-99, -99, "乱世英雄辈出\n岂有大才隐世不出之理\n谅一村夫尔，大言不惭！", 2],
	]
	return

func event_settle()->void:
	# 曹操所在城市
	var cityId = DataManager.get_office_city_by_actor(CAOCAO)
	var city = clCity.city(cityId)
	var xushu = ActorHelper.actor(XUSHU)
	clCity.move_out(xushu.actorId)
	clCity.move_to(xushu.actorId, city.ID)
	xushu.set_loyalty(40)
	var wolong = ActorHelper.actor(WOLONG)
	var xinye = clCity.city(XINYE)
	clCity.move_out(wolong.actorId)
	clCity.move_to(wolong.actorId, xinye.ID)
	wolong.set_status_officed()
	wolong.set_soldiers(1000)
	wolong.set_loyalty(99)
	DataManager.twinkle_citys = [xinye.ID, city.ID]
	var msg = "{0}转投{1}\n{2}出仕于{3}".format([
		xushu.get_name(), city.get_full_name(),
		wolong.get_name(), xinye.get_full_name(),
	])
	SceneManager.show_vstate_dialog(msg)
	LoadControl.set_view_model(2999)
	return
