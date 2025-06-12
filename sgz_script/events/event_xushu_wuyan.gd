extends "res://script/event_base.gd"

# 曹操视角的徐庶进曹营事件

const XINYE = StaticManager.CITY_ID_XINYE

const XUSHU = StaticManager.ACTOR_ID_XUSHU
const CHENGYU = StaticManager.ACTOR_ID_CHENGYU
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const CAOCAO = StaticManager.ACTOR_ID_CAOCAO

func _init():
	name = "xushu_wuyan"
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
		XUSHU: XINYE,
	}
	prevEvents = []
	dialogs = [
		[-99, CHENGYU, "贺喜主公\n昱前日取得徐母手迹\n作书唤徐庶来此，已至矣", 1],
		[-99, XUSHU, "老母在堂，幸蒙顾念\n不胜愧感\n丞相恕罪，愿即往拜问", 2],
		[-99, -2, "曹操欢颜闲叙两句\n便放徐庶去拜老母\n孰料 ……", 2],
		[-99, -1, "辱子飘荡江湖数年\n吾以为汝学业有进\n何其反不如初也！", 0],
		[-99, -1, "汝既读书\n须知忠孝不能两全\n岂不识曹操欺君罔上之贼？", 0],
		[-99, -1, "刘玄德仁义布于四海\n况又汉室之冑\n汝既事之，得其主矣", 2],
		[-99, -1, "今凭一紙伪书，更不详察\n遂弃明投暗，自取恶名\n真愚夫也！", 2],
		[-99, -1, "吾有何面目与汝相见！\n汝玷辱祖宗\n空生于天地间耳！", 0],
		[-99, -2, "徐母一番痛骂，径入内室\n徐庶既惊且愧，拜伏于地\n不敢仰视", 0],
		[-99, -2, "少顷，内侍急报\n徐母竟自缢于梁\n徐庶闻言，哭绝于地", 0],
		[-99, -2, "曹操闻之亦为叹息\n好言抚慰，亲往祭奠\n徐庶居丧守墓，不受操所赐", 0],
	]
	return

func event_settle()->void:
	var cityId = DataManager.get_office_city_by_actor(CAOCAO)
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())
	var xs = ActorHelper.actor(XUSHU)
	clCity.move_out(xs.actorId)
	clCity.move_to(xs.actorId, cityId)
	xs.set_loyalty(40)
	DataManager.twinkle_citys = [XINYE, city.ID]
	var msg = "{0}转投{1}军\n出仕于{2}".format([
		xs.get_name(), vs.get_lord_name(), city.get_full_name(),
	])
	SceneManager.show_vstate_dialog(msg)
	LoadControl.set_view_model(2999)
	return
