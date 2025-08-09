extends "effect_10000.gd"

#腾龙主动技
#【腾龙】内政,主动技。发动后，刘协自动成为君主，原君主变为99忠的武将，且德+50

const EFFECT_ID = 10026
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const DIALOGS = [
	[1, "陛下...", 3],
	[0, "公有心事？何妨明言", 2],
	[1, "臣当直言，陛下恕罪\n天下动乱，汉室衰微久矣\n人皆言火德衰微，天数有变", 2],
	[1, "然 <YEARS> 年来，忠志之士忘身于外者，实欲抚平板荡\n有以报之于陛下也", 2],
	[1, "天幸陛下神武\n汉室中兴有望矣", 2],
	[1, "臣等愿归政于陛下\n随陛下扫平乱党\n恢复太平治世！", 0],
	[0, "<NICK>何出此言\n若无卿在，天下…\n不知几人称帝，几人称王", 3],
	[0, "<NICK>忠勤王事，朕深知之\n朕德才不足，还政之事\n请勿复言", 2],
	[1, "臣世受国恩，庸庸碌碌\n若不能见陛下龙腾\n何颜见祖宗于地下！", 0],
	[3, "陛下，臣等公议如此\n绝无二心！\n望陛下亲政！", 2],
	[2, "违陛下旨意者\n天下共诛之！\n望陛下亲政！", 2],
	[4, "不服王化之徒\n臣等旦夕剿灭！\n望陛下亲政！", 2],
	[0, "……", 2],
	["flow", FLOW_BASE + "_now"],
	[0, "既如此，朕当振作", 2],
	[0, "列祖列宗在上\n不肖子协有言", 2],
	[0, "天下动荡至今，协一无作为\n致使汉业衰微，社稷蒙难", 3],
	[0, "今幸忠臣尚在\n天不亡我大汉\n协誓还万民以太平！", 0],
	[-1, "公元 <YEAR> 年 <MONTH> 月\n<NAME>等人还政于<KING>\n奉天子以讨不臣", 0],
	["flow", "play_affiars_animation|Town_Save||false"],
]
var dialogProcess = -1

func effect_10026_start() -> void:
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	var currentKingId = clVState.vstate(vstateId).get_lord_id()
	var currentKingActor = ActorHelper.actor(currentKingId)
	
	if actorId == currentKingId:
		var msg = "陛下何故谋反？"
		play_dialog(actorId, msg, 3, 2999)
		return

	# 寻找群众演员
	var otherActorIds = {}
	var excepted = [actorId]
	for prop in ["德", "知", "武"]:
		var found = DataManager.get_max_property_actorId(prop, vstateId, excepted)
		if found < 0:
			otherActorIds[prop] = currentKingId
		else:
			excepted.append(found)
			otherActorIds[prop] = found

	# 直接生效，不等对话结束
	# 禁用此技能
	ske.affair_cd(99999)
	# 如果是阴面，转为阳面，这个逻辑主要是为了刘协
	if actor.is_face_positive():
		actor.set_face(true)
	# 改变忠诚度
	actor.set_loyalty(100)
	currentKingActor.set_loyalty(99)
	currentKingActor.set_moral(min(99, currentKingActor.get_moral() + 50))
	for _actorId in otherActorIds.values():
		ActorHelper.actor(_actorId).set_loyalty(99)
	# 改变势力君主
	vstateId = DataManager.lord_change(vstateId, actorId)
	# 改变玩家控制
	DataManager.players[FlowManager.controlNo].set_actor(actorId)
	# 改变太守
	city.remove_actor(actorId)
	city.insert_actor(0, actorId)

	for dialogInfo in DIALOGS:
		match dialogInfo[0]:
			0:
				dialogInfo[0] = actorId
			1:
				dialogInfo[0] = currentKingId
			2:
				dialogInfo[0] = otherActorIds["德"]
			3:
				dialogInfo[0] = otherActorIds["知"]
			4:
				dialogInfo[0] = otherActorIds["武"]
		dialogInfo[1] = dialogInfo[1].replace("<YEARS>", str(max(1, DataManager.year - 189)))
		dialogInfo[1] = dialogInfo[1].replace("<YEAR>", str(DataManager.year))
		dialogInfo[1] = dialogInfo[1].replace("<MONTH>", str(DataManager.month))
		dialogInfo[1] = dialogInfo[1].replace("<KING>", actor.get_name())
		dialogInfo[1] = dialogInfo[1].replace("<NAME>", currentKingActor.get_name())
		var nick = DataManager.get_actor_honored_title(currentKingId, actorId)
		dialogInfo[1] = dialogInfo[1].replace("<NICK>", nick)

	dialogProcess = 0
	SceneManager.hide_all_tool()
	LoadControl.set_view_model(2000)
	SoundManager.play_bgm("res://resource/sounds/bgm/GameHappy_End.ogg", true, true, true)
	return

func on_view_model_2000()->void:
	if dialogProcess < 0:
		return
	if dialogProcess >= DIALOGS.size():
		LoadControl.set_view_model(2999)
		return
	var dialogInfo = DIALOGS[dialogProcess]
	if str(dialogInfo[0]) == "flow":
		LoadControl.set_view_model(-1)
		FlowManager.add_flow(dialogInfo[1])
	else:
		SceneManager.show_confirm_dialog(dialogInfo[1], dialogInfo[0], dialogInfo[2])
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	dialogProcess += 1
	LoadControl.set_view_model(2000)
	return

func effect_10026_now() -> void:
	dialogProcess += 1
	actor.set_side("阳")
	LoadControl.set_view_model(2000)
	return
