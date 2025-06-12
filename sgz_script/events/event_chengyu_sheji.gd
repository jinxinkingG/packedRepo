extends "res://script/event_base.gd"

# 程昱设计事件
# 曹操视角的徐庶进曹营，前置事件

const XINYE = StaticManager.CITY_ID_XINYE

const XUSHU = StaticManager.ACTOR_ID_XUSHU
const CHENGYU = StaticManager.ACTOR_ID_CHENGYU
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const CAOCAO = StaticManager.ACTOR_ID_CAOCAO
const CAOREN = StaticManager.ACTOR_ID_CAOREN

func _init():
	name = "chengyu_sheji"
	timing = [20612]
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
		[-99, CAOREN, "前月新野，我等初战不利\n遭刘备连番诡计，损兵折将\n请主公发落！", 3],
		[-99, CAOCAO, "胜败乃兵家之常\n但不知谁为刘备划策？", 2],
		[-99, CAOREN, "刘备新得军师，姓单名福\n据闻言听计从\n破我八门金锁阵，着实厉害", 2],
		[-99, CHENGYU, "此非单福也\n实颍川人士\n姓徐名庶字元直", 1],
		[-99, CHENGYU, "幼好击剑，尝为人报仇杀人\n更名避祸，折节向学\n遍访名师，尝与司马徽谈论", 2],
		[-99, CAOCAO, "徐庶之才，比君何如？", 2],
		[-99, CHENGYU, "十倍于昱", 2],
		[-99, CAOCAO, "惜乎贤士归于刘备！\n羽翼成矣，奈何？", 0],
		[-99, CHENGYU, "徐庶虽在彼\n丞相要用，召來不难", 2],
		[-99, CHENGYU, "徐庶为人至孝\n幼丧其父，弟康新丧\n止有老母在堂，无人侍养", 2],
		[-99, CHENGYU, "丞相可使人赚其母至此\n令作书召其子\n则徐庶必至矣", 2],
		[-99, -2, "曹操闻言大喜\n星夜使人前去\n依计行事 ……", 2],
		["BLACK"],
		[-99, CAOCAO, "老母车马劳苦\n闻令嗣徐元直，天下奇才也\n今助逆臣刘备 ……", 1],
		[-99, CAOCAO, "美玉落于淤泥，诚为可惜\n今烦老母作书，唤回许都\n吾保奏于天子，必有重赏", 1],
		[-99, -1, "吾久闻玄德乃中山靖王之后\n屈身下士，恭己待人\n仁声素著，真当世之英雄也", 2],
		[-99, -1, "吾儿辅之，得其主矣\n汝托名汉相，实为汉贼\n欲使吾儿背明投暗 ……", 0],
		[-99, -1, "岂不自耻乎！！！", 0],
		[-99, -2, "徐母言毕，竟取砚石便打\n曹操大怒，便欲斩之\n程昱急止，将徐母别室养之", 2],
		[-99, CHENGYU, "丞相勿忧，且留得徐母在\n昱自有计赚徐庶至此\n以辅丞相", 1],
		["BLACK"],
	]
	return

func event_settle()->void:
	event_finish()
	return
