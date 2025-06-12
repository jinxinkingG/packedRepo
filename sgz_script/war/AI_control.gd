extends Resource

const view_model_name = "战争-AI-步骤"
const VAR_END_ACTOR = "AI-停止武将"
const VAR_CUR_ACTOR = "AI-当前武将"

var wab;

var iembattle;

var temp_time:int = 0;

func get_view_model():
	if(!DataManager.common_variable.has(view_model_name)):
		return -1;
	return int(DataManager.common_variable[view_model_name]);

func set_view_model(view_model:int):
	DataManager.common_variable[view_model_name] = int(view_model);


func _init() -> void:
	match DataManager.diffculities:
		3:
			wab = Global.load_script(DataManager.mod_path+"sgz_script/war/AI/War_AI_behavior_hard.gd")
		4:
			wab = Global.load_script(DataManager.mod_path+"sgz_script/war/AI/War_AI_behavior_ng.gd")
		_:
			wab = Global.load_script(DataManager.mod_path+"sgz_script/war/AI/War_AI_behavior_new.gd")
	iembattle = Global.load_script(DataManager.mod_path+"sgz_script/war/IEmbattle.gd")
	FlowManager.bind_import_flow("AI_auto_embattle" ,self)
	FlowManager.bind_import_flow("AI_before_ready", self)
	FlowManager.bind_import_flow("AI_ready", self)
	FlowManager.bind_import_flow("AI_end", self)
	FlowManager.bind_import_flow("AI_turn_dialog", self)
	return

#自动布阵
func AI_auto_embattle():
	var wvId = DataManager.get_env_int("布阵方")
	var wf = DataManager.get_current_war_fight()
	var wv = wf.get_war_vstate(wvId)
	var embattled = 0
	var candidates = []
	for wa in wv.get_war_actors(false, false):
		if wa.has_position() or wa.get_ext_variable("跳过布阵", 0) == 1:
			continue
		candidates.append(wa)
	if DataManager.diffculities >= 4 and candidates.size() > 1:
		# 挑战难度下，防守方优化布阵
		var leader = candidates.pop_front()
		# 主将不变，其他人按战斗力排序
		candidates.sort_custom(Global.actorComp, "by_power")
		candidates.insert(0, leader)
	for wa in candidates:
		iembattle.set_default_actor_embattle(wa)
		embattled += 1
	FlowManager.add_flow("draw_actors")
	wv.embattled = 1
	FlowManager.add_flow("check_embattle")
	set_view_model(0)
	return

#AI回合开始
func AI_before_ready():
	#检查是否升级
	_check_actors_levelup()
	if _check_wait_dialog():
		set_view_model(-1)
		FlowManager.add_flow("AI_turn_dialog")
		return
	# 确认是否有势力战败
	if check_war_vstates_status():
		FlowManager.add_flow("war_vstate_settlement")
		return
	LoadControl.end_script()
	set_view_model(1)
	var war_map = SceneManager.current_scene().war_map
	war_map.next_shrink_actors = []
	war_map.show_scheme_selector(null)
	temp_time = Time.get_ticks_usec()
	
	var endActors = DataManager.get_env_int_array(VAR_END_ACTOR)
	
	SceneManager.hide_all_tool()
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	if wv.get_main_controlNo() >= 0:
		FlowManager.add_flow("player_before_ready")
		return

	var actorId = wab.next_behavior_actor(wv)
	var wa = DataManager.get_war_actor(actorId)
	DataManager.set_env(VAR_CUR_ACTOR, actorId)
	
	if wa == null or wa.disabled or not wa.has_position():
		endActors.append(actorId)

	if endActors.has(actorId) or wa.wvId != wv.id:
		var allEnded = true
		for w in wv.get_war_actors(false, true):
			if w.actorId in endActors:
				continue
			actorId = w.actorId
			allEnded = false
			break
		if allEnded:
			FlowManager.add_flow("AI_end")
			return
	DataManager.set_env(VAR_CUR_ACTOR, actorId)
	DataManager.player_choose_actor = actorId

	FlowManager.add_flow("AI_ready")
	return

#检查武将升级，并插入闲时对话
func _check_actors_levelup():
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false):
		# 如果升级了，再检查一次
		# 因为可能有连续升级，比如技能【赋诗】的影响
		if _check_actor_levelup(wa):
			_check_actor_levelup(wa)
	return

func _check_actor_levelup(wa:War_Actor)->bool:
	var actor = ActorHelper.actor(wa.actorId)
	var history = actor.get_levelup_trackings()
	if history.empty():
		return false
	var leader = DataManager.get_war_actor(wa.get_main_actor_id())
	if leader == null:
		return false
	for record in actor.get_levelup_trackings():
		var msgs = []
		msgs.append("{0}升至{1}级，体力回满".format([
			actor.get_name(), record["level"],
		]))
		for attr in record["attrs"]:
			var msg = "【{0}】提升至{1}".format([attr, record["attrs"][attr][1]])
			msgs.append(msg)
		for skill in record["skills"]:
			msgs.append("解锁新技能：【{0}】".format([skill]))
		for from in range(0, msgs.size(), 3):
			var to = min(from + 3, msgs.size()) - 1
			var msg = "\n".join(msgs.slice(from, to))
			var d = leader.attach_free_dialog(msg, 1)
			d.se = "res://resource/sounds/se/LevelUp.ogg"
	# 升级体力回满
	# 不放在 actor.check_levelup() 里
	# 避免小战场直接回满了
	actor.set_hp(actor.get_max_hp())
	actor.reset_levelup_trackings()
	# 不支持 flow，可插入闲时对话
	SkillHelper.auto_trigger_skill(actor.actorId, 20033, "")
	return true

func AI_ready():
	set_view_model(2);
	_check_actors_levelup()
	if _check_wait_dialog():
		set_view_model(-1)
		FlowManager.add_flow("AI_turn_dialog")
		return
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	# 确认是否有势力战败
	if check_war_vstates_status():
		FlowManager.add_flow("war_vstate_settlement")
		return
	# 如果有技能未完成，等待技能结束
	var st = SkillHelper.get_current_skill_trigger()
	if st != null and st.wait:
		return
	#DataManager.game_trace("")
	#AI行动逻辑入口
	wab.behavior(wv.id)
	#DataManager.game_trace("== AI BEHAVIOR #{0}".format([
	#	DataManager.get_env_int(VAR_CUR_ACTOR)
	#]))
	return

func AI_turn_dialog():
	var data = DataManager.get_env_dict("战争.AI.等待对白")
	if data.empty():
		FlowManager.add_flow("AI_before_ready")
		return
	var d = War_Character.DialogInfo.new()
	d.input(data)
	DataManager.unset_env("战争.AI.等待对白")
	if d.se != "":
		SoundManager.play_anim_bgm(d.se)
	if d.callback_script != "" and d.callback_method != "":
		var sc = Global.load_script("res://resource/sgz_script/" + d.callback_script)
		if sc.has_method(d.callback_method):
			sc.actorId = d.actorId
			var fromId = DataManager.get_env_int("战争.AI.等待对白来源")
			if fromId >= 0:
				sc.actorId = fromId
			DataManager.unset_env("战争.AI.等待对白来源")
			if sc.call(d.callback_method):
				return
	var map = SceneManager.current_scene().war_map
	map.camer_to_actorId(d.actorId, "")
	SceneManager.show_confirm_dialog(d.text, d.actorId, d.mood)
	map.next_shrink_actors = [d.actorId]
	set_view_model(3)
	return

func AI_end():
	wab.AI_end()
	set_view_model(-1)
	DataManager.unset_env(VAR_CUR_ACTOR)
	DataManager.unset_env(VAR_END_ACTOR)
	DataManager.game_trace("AI回合共需时间："+ str((Time.get_ticks_usec()-temp_time)/1000.0))
	LoadControl.end_script()
	var wf = DataManager.get_current_war_fight()
	var wv = wf.current_war_vstate()
	# 这里不检查是否战败，交给其他控制方
	wv.prepare_war_actors()
	FlowManager.add_flow("turn_control_end")
	return

func _process(delta:float)->void:
	wab._input_key(delta);
	var vm = get_view_model()
	match vm:
		3: # 等待闲时对话
			Global.wait_for_confirmation("AI_before_ready", view_model_name)
	return

#检查空闲对白
func _check_wait_dialog():
	var wf = DataManager.get_current_war_fight()
	for wa in wf.get_war_actors(false):
		while not wa.wait_dialogs.empty():
			var d = wa.wait_dialogs.pop_front()
			if d.sceneId >= 30000:
				# 小战场或单挑的对话，忽略并丢弃
				continue
			DataManager.set_env("战争.AI.等待对白", d.output())
			DataManager.set_env("战争.AI.等待对白来源", wa.actorId)
			return true
	return false

func check_war_vstates_status()->bool:
	var wf = DataManager.get_current_war_fight()
	var somethingHappened = false
	for wv in wf.war_vstates():
		#调用自动检查失败条件程序
		wv.check_lose()
		# 需要结算
		if wv.requires_lost_settlement():
			somethingHappened = true
	# 主要势力失败?
	if wf.defenderWV.lost() or wf.attackerWV.lost():
		somethingHappened = true
	return somethingHappened
