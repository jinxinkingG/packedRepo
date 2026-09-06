extends Resource

const VIEW_MODEL_NAME = "单挑-玩家-步骤"

func get_view_model() -> int:
	return DataManager.get_env_int(VIEW_MODEL_NAME)

func set_view_model(vm:int) -> void:
	DataManager.set_env(VIEW_MODEL_NAME, vm)
	return

const GREETINGS = [
	"吾乃{0}\n来堂堂正正地一决胜负",
	"{0}在此！\n逆贼快快下马受死",
]
const RESPONSES =[
	"来！无怨无悔地决斗",
	"尔竟敢口出狂言！",
]

func _init() -> void:
	FlowManager.bind_import_flow("solo_player_start", self)
	FlowManager.bind_import_flow("solo_player_ready", self)
	FlowManager.bind_import_flow("solo_say_hurt", self)
	FlowManager.bind_import_flow("solo_say_dead_1", self)
	FlowManager.bind_import_flow("solo_say_dead_2", self)
	FlowManager.bind_import_flow("solo_say_dead_3", self)
	FlowManager.bind_import_flow("solo_tactic_menu", self)
	FlowManager.bind_import_flow("solo_before_say_hurt", self)
	FlowManager.bind_import_flow("solo_say_dead_4", self)
	
	FlowManager.bind_signal_method("solo_damage", self)
	return

func _process(delta: float) -> void:
	if AutoLoad.playerNo != FlowManager.controlNo:
		return
	_input_key(delta)
	return

func _input_key(delta: float):
	var sf = DataManager.get_current_solo_fight()
	var scene:Control = SceneManager.current_scene()
	var bottom = SceneManager.lsc_menu
	match get_view_model():
		0:#初始叫阵
			if not Global.wait_for_confirmation("", VIEW_MODEL_NAME):
				return
			var done = sf.get_env_int_array("叫阵完成")
			done.append(sf.currentId)
			sf.set_env("叫阵完成", done)
			FlowManager.add_flow("solo_init_say")
		1:#菜单
			var menu = scene.solo_menu
			if Input.is_action_just_pressed("ANALOG_UP"):
				menu.lsc.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				menu.lsc.move_down()
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				menu.lsc.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				menu.lsc.move_right()
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			set_view_model(-1)
			match menu.lsc.cursor_index:
				0:#牵制攻击
					FlowManager.add_flow("load_script|solo/solo_light_attack.gd");
					FlowManager.add_flow("solo_light_attack")
				1:#撤退
					FlowManager.add_flow("load_script|solo/solo_retreat.gd")
					FlowManager.add_flow("solo_retreat")
				2:#攻击
					FlowManager.add_flow("load_script|solo/solo_attack.gd")
					FlowManager.add_flow("solo_attack")
				3:#投降
					var actor = sf.current().actor()
					if actor.get_loyalty() == 100 or actor.faked:
						#君主或人偶不可投降
						return
					FlowManager.add_flow("load_script|solo/solo_surrender.gd")
					FlowManager.add_flow("solo_surrender")
				4:#战术
					FlowManager.add_flow("solo_tactic_menu")
				5:#信息
					FlowManager.add_flow("load_script|solo/solo_see_state.gd")
					FlowManager.add_flow("solo_see_state")
				6:#舍命一击
					FlowManager.add_flow("load_script|solo/solo_crazy_attack.gd")
					FlowManager.add_flow("solo_crazy_attack")
			menu.hide()
		2:#战术列表
			var menu = scene.solo_tactic_menu
			if Input.is_action_just_pressed("ANALOG_UP"):
				menu.lsc.move_up()
			if Input.is_action_just_pressed("ANALOG_DOWN"):
				menu.lsc.move_down()
			if Input.is_action_just_pressed("ANALOG_LEFT"):
				menu.lsc.move_left()
			if Input.is_action_just_pressed("ANALOG_RIGHT"):
				menu.lsc.move_right()
			if Global.is_action_pressed_BY():
				if not SceneManager.dialog_msg_complete(false):
					return
				FlowManager.add_flow("solo_player_ready")
				return
			if not Global.is_action_pressed_AX():
				return
			if not SceneManager.dialog_msg_complete(true):
				return
			set_view_model(-1)
			match menu.lsc.cursor_index:
				0:#说服
					FlowManager.add_flow("load_script|solo/solo_persuade.gd")
					FlowManager.add_flow("solo_persuade")
				1:#恫吓
					FlowManager.add_flow("load_script|solo/solo_threaten.gd")
					FlowManager.add_flow("solo_threaten")
			menu.hide()
		190:#确认伤害，并进入下一步
			Global.wait_for_confirmation("solo_damage", VIEW_MODEL_NAME)
		192:#确认死亡/俘虏
			if not Global.wait_for_confirmation("", VIEW_MODEL_NAME):
				return
			#判断是否需要走夺取装备的方法
			var robEquipList = []
			for actorId in sf.get_actor_ids():
				var wa = DataManager.get_war_actor(actorId)
				if wa == null or not wa.disabled:
					continue
				var actor = wa.actor()
				if not actor.is_status_dead() and not actor.is_status_captured():
					continue
				var opponent = sf.opponent(actorId)
				var opponentActor = opponent.actor()

				var robExp = int(min(10000, actor.get_exp()/2))
				actor.add_exp(-robExp)
				DataManager.actor_add_Exp(opponent.actorId, robExp, false)
				#单挑抢夺装备
				robEquipList = _try_rob_equipment(opponent.actorId, actor.actorId, opponent.vstate().id)

				if wa.actorId == wa.get_lord_id():
					#击杀君主时，夺取装备仓库
					sf.set_env("抢夺装备库", wa.actorId)
					opponent.vstate().rob_all_stored_equipments(wa.vstate().id)
				sf.set_env("抢夺装备", [opponent.actorId, robEquipList])
			if robEquipList.empty() and sf.get_env_int("抢夺装备库", -1) < 0:
				FlowManager.add_flow("solo_say_dead_4")
			else:
				FlowManager.add_flow("solo_say_dead_3")
		193:#确认夺取装备
			Global.wait_for_confirmation("solo_say_dead_4", VIEW_MODEL_NAME)
	return

# 初始叫阵
func solo_player_start() -> void:
	var sf = DataManager.get_current_solo_fight()
	var wa = sf.current()
	var msg = ""
	if sf.currentId == sf.get_actor_ids()[0]:
		var idx = randi() % GREETINGS.size()
		sf.set_env("叫阵对话", idx)
		msg = GREETINGS[idx]
	else:
		var idx = sf.get_env_int("叫阵对话")
		msg = RESPONSES[idx]
	msg = msg.format([wa.get_name()])
	SceneManager.show_solo_dialog(msg, wa.actorId, 0)
	set_view_model(0)
	return

#单挑菜单
func solo_player_ready():
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()
	DataManager.unset_env("单挑.是否暴击")
	LoadControl.end_script()
	scene.solo_menu.init_data(sf.currentId)
	scene.solo_menu.show()
	scene.solo_tactic_menu.hide()
	set_view_model(1)
	return

func solo_before_say_hurt():
	set_view_model(-1)
	var sf = DataManager.get_current_solo_fight()
	var wf = DataManager.get_current_war_fight()

	var wa = sf.current()
	var target = sf.target()
	var targetActor = target.actor()

	var result = DataManager.get_env_int("单挑.是否命中")
	var damage = DataManager.get_env_int("单挑.伤害数值")
	var selfDamage = DataManager.get_env_int("单挑.反伤")
	DataManager.set_env("单挑.补充信息", [])
	var extraMsgs = []
	if result != 0 and damage > 0:
		# 被攻击方触发
		SkillHelper.auto_trigger_skill(target.actorId, 40003)
		extraMsgs = DataManager.get_env_array("单挑.补充信息")
		# 格挡检查
		var parry = targetActor.get_equip_feature_min("单挑格挡")
		if parry > 0 and damage > parry:
			DataManager.set_env("单挑.伤害数值", parry)
			var msg = "{0}格挡{1}伤害".format([
				target.get_name(), damage - parry
			])
			extraMsgs.append(msg)
		# 免死检查
		if targetActor.get_hp() <= damage:
			var suit = targetActor.get_suit()
			var times = targetActor.get_equip_feature_max("单挑免死")
			var key = "单挑免死.{0}".format([suit.id])
			var blocked = wf.get_env_int(key, 0)
			if times > blocked:
				blocked += 1
				wf.set_env(key, blocked)
				var msg = "{0}抵挡{1}点致命伤害".format([
					suit.name(), damage
				])
				extraMsgs.append(msg)
				if blocked >= times:
					DataManager.disable_actor_equip(20000, target.actorId, suit)
					msg = "{0}已被禁用！".format([suit.name()])
					extraMsgs.append(msg)
				damage = 0
				DataManager.set_env("单挑.伤害数值", damage)
		# 攻击方触发，如吸血等
		SkillHelper.auto_trigger_skill(wa.actorId, 40004)
		extraMsgs = DataManager.get_env_array("单挑.补充信息")
	# 攻击回体可以无视命中与否
	var recover = DataManager.get_env_int("单挑.攻击回体")
	DataManager.unset_env("单挑.攻击回体")
	if recover > 0:
		recover = wa.actor().recover_hp(recover)
		if recover > 0:
			var msg = "{0}体力回复 {1}".format([
				wa.get_name(), recover
			])
			extraMsgs.append(msg)
	# 判断反伤
	if selfDamage > 0:
		var msg = "{0}顺势反击\n{1}受到{2}点伤害".format([
			target.get_name(), wa.get_name(), selfDamage,
		])
		extraMsgs.append(msg)
	DataManager.set_env("单挑.补充信息", extraMsgs)
	FlowManager.add_flow("solo_say_hurt")
	return

#报告攻击伤害值
func solo_say_hurt():
	var sf = DataManager.get_current_solo_fight()
	LoadControl.end_script()

	var result = DataManager.get_env_int("单挑.是否命中")
	var damage = DataManager.get_env_int("单挑.伤害数值")
	var isCritical = DataManager.get_env_int("单挑.是否暴击") == 1

	var msg = ""
	if result == 0:
		msg = "但攻击被闪开"
	elif damage <= 0:
		msg = "但并未造成伤害"
	else:
		var memo = "伤害"
		if isCritical:
			memo = "暴击伤害"
		msg = "造成{0}点{1}！".format([damage, memo])
	var extraMessages = DataManager.get_env_array("单挑.补充信息")
	msg += "\n" + "\n".join(extraMessages)
	SceneManager.show_confirm_dialog(msg)
	SceneManager.dialog_msg_complete(true)
	set_view_model(190)
	return

func solo_damage() -> void:
	var sf = DataManager.get_current_solo_fight()

	var wa = sf.current()
	var actor = wa.actor()

	var target = sf.target()
	var targetActor = target.actor()

	var result = DataManager.get_env_int("单挑.是否命中")
	var damage = DataManager.get_env_int("单挑.伤害数值")

	if result == 1:
		# 攻击命中时
		targetActor.set_hp(targetActor.get_hp() - damage)
		if targetActor.get_hp() <= 0:
			# 目标战死
			target.actor_capture_to(wa.wvId, "单挑", wa.actorId)
			FlowManager.add_flow("solo_say_dead_1")
			return

	# 判断反伤
	var selfDamage = DataManager.get_env_int("单挑.反伤")
	if selfDamage > 0:
		actor.set_hp(actor.get_hp() - selfDamage)
		if actor.get_hp() <= 0:
			# 反伤致死
			wa.actor_capture_to(target.wvId, "单挑", target.actorId)
			FlowManager.add_flow("solo_say_dead_1")
			return

	FlowManager.add_flow("solo_turn_end")
	return

#播放死亡动画
func solo_say_dead_1():
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()
	scene.update_hp()
	for actorId in sf.get_actor_ids():
		var wa = DataManager.get_war_actor(actorId)
		if not wa.disabled:
			continue
		var node = scene.get_actor_node(actorId)
		scene.bgm = false
		node.action_dead("solo_say_dead_2")
	set_view_model(191)
	return

#报告死亡
func solo_say_dead_2():
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()
	scene.update_hp()
	var msg = ""
	for actorId in sf.get_actor_ids():
		var wa = DataManager.get_war_actor(actorId)
		if not wa.disabled:
			continue
		var actor = wa.actor()
		if actor.faked:
			msg = "「{0}」灵力消散"
		elif actor.is_status_dead():
			msg = "{0}力竭战败"
		elif actor.is_status_captured():
			msg = "{0}被俘虏了"
		msg = msg.format([actor.get_name()])
		break
	if msg == "":
		return
	SceneManager.show_confirm_dialog(msg)
	set_view_model(192)
	return

#夺取装备
func solo_say_dead_3() -> void:
	var sf = DataManager.get_current_solo_fight()
	var robEquipInfo = sf.get_env_array("抢夺装备")
	var robLordId = sf.get_env_int("抢装备库", -1)
	var msgs = []
	if robEquipInfo.size() == 2:
		var actorId = Global.intval(robEquipInfo[0])
		var robEquipList = Global.arrval(robEquipInfo[1])
		if actorId >= 0 and robEquipList.size() > 0:
			msgs.append("{0}夺得{1}".format([
				ActorHelper.actor(actorId).get_name(), "、".join(robEquipList)
			]))
	if robLordId >= 0:
		var robLord = ActorHelper.actor(robLordId)
		msgs.append("{0}势力的装备库被抢".format([robLord.get_name()]))
	
	if msgs.empty():
		FlowManager.add_flow("solo_say_dead_4")
		return
	SceneManager.show_confirm_dialog("\n".join(msgs))
	set_view_model(193)
	return

#触发死亡技能
func solo_say_dead_4() -> void:
	set_view_model(-1)
	var sf = DataManager.get_current_solo_fight()
	for actorId in sf.get_actor_ids():
		var wa = DataManager.get_war_actor(actorId);
		if wa == null or wa.disabled:
			continue
		var actor = wa.actor()
		if actor.is_status_dead() or actor.is_status_captured():
			continue
		if SkillHelper.auto_trigger_skill(actorId, 40002, "solo_run_end"):
			return
	FlowManager.add_flow("solo_run_end")
	return

#战术菜单
func solo_tactic_menu() -> void:
	var sf = DataManager.get_current_solo_fight()
	var scene = SceneManager.current_scene()

	scene.solo_tactic_menu.init_data(sf.currentId)
	scene.solo_tactic_menu.show()
	scene.solo_menu.hide()
	set_view_model(2)
	return

# 尝试抢夺装备，返回抢夺结果
func _try_rob_equipment(winnerId:int, lostId:int, winnerVstateId:int)->PoolStringArray:
	var robbed = []
	var winner = ActorHelper.actor(winnerId)
	var loser = ActorHelper.actor(lostId)
	var winnerVS = clVState.vstate(winnerVstateId)
	for type in StaticManager.EQUIPMENT_TYPES:
		var target = loser.get_equip(type)
		var subType = target.subtype(true)
		var equipped = winner.get_equip(type)
		# 小战场临时装备，不可抢夺
		if target.battleTemporary:
			continue
		# 装备栏被禁用时，㐓不可夺取
		if target.type_disabled():
			continue
		# 以真实价值判断，不看禁用状态
		if target.level_score(true) <= equipped.level_score(true):
			continue
		if subType != "":
			var typeAllowed = false
			# 有类型的武器/道具，需要同类型才能夺取
			if subType == equipped.subtype():
				typeAllowed = true
			else:
				typeAllowed = false
				# 特殊判断
				if target.level(true) == "S":
					if SkillHelper.actor_has_skills(winnerId, ["龙爪"]):
						typeAllowed = true
			if not typeAllowed:
				continue
		winnerVS.add_stored_equipment(equipped)
		if not loser.set_equip(clEquip.basic_equip(type, subType)):
			continue
		if not winner.set_equip(target):
			loser.set_equip(target)
			continue
		robbed.append(target.name())
	return robbed
