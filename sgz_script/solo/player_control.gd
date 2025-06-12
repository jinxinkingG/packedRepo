extends Resource
const view_model_name = "单挑-玩家-步骤";

func get_view_model():
	if(!DataManager.common_variable.has(view_model_name)):
		return -1;
	return int(DataManager.common_variable[view_model_name]);

func set_view_model(view_model:int):
	DataManager.common_variable[view_model_name] = int(view_model);


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
	return

func _process(delta: float) -> void:
	if AutoLoad.playerNo != FlowManager.controlNo:
		return
	_input_key(delta)
	return

func _input_key(delta: float):
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	match get_view_model():
		0:#初始叫嚣
			if not Global.wait_for_confirmation("", view_model_name):
				return
			var side = DataManager.solo_sort[DataManager.solo_sort_no]
			var finished = DataManager.get_env_array("单挑.叫嚣完成")
			finished.append(side)
			DataManager.set_env("单挑.叫嚣完成", finished)
			FlowManager.add_flow("solo_init_say")
		1:#菜单
			var solo_menu = scene_solo.solo_menu;
			if(Input.is_action_just_pressed("ANALOG_UP")):
				solo_menu.lsc.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				solo_menu.lsc.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				solo_menu.lsc.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				solo_menu.lsc.move_right();
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var action = solo_menu.lsc.cursor_index;
				var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
				var actorId = DataManager.solo_actor_by_side(side);
				var actor = ActorHelper.actor(actorId)
				DataManager.common_variable["单挑.行为"]=action;
				
				match action:
					0:#牵制攻击
						FlowManager.add_flow("load_script|solo/solo_light_attack.gd");
						FlowManager.add_flow("solo_light_attack");
					1:#撤退
						FlowManager.add_flow("load_script|solo/solo_retreat.gd");
						FlowManager.add_flow("solo_retreat");
					2:#攻击
						FlowManager.add_flow("load_script|solo/solo_attack.gd");
						FlowManager.add_flow("solo_attack");
					3:#投降
						if actor.get_loyalty() == 100 or actor.faked:
							#君主或人偶不可投降
							return;
						FlowManager.add_flow("load_script|solo/solo_surrender.gd");
						FlowManager.add_flow("solo_surrender");
					4:#战术
						FlowManager.add_flow("solo_tactic_menu");
					5:#信息
						FlowManager.add_flow("load_script|solo/solo_see_state.gd");
						FlowManager.add_flow("solo_see_state");
					6:#舍命一击
						FlowManager.add_flow("load_script|solo/solo_crazy_attack.gd");
						FlowManager.add_flow("solo_crazy_attack");
				scene_solo.solo_menu.hide();
		2:#战术列表
			var solo_tactic_menu = scene_solo.solo_tactic_menu;
			if(Input.is_action_just_pressed("ANALOG_UP")):
				solo_tactic_menu.lsc.move_up();
			if(Input.is_action_just_pressed("ANALOG_DOWN")):
				solo_tactic_menu.lsc.move_down();
			if(Input.is_action_just_pressed("ANALOG_LEFT")):
				solo_tactic_menu.lsc.move_left();
			if(Input.is_action_just_pressed("ANALOG_RIGHT")):
				solo_tactic_menu.lsc.move_right();
			if(Global.is_action_pressed_AX()):
				if(!SceneManager.dialog_msg_complete(true)):
					return;
				var action = 7+solo_tactic_menu.lsc.cursor_index;
				var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
				var actorId = DataManager.solo_actor_by_side(side);
				DataManager.common_variable["单挑.行为"]=action;
				scene_solo.solo_menu.hide();
				match action:
					7:#说服
						FlowManager.add_flow("load_script|solo/solo_persuade.gd");
						FlowManager.add_flow("solo_persuade");
					8:#恫吓
						FlowManager.add_flow("load_script|solo/solo_threaten.gd");
						FlowManager.add_flow("solo_threaten");
			if(Global.is_action_pressed_BY()):
				if(!SceneManager.dialog_msg_complete(false)):
					return;
				FlowManager.add_flow("solo_player_ready");
		190:#确认伤害，并进入下一步
			if not Global.wait_for_confirmation("", view_model_name):
				return
			var result = DataManager.get_env_int("单挑.是否命中")
			var damage = DataManager.get_env_int("单挑.伤害数值")
			var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
			var actorId = DataManager.solo_actor_by_side(side)
			var actor = ActorHelper.actor(actorId)
			var wa = DataManager.get_war_actor(actorId)
			var enemy = wa.get_battle_enemy_war_actor()
			if result == 1:
				#攻击命中时
				var enemyActor = enemy.actor()
				enemyActor.set_hp(enemyActor.get_hp() - damage)
				if enemyActor.get_hp() <= 0:
					enemy.actor_capture_to(wa.wvId, "单挑", wa.actorId)
					FlowManager.add_flow("solo_say_dead_1")
					return
			# 判断反伤
			var selfDamage = DataManager.get_env_int("单挑.反伤")
			if selfDamage > 0:
				actor.set_hp(actor.get_hp() - selfDamage)
				if actor.get_hp() <= 0:
					wa.actor_capture_to(enemy.wvId, "单挑", enemy.actorId)
					FlowManager.add_flow("solo_say_dead_1")
					return
			FlowManager.add_flow("solo_turn_end")
		192:#确认死亡/俘虏
			if not Global.wait_for_confirmation("", view_model_name):
				return
			DataManager.set_env("单挑.抢装备库", -1)
			#判断是否需要走夺取装备的方法
			var rob_equlist = []
			for actorId in DataManager.solo_actors:
				var wa = DataManager.get_war_actor(actorId)
				if wa == null or not wa.disabled:
					continue;
				var actor = ActorHelper.actor(actorId)
				if actor.is_status_dead() or actor.is_status_captured():
					var enemy_war_actor = wa.get_battle_enemy_war_actor();
					var enemy_actor = ActorHelper.actor(enemy_war_actor.actorId)

					var robExp = int(min(10000, actor.get_exp()/2))
					actor.add_exp(-robExp)
					DataManager.actor_add_Exp(enemy_war_actor.actorId, robExp, false)
					#单挑抢夺装备
					rob_equlist = _try_rob_equipment(enemy_actor.actorId, actor.actorId, enemy_war_actor.vstate().id)

					if wa.actorId == wa.get_lord_id():
						#击杀君主时，夺取装备仓库
						DataManager.set_env("单挑.抢装备库", wa.actorId)
						enemy_war_actor.vstate().rob_all_stored_equipments(wa.vstate().id)
			if rob_equlist.empty() and DataManager.get_env_int("单挑.抢装备库", -1) < 0:
				FlowManager.add_flow("solo_say_dead_4")
			else:
				DataManager.set_env("单挑.抢夺装备", rob_equlist)
				FlowManager.add_flow("solo_say_dead_3")
		193:#确认夺取装备
			Global.wait_for_confirmation("solo_say_dead_4", view_model_name)
	return

#初始叫嚣
func solo_player_start():
	set_view_model(0);
	var dialogs1 = [
		"吾乃{0}\n来堂堂正正地一决胜负","{0}在此！\n逆贼快快下马受死",
	];
	var dialogs2 =[
		"来！无怨无悔地决斗","你竟敢口出狂言",
	];
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var actor = ActorHelper.actor(actorId)
	var dialog_index = 0;
	var msg = "";
	if(DataManager.solo_sort_no==0):
		dialog_index = Global.get_random(0,1);
		DataManager.common_variable["值"]=dialog_index;
		msg = str(dialogs1[dialog_index]).format([actor.get_name()]);
	else:
		dialog_index = int(DataManager.common_variable["值"]);
		msg = dialogs2[dialog_index];
	SceneManager.show_solo_dialog(msg,actorId,0);

#单挑菜单
func solo_player_ready():
	set_view_model(1);
	LoadControl.end_script();
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var wa = DataManager.get_war_actor(actorId);
	var enemy_wa:War_Actor = wa.get_battle_enemy_war_actor();
	var actor = ActorHelper.actor(actorId);
	var enemy_actor = ActorHelper.actor(enemy_wa.actorId);
	scene_solo.solo_menu.init_data(actorId);
	scene_solo.solo_menu.show();
	scene_solo.solo_tactic_menu.hide();
	return

func solo_before_say_hurt():
	set_view_model(189);
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	#40001：单挑攻击时（已确认是否命中）
	if(SkillHelper.auto_trigger_skill(actorId,40001,"solo_say_hurt")):
		return;
	FlowManager.add_flow("solo_say_hurt")
	return

#报告攻击伤害值
func solo_say_hurt():
	set_view_model(190);
	LoadControl.end_script();
	var wf = DataManager.get_current_war_fight()
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var wa = DataManager.get_war_actor(actorId);
	var enemy:War_Actor = wa.get_battle_enemy_war_actor();
	var enemyActor = enemy.actor()
	var result = DataManager.get_env_int("单挑.是否命中")
	var damage = DataManager.get_env_int("单挑.伤害数值")
	var selfDamage = DataManager.get_env_int("单挑.反伤")
	var msgs = []
	if result == 0:
		msgs.append("但攻击被闪开")
		if selfDamage > 0:
			var msg = "{0}顺势反击\n{1}受到{2}点伤害".format([
				enemy.get_name(), wa.get_name(), selfDamage,
			])
			msgs.append(msg)
	elif damage <= 0:
		msgs.append("但并未造成伤害")
	else:
		# 重置对白，40003 和 40004 都可以调整对白补充信息
		var memo = ""
		#被攻击方触发
		SkillHelper.auto_trigger_skill(enemy.actorId, 40003, "")
		if DataManager.get_env_int("单挑.是否暴击") == 1:
			memo = "暴击"
		damage = DataManager.get_env_int("单挑.伤害数值")
		# 格挡检查
		var parry = enemyActor.get_equip_feature_min("单挑格挡")
		if parry > 0 and damage > parry:
			var msg = "{0}格挡{1}伤害".format([
				enemyActor.get_name(), damage - parry,
			])
			DataManager.set_env("单挑.伤害数值", parry)
			DataManager.set_env("单挑.额外伤害", 0)
			damage = parry
			msgs.append(msg)
		# 免死检查
		if enemyActor.get_hp() <= damage:
			var suit = enemyActor.get_suit()
			var times = enemyActor.get_equip_feature_max("单挑免死")
			var key = "单挑免死.{0}".format([suit.id])
			var blocked = wf.get_env_int(key, 0)
			if times > blocked:
				blocked += 1
				wf.set_env(key, blocked)
				var msg = "{0}抵挡{1}点致命伤害"
				if blocked >= times:
					DataManager.disable_actor_equip(20000, enemy.actorId, suit)
					msg += "，{0}已被禁用！"

				msg = msg.format([
					suit.name(), damage
				])
				DataManager.set_env("单挑.伤害数值", 0)
				DataManager.set_env("单挑.额外伤害", 0)
				damage = 0
				msgs.append(msg)

		DataManager.set_env("单挑.补充信息", "")
		if damage > 0:
			#----攻击方命中以后触发(此步骤用于近似模拟已经打完伤害的阶段，处理吸血等情况)---------
			SkillHelper.auto_trigger_skill(wa.actorId, 40004, "")

		var damageMsg = str(damage)
		var extraDamage = DataManager.get_env_int("单挑.额外伤害")
		extraDamage = max(0, extraDamage)
		DataManager.unset_env("单挑.额外伤害")
		if damage < extraDamage:
			extraDamage = 0
		if extraDamage > 0:
			damageMsg ="{0}(+{1})".format([damage - extraDamage, extraDamage])
		var msg = "造成{0}点{1}伤害！".format([damageMsg, memo])
		msgs.insert(0, msg)
		var extraMessage = DataManager.get_env_str("单挑.补充信息")
		if extraMessage != "":
			msgs.append(extraMessage)
	SceneManager.show_confirm_dialog("\n".join(msgs))
	DataManager.unset_env("单挑.是否暴击")
	SceneManager.dialog_msg_complete(true)
	return

#播放死亡动画
func solo_say_dead_1():
	set_view_model(191);
	var scene_solo = SceneManager.current_scene();
	scene_solo.update_hp();
	for actorId in DataManager.solo_actors:
		var wa = DataManager.get_war_actor(actorId)
		if not wa.disabled:
			continue
		var node = scene_solo.get_actor_node(actorId);
		scene_solo.bgm = false
		node.action_dead("solo_say_dead_2")
	return

#报告死亡
func solo_say_dead_2():
	set_view_model(192);
	var scene_solo = SceneManager.current_scene();
	scene_solo.update_hp();
	for actorId in DataManager.solo_actors:
		var wa = DataManager.get_war_actor(actorId)
		if wa.disabled:
			var actor = wa.actor()
			if actor.faked:
				SceneManager.show_confirm_dialog("「{0}」灵力消散".format([actor.get_name()]))
				return
			if actor.is_status_dead():
				SceneManager.show_confirm_dialog("{0}力竭战败".format([actor.get_name()]))
				return
			elif actor.is_status_captured():
				SceneManager.show_confirm_dialog("{0}被俘虏了".format([actor.get_name()]))
				return
	return

#夺取装备
func solo_say_dead_3():
	var rob_equlist:Array = DataManager.common_variable["单挑.抢夺装备"];
	var msg = [];
	if !rob_equlist.empty():
		for actorId in DataManager.solo_actors:
			var actor = ActorHelper.actor(actorId)
			var war_actor = DataManager.get_war_actor(actorId);
			if(war_actor.disabled):
				continue;
			if actor.is_status_dead() or actor.is_status_captured():
				continue;
			msg.append("{0}夺得{1}".format([
				actor.get_name(), "、".join(rob_equlist)
			]));
	if DataManager.common_variable.has("单挑.抢装备库"):
		var rob_lordId = int(DataManager.common_variable["单挑.抢装备库"]);
		if rob_lordId!=-1:
			var rob_lord = ActorHelper.actor(rob_lordId);
			msg.append("{0}势力的装备库被抢".format([rob_lord.get_name()]));
	
	if msg.empty():
		FlowManager.add_flow("solo_say_dead_4");
		return
	SceneManager.show_confirm_dialog("\n".join(msg));
	set_view_model(193)
	return

#触发死亡技能
func solo_say_dead_4():
	set_view_model(-1)
	for actorId in DataManager.solo_actors:
		var actor = ActorHelper.actor(actorId)
		var war_actor = DataManager.get_war_actor(actorId);
		if(war_actor==null || war_actor.disabled):
			continue;
		if actor.is_status_dead() or actor.is_status_captured():
			continue;
		if(SkillHelper.auto_trigger_skill(actorId,40002,"solo_run_end")):
			return;
	FlowManager.add_flow("solo_run_end");
	return

#战术菜单
func solo_tactic_menu():
	set_view_model(2);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	
	scene_solo.solo_tactic_menu.init_data(actorId);
	scene_solo.solo_tactic_menu.show();
	scene_solo.solo_menu.hide();

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
