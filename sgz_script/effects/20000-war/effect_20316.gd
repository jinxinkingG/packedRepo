extends "effect_20000.gd"

#赋诗升级触发效果
#【赋诗】大战场，主将锁定技。你方武将升级时，经验+2000。且你方8级武将获得的经验+10%

const EXP_GAIN = 2000
const POEMS = {
	StaticManager.ACTOR_ID_CAOCAO: [
		"老骥伏枥，志在千里",
		"日月之行，若出其中",
		"星汉灿烂，若出其里",
		"山不厌高，海不厌深",
		"北上太行山，艰哉何巍巍",
		"兼爱尚同，疏者为戚",
	],
	StaticManager.ACTOR_ID_CAOPI: [
		"星汉西流夜未央",
		"忧来思君不敢忘",
		"烈烈北风凉",
		"高山有崖，林木有枝",
		"别日何易会日难",
		"俯视清水波，仰看明月光",
		"展诗清歌仰自宽",
		"谁云江水广，一苇可以航",
	],
	StaticManager.ACTOR_ID_CAOZHI: [
		"捐躯赴国难，视死忽如归",
		"丈夫志四海，万里犹比邻",
		"高树多悲风，海水扬其波",
		"八方各异气，千里殊风雨",
		"仰手接飞猱，俯身散马蹄",
		"谦谦君子德，磬折欲何求",
	],
	-1: [
		"好生厉害！",
		"炸裂啊！",
		"这不起飞咯啊！",
	],
}

func check_trigger_correct()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	var targetActor = ActorHelper.actor(ske.actorId)

	ske.change_actor_exp(ske.actorId, EXP_GAIN)
	ske.war_report()

	var msg = "{0}\n{1}当再接再厉\n（{2}经验增加{3}".format([
		get_poem(me.actorId), DataManager.get_actor_honored_title(ske.actorId, me.actorId),
		targetActor.get_name(), EXP_GAIN,
	])
	# 为了对话有序，需要加到升级武将身上
	wa.attach_free_dialog(msg, 1, 20000, actorId)
	return false

func get_poem(fromId:int)->String:
	if not POEMS.has(fromId):
		fromId = -1
	var poems = POEMS[fromId].duplicate()
	poems.shuffle()
	return poems[0]
