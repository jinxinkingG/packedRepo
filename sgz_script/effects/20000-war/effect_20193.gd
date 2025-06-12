extends "effect_20000.gd"

#逢亮效果2实现，被笼络
#【逢亮】大战场,锁定技。你转移阵营或被俘虏时，若转移后的阵营不是你的战争初始势力，并有忠>90的诸葛亮在场，你永久转为<阳>面，且忠变为99。

const CALLBACK_SCRIPT = "effects/20000-war/effect_20193.gd"
const CALLBACK_METHOD = "progress"

const ZHIJI_EFFECT_ID = 20213

const DIALOGS = [
	["今得伯约，如得一凤\n吾愿足矣\n", StaticManager.ACTOR_ID_ZHUGELIANG, 1],
	["唯先生知姜维！\n维亦知先生之志", 999, 2],
	["愿追随先生左右\n但有远志，不在当归！\n", 999, 0],
	["姜维转为<阳>\n追随孔明，加入<VSTATE>军", -1, 2],
]

func on_trigger_20008()->bool:
	# 战后
	if me == null or me.disabled:
		return false
	return _something_happened()

func on_trigger_20012()->bool:
	# 计策后
	if me == null or me.disabled:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.name != "笼络":
		return false
	if se.targetId != actorId:
		return false
	if se.succeeded <= 0:
		return false
	return _something_happened()

func _something_happened()->bool:
	if not me.changed_vstate():
		return false
	if actor.is_face_positive():
		return false
	if actor.is_status_captured():
		return false

	# 找诸葛亮
	var sleepingDragon = me.war_vstate().get_war_actor(StaticManager.ACTOR_ID_ZHUGELIANG)
	if sleepingDragon == null or sleepingDragon.disabled or not sleepingDragon.has_position():
		return false
	if sleepingDragon.actor().get_loyalty() <= 90:
		return false

	var msg = "吾自出茅庐，遍求贤者\n欲传平生之学，未得其人"
	var d = me.attach_free_dialog(msg, 2, 20000, sleepingDragon.actorId)
	d.callback_script = CALLBACK_SCRIPT
	d.callback_method = CALLBACK_METHOD
	return false

func progress():
	me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		DataManager.unset_env("逢亮.事件")
		return
	var progress = DataManager.get_env_int("逢亮.事件", 0)
	if progress >= DIALOGS.size():
		DataManager.unset_env("逢亮.事件")
		done()
		return
	var dialog = DIALOGS[progress]
	DataManager.set_env("逢亮.事件", progress + 1)
	var msg = dialog[0].replace("<VSTATE>", me.get_lord_name())
	var speaker = dialog[1]
	if speaker == 999:
		speaker = me.actorId
	var d = me.attach_free_dialog(msg, dialog[2], 20000, speaker)
	d.callback_script = CALLBACK_SCRIPT
	d.callback_method = CALLBACK_METHOD
	return

func done():
	me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return
	var wv = me.war_vstate()
	if wv == null:
		return
	var sleepingDragon = wv.get_war_actor(StaticManager.ACTOR_ID_ZHUGELIANG)
	if sleepingDragon == null or sleepingDragon.disabled or not sleepingDragon.has_position():
		return
	# 从俘虏营中移除
	if wv.capture_actors.has(me.actorId):
		wv.capture_actors.erase(me.actorId)
	# 转面
	var actor = me.actor()
	if actor.is_face_positive():
		return
	actor.set_face(true)
	actor.set_loyalty(min(99, sleepingDragon.actor().get_loyalty()))
	actor.set_soldiers(500)
	actor.set_status_officed()
	# 出战
	me = wv.camp_out(me.actorId)
	# 设置位置
	var iembattle = Global.load_script(DataManager.mod_path+"sgz_script/war/IEmbattle.gd")
	iembattle.set_default_actor_embattle(me)
	var map = SceneManager.current_scene().war_map
	map.draw_actors()
	map.set_cursor_location(me.position, true)
	SceneManager.show_actor_info(me.actorId)
	
	if not SkillHelper.actor_has_skills(actorId, ["志继"]):
		return

	var dic = {
		"current_actor": me.actorId,
		"effect_id": ZHIJI_EFFECT_ID,
		"triggerId": -1,
		"skill_name": "志继",
		"skill_actor": me.actorId,
	}
	var st = SkillTriggerInfo.new()
	st.induce_dialog = ""
	st.actorId = actorId
	st.triggerId = -1
	st.lock_effects = [dic]
	st.induce_effects = []
	st.next_flow = "player_ready"
	if DataManager.get_scene_actor_control(actorId) < 0:
		st.next_flow = "AI_before_ready"
	SkillHelper.add_skill_triggerinfo(st)
	return
