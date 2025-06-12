extends "effect_10000.gd"

#毒逝主动技·转换技
#【毒逝】内政，主动技。你非君主时，君主派人将汉少帝刘辩毒杀，并永久隐藏之，之后将君主德降为1点。若刘协未出仕，将其无视条件加入你方势力。你为君主时，失去本技能，并获得<天威>。

const EFFECT_ID = 10051
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const DIALOGS = [
	[1, "春日融和，陛下好闲情啊", 1],
	[0, "…… ……\n主公安否？必有要事？", 2],
	[1, "近日偶得好诗一首\n当与陛下共赏", 2],
	[1, "嫩草~绿凝烟，袅袅~双飞燕\n洛水~一条青，陌上~人称羡", 2],
	[1, "远望~碧云深，是吾~旧宫殿\n何人~仗忠义，泄我~\n心，中，怨！", 2],
	[0, "这 ……", 3],
	[1, "哼！好一个心中怨！", 0],
	[1, "天下动荡，臣等奋力维持\n尔不修德行，反生怨恨\n何颜苟活？请饮此杯！", 0],
	[0, "此……莫非鸩耶？", 3],
	[1, "陛下不饮，待谁灌之？", 2],
	[0, "罢了 …… ……\n天地易兮日月翻，\n弃万乘兮退守藩。", 2],
	[0, "为臣逼兮命不久，\n大势去兮空泪潸！", 3],
	[-1, "公元 <YEAR> 年 <MONTH> 月\n<NAME>毒杀<KING>\n（<NAME>德降为<MORAL>", 0],
	["flow", "play_affiars_animation|Town_Save||false|刘协加入我军"],
]
var dialogProcess = -1

func on_view_model_2000():
	if dialogProcess < 0:
		return
	if dialogProcess >= DIALOGS.size():
		LoadControl.set_view_model(2002)
		return
	var dialogInfo = DIALOGS[dialogProcess]
	if str(dialogInfo[0]) == "flow":
		FlowManager.add_flow(dialogInfo[1])
		LoadControl.set_view_model(2002)
		return
	if dialogInfo[0] == -1:
		SoundManager.play_bgm("res://resource/sounds/bgm/solo_dead.ogg", false, true, true)
	SceneManager.show_confirm_dialog(dialogInfo[1], dialogInfo[0], dialogInfo[2])
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	if not Global.is_action_pressed_AX():
		return
	if not SceneManager.dialog_msg_complete(true):
		return
	dialogProcess += 1
	LoadControl.set_view_model(2000)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func on_view_model_3000_delta(delta:float):
	var accumulated = DataManager.get_env_float("delta")
	DataManager.set_env("delta", accumulated + delta)
	if accumulated >= 2.0 * Engine.time_scale:
		LoadControl.set_view_model(-1)
		SceneManager.dialog_msg_complete(true)
		goto_step("AI_end")
		return
	wait_for_skill_result_confirmation(FLOW_BASE + "_AI_end")
	return

func check_AI_perform()->bool:
	actor = ActorHelper.actor(actorId)
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if city.get_lord_id() != StaticManager.ACTOR_ID_DONGZHUO:
		return false
	var taishi = ActorHelper.actor(StaticManager.ACTOR_ID_DONGZHUO)
	if taishi.is_face_positive() or taishi.get_moral() > 1:
		return false
	return true

func effect_10051_AI_start():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var taishi = ActorHelper.actor(StaticManager.ACTOR_ID_DONGZHUO)
	# 直接生效，不等对话结束
	# 禁用此技能
	ske.affair_cd(99999)
	# 永久禁用
	clCity.move_out(actorId)
	actor.set_status_disabled()
	taishi.set_moral(1)
	set_env("AI.毒杀少帝", city.get_vstate_id())

	var liuxie = ActorHelper.actor(StaticManager.ACTOR_ID_LIUXIE)
	var liuxieAppearance = false
	if not liuxie.is_status_officed():
		liuxie.set_status_officed()
		clCity.move_out(liuxie.actorId)
		clCity.move_to(liuxie.actorId, cityId)
		liuxieAppearance = true

	SoundManager.play_bgm("res://resource/sounds/bgm/GameDead_End.ogg", true, true, true)

	var vstateId = -1
	for p in DataManager.players:
		if p.actorId >= 0:
			vstateId = p.belong_To_vstateId()
			if vstateId >= 0:
				break

	# 没找到玩家
	if vstateId < 0:
		var msg = "{0}毒杀{1}"
		if liuxieAppearance:
			msg += "\n{2}出仕于{0}军"
		msg = msg.format([
			taishi.get_name(), actor.get_name(), liuxie.get_name(),
		])
		SceneManager.show_vstate_dialog(msg)
		DataManager.set_env("delta", 0)
		LoadControl.set_view_model(3000)
		return

	var reporter = DataManager.get_max_property_actorId("政", vstateId)
	var msg = "大事不好！\n董贼欺天废主，毒杀少帝！".format([
		DataManager.get_actor_naughty_title(taishi.actorId, reporter)
	])
	if liuxieAppearance:
		msg += "\n陈留王协，为贼挟制矣"
	SceneManager.show_confirm_dialog(msg, reporter, 0)
	DataManager.set_env("delta", 0)
	LoadControl.set_view_model(3000)
	return

func effect_10051_AI_end():
	SceneManager.hide_all_tool()
	var cityId = DataManager.get_env_int("AI.主动技当前城市")
	var city = clCity.city(cityId)
	var vs = clVState.vstate(city.get_vstate_id())
	var msg = "{0} 军 战略中".format([
		vs.get_dynasty_title_or_lord_name()
	])
	SceneManager.show_vstate_dialog(msg)
	DataManager.twinkle_citys = []
	LoadControl.end_script()
	FlowManager.add_flow("AI_active_skill")
	return

func effect_10051_start():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var currentKingActor = ActorHelper.actor(city.get_lord_id())
	
	if actorId == currentKingActor.actorId:
		LoadControl._error("不可")
		return

	# 直接生效，不等对话结束
	# 禁用此技能
	ske.affair_cd(99999)
	# 永久禁用
	clCity.move_out(actorId)
	actor.set_status_disabled()
	currentKingActor.set_moral(1)

	for dialogInfo in DIALOGS:
		match dialogInfo[0]:
			0:
				dialogInfo[0] = self.actorId
			1:
				dialogInfo[0] = currentKingActor.actorId
		dialogInfo[1] = dialogInfo[1].replace("<YEARS>", str(max(1, DataManager.year - 189)))
		dialogInfo[1] = dialogInfo[1].replace("<YEAR>", str(DataManager.year))
		dialogInfo[1] = dialogInfo[1].replace("<MONTH>", str(DataManager.month))
		dialogInfo[1] = dialogInfo[1].replace("<KING>", actor.get_name())
		dialogInfo[1] = dialogInfo[1].replace("<NAME>", currentKingActor.get_name())
		dialogInfo[1] = dialogInfo[1].replace("<MORAL>", currentKingActor.get_moral())
	self.dialogProcess = 0
	SceneManager.hide_all_tool()
	LoadControl.set_view_model(2000)
	SoundManager.play_bgm("res://resource/sounds/bgm/GameDead_End.ogg", true, true, true)
	return

func effect_10051_2():
	var liuxie = ActorHelper.actor(StaticManager.ACTOR_ID_LIUXIE)
	if liuxie.is_status_officed():
		FlowManager.add_flow("player_ready")
		return
	liuxie.set_status_officed()
	clCity.move_out(liuxie.actorId)
	clCity.move_to(liuxie.actorId, DataManager.player_choose_city)
	FlowManager.add_flow("player_ready")
	return

# 被动效果，检查是否转换技能
func check_trigger_correct()->bool:
	for vs in clVState.all_vstates():
		if vs.get_lord_id() == self.actorId:
			SkillHelper.ban_actor_skill(10000, self.actorId, "毒逝", 99999)
			SkillHelper.add_actor_scene_skill(10000, self.actorId, "天威", 99999)
			break
	return false
