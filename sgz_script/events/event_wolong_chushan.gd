extends "res://script/event_base.gd"

# 卧龙出山事件

const WHERE = StaticManager.CITY_ID_XINYE
const LONGZHONG = StaticManager.CITY_ID_XIANGYANG
const CAOCAO_CITIES = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,18,34]
const SUNQUAN_CITIES = [35,36,37,38,41]
const JINGZHOU_CITIES = [15,22,28,29,31,32,33]
const YIZHOU_CITIES = [21,23,24,25,26]
const JINGYI_CITIES = [15,22,28,29,31,32,33,21,23,24,25,26]

const WOLONG = StaticManager.ACTOR_ID_ZHUGELIANG
const LIUBEI = StaticManager.ACTOR_ID_LIUBEI
const GUANYU = StaticManager.ACTOR_ID_GUANYU
const ZHANGFEI = StaticManager.ACTOR_ID_ZHANGFEI

func _init():
	name = "wolong_chushan"
	timing = [20701]
	players = [LIUBEI]
	vstates = {
		StaticManager.VSTATEID_LIUBEI: LIUBEI,
	}
	cities = {
		WHERE: StaticManager.VSTATEID_LIUBEI,
	}
	actors = {
		LIUBEI: WHERE,
		# -2 表示为在野状态
		WOLONG: -2,
	}
	prevEvents = ["zilong_jiuxu"]
	dialogs = [
		["BLACK"],
		[WHERE, -2, "刘备骤失智囊\n又得徐庶力荐\n立刻便往隆中拜访卧龙", 2],
		[WHERE, -2, "然而两次扑空\n只得留下书信\n备言渴慕之情", 2],
		[WHERE, -2, "这一日，卜蓍得了吉期\n提前斋戒三日，熏沐更衣\n欲再往卧龙岗谒孔明", 2],
		[WHERE, -2, "关张以为卧龙无礼\n已有三分不悦，谏阻不得\n只得相随。三人来到庄前", 2],
		[LONGZHONG, LIUBEI, "有劳仙童转报\n刘备专来拜见先生", 1],
		[LONGZHONG, -1, "今日先生虽在家\n但现在草堂上昼寝未醒", 2],
		[LONGZHONG, LIUBEI, "既如此，且休通报\n云长翼德，门外静候\n我自堂下稍待", 1],
		[LONGZHONG, -2, "…… ……\n…… ……\n…… ……", 2],
		[LONGZHONG, -2, "良久，不见动静\n张飞入见玄德阶下侍立\n而先生高卧，不由大怒", 1],
		[LONGZHONG, ZHANGFEI, "这先生如何傲慢！\n等我去屋后放一把火\n看他起不起！", 0],
		[LONGZHONG, GUANYU, "翼德不可！\n兄长定然深责我等\n且看他究竟如何罢了", 0],
		[LONGZHONG, ZHANGFEI, "呶！！！\n…… ……", 0],
		[LONGZHONG, -2, "…… ……\n又立了一个时辰\n孔明总算醒来，口吟诗曰", 2],
		[LONGZHONG, WOLONG, "大梦谁先觉，平生我自知\n草堂春睡足，窗外日迟迟", 1],
		[LONGZHONG, -1, "先生，刘皇叔在此\n立候多时", 2],
		[LONGZHONG, WOLONG, "何不早报！尚容更衣", 2],
		[LONGZHONG, -2, "稍顷，孔明整衣冠出迎\n二人叙礼，分宾主而坐\n童子献茶罢，孔明开言道", 2],
		[LONGZHONG, WOLONG, "昨观书意\n足见将军忧民忧国之心\n但恨亮年幼才疏，有误下问", 2],
		[LONGZHONG, LIUBEI, "大丈夫抱经世奇才，岂可空老于林泉之下？愿先生以苍生为念，开备愚鲁而赐教", 2],
		[LONGZHONG, WOLONG, "愿闻将军之志", 1],
		[LONGZHONG, LIUBEI, "汉室倾颓，奸臣窃命，备不量力，欲伸大义于天下，而智术浅短，迄无所就", 2],
		[LONGZHONG, WOLONG, "自董卓造逆以來\n天下豪杰並起。", 2],
		[CAOCAO_CITIES, WOLONG, "曹操势不及袁绍，而竟能克绍者，非惟天時，抑亦人谋也。", 2],
		[CAOCAO_CITIES, WOLONG, "今操已拥百万之众\n挟天子以令诸侯\n此诚不可与争锋。", 2],
		[SUNQUAN_CITIES, WOLONG, "孙权据有江东，已历三世，国险而民附\n此可用为援，而不可图也", 2],
		[JINGZHOU_CITIES, WOLONG, "荆州北据汉、沔，利尽南海\n东连吴会，西通巴、蜀。", 2],
		[JINGZHOU_CITIES, WOLONG, "此用武之地，非其主不能守\n是殆天所以资将军，将军岂有意乎？", 2],
		[YIZHOU_CITIES, WOLONG, "益州险塞\n沃野千里，天府之国\n高祖因之以成帝业", 2],
		[YIZHOU_CITIES, WOLONG, "今刘璋暗弱\n民殷国富，而不知存恤\n智能之士，思得明君", 2],
		[LONGZHONG, WOLONG, "将军既帝室之胄\n信义著于四海\n总揽英雄，思贤如渴", 2],
		[JINGYI_CITIES, WOLONG, "若跨有荆、益，保其岩阻\n西和诸戎，南抚彝、越\n外结孙权，内修政理", 2],
		[JINGZHOU_CITIES, WOLONG, "待天下有变，则命一上将\n将荆州之兵以向宛、洛", 2],
		[YIZHOU_CITIES, WOLONG, "将军身率益州之众以出秦川\n百姓有不箪食壶浆以迎将军者乎？", 2],
		[LONGZHONG, WOLONG, "诚如是，则大业可成，汉室可兴矣。此亮所以为将军谋者也。惟将军图之", 2],
		[LONGZHONG, LIUBEI, "先生之言，顿开茅塞\n使备如拨云雾而睹青天。\n愿先生不弃鄙贱，出山相助", 1],
		[LONGZHONG, WOLONG, "亮久乐耕锄，懒于应世\n不能奉命", 2],
		[LONGZHONG, LIUBEI, "先生不出，如苍生何！", 3],
		[LONGZHONG, -2, "刘备言毕\n泪沾袍袖，衣襟尽湿\n孔明亦感其意甚诚", 2],
		[LONGZHONG, WOLONG, "将军既不相弃\n愿效犬马之劳", 1],
		[LONGZHONG, -2, "此谓隆中对也，后人叹曰：\n身未升腾思退步，\n功成应忆去时言。", 2],
		[LONGZHONG, -2, "只因先主丁宁后，\n星落秋风五丈原。", 2],
	]

	return

func event_settle()->void:
	var wolong = ActorHelper.actor(WOLONG)
	var xinye = clCity.city(WHERE)
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
