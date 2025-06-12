extends "res://script/event_base.gd"

# 徐庶奔曹事件

const WHERE = StaticManager.CITY_ID_XINYE
const XUSHU = StaticManager.ACTOR_ID_XUSHU
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const CAOCAO = StaticManager.ACTOR_ID_CAOCAO

func _init():
	LoadControl.view_model_name = "玩家-事件"
	name = "xushu_bencao"
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
		# -1 表示在哪里都可以，寻找并更新其所在
		CAOCAO: -1,
	}
	dialogs = [
		[WHERE, -1, "报！许昌来人寻军师\n说道奉了老夫人言语\n有书附达", 2],
		[WHERE, XUSHU, "许昌来人？书信将来！\n\n（急忙展信阅看……", 2],
		[WHERE, -2, "（书信写道：\n…… ……\n近汝弟康喪，舉目無親", 2],
		[WHERE, -2, "…… ……\n不期曹丞相使人賺至許昌\n…… ……", 2],
		[WHERE, -2, "賴程昱等救免\n若得汝來降，能免我死\n…… ……", 2],
		[WHERE, -2, "…… ……\n吾今命若懸絲，專望救援！\n更不多囑", 2],
		[WHERE, XUSHU, "！！！\n这…… 竟作出此等手段！", 0],
		[WHERE, -2, "徐庶心乱如麻\n思虑再三，竟无措置\n只得去寻玄德", 2],
		[WHERE, XUSHU, "主公明鉴！庶本无用之人\n作狂歌于市，以动使君\n幸蒙不弃，即赐重用", 2],
		[WHERE, XUSHU, "争奈老母，今被曹操奸计\n賺至許昌囚禁，将欲加害\n老母手书来唤，庶不容不去", 3],
		[WHERE, LIUBEI, "母子天性之亲，岂能不顾！\n元直无以备为念\n救得老夫人，或者再得奉教", 3],
		["BLACK"],
		[WHERE, -2, "二人相对而泣，坐以待旦\n…… ……\n翌日辞别，刘备送至长亭", 2],
		[WHERE, LIUBEI, "备分浅缘薄\n不能与先生相聚\n望先生善事新主，以成功名", 3],
		[WHERE, XUSHU, "某才微智浅，深荷使君重用\n今不幸半途而別\n纵曹操相迫，庶亦不設一謀", 2],
		[WHERE, -2, "送了一程，又送了一程\n徐庶拜别，刘备泪如雨下", 2],
		#["BLACK"],
		[WHERE, -2, "…… ……\n…… ……\n…… ……", 2],
		[WHERE, -2, "忽见徐庶拍马而回\n玄德大喜", 2],
		[WHERE, LIUBEI, "先生此回，必有主意？", 1],
		[WHERE, XUSHU, "某心绪如麻，忘却大事\n襄阳有奇士，只在隆中\n使君亲求之，切勿屈致", 2],
		[WHERE, LIUBEI, "愿闻此人姓名？\n才德可比得先生？", 2],
		[WHERE, XUSHU, "此人乃琅琊阳都人\n复姓诸葛，名亮，字孔明\n才堪经天纬地，天下一人也", 2],
		[WHERE, LIUBEI, "昔水镜先生曾为备言：\n伏龙凤雏，得一可安天下\n今所云莫非即伏龙凤雏乎？", 2],
		[WHERE, XUSHU, "凤雏乃襄阳庞统\n伏龙正是诸葛孔明", 2],
		[WHERE, LIUBEI, "何期大贤只在目前。\n非先生言，备有眼如盲也！", 1],
		[WHERE, -2, "徐庶走马荐诸葛\n再拜而别\n后人诗赞曰：", 2],
		[WHERE, -2, "痛恨高贤不再逢，\n临岐泣別兩情浓。", 2],
		[WHERE, -2, "片言却似春雷震，\n能使南阳起卧龙。", 2],
		#["BLACK"],
	]
	return

func event_settle()->void:
	# 这里不作任何实际处理
	# 因为要看后续事件，子龙救徐母的不同分支
	event_finish()
	return
