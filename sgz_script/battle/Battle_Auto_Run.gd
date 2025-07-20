extends Resource

const current_step_name = "白兵战-当前步骤"
const next_step_name = "白兵战-下个步骤"

var player_control
var ai_control

var trace = false

func _init() -> void:
	FlowManager.clear_pre_history.clear()
	LoadControl.end_script()
	FlowManager.clear_bind_method()
	
	player_control = Global.load_script(DataManager.mod_path+"sgz_script/battle/player_control.gd")
	ai_control = Global.load_script(DataManager.mod_path+"sgz_script/battle/AI/AI_Control.gd")

	FlowManager.bind_import_flow("battle_run_start", self)
	FlowManager.bind_import_flow("battle_init_trigger", self)
	FlowManager.bind_import_flow("battle_init_units", self)
	FlowManager.bind_import_flow("check_formation_ready", self)
	FlowManager.bind_import_flow("before_turn_start_trigger", self)
	FlowManager.bind_import_flow("unit_action", self)
	FlowManager.bind_import_flow("unit_actioned", self)
	FlowManager.bind_import_flow("after_unit_action", self)
	FlowManager.bind_import_flow("check_battle_need_over", self)
	FlowManager.bind_import_flow("wait_for_AI_tactic", self)
	FlowManager.bind_import_flow("battle_over", self)
	FlowManager.bind_import_flow("go_to_solo", self)
	FlowManager.bind_import_flow("back_from_solo", self)
	FlowManager.bind_import_flow("after_formation_set_trigger", self)
	return

#读取当前步骤
func get_current_step()->int:
	return DataManager.get_env_int(current_step_name)

#设置当前步骤
func set_current_step(step:int)->void:
	DataManager.set_env(current_step_name, step)
	return

#读取下个步骤
func get_next_step()->int:
	return DataManager.get_env_int(next_step_name)

#设置下个步骤
func set_next_step(step:int)->void:
	if trace:
		print("WAR next step set to: " + str(step))
	DataManager.set_env(next_step_name, step)
	return

#白兵战开始
func battle_run_start() -> void:
	DataManager.game_trace("battle_run_start 初始化前");

	var bf = DataManager.get_current_battle_fight()
	bf.ready_to_start()

	DataManager.game_trace("battle_run_start 初始化完成");

	# 准备触发技能
	FlowManager.add_flow("battle_init_trigger")
	return

func battle_init_trigger():
	var bf = DataManager.get_current_battle_fight()
	var key = "INIT.触发武将"
	var triggered = bf.get_env_int_array(key)
	for actorId in [bf.get_attacker_id(), bf.get_defender_id()]:
		if actorId in triggered:
			continue
		triggered.append(actorId)
		bf.set_env(key, triggered)
		if SkillHelper.auto_trigger_skill(actorId, 30050, "battle_init_trigger"):
			return
	bf.unset_env(key)
	FlowManager.add_flow("battle_init_units")
	return

#初始化双方单位
func battle_init_units():
	var bf = DataManager.get_current_battle_fight()
	var attacker = bf.get_attacker()
	var defender = bf.get_defender()
	#初始化双方白兵数据（士气、战术……）
	attacker.battle_init()
	defender.battle_init()

	# 攻防双方初始兵种设置
	bf.init_units()

	# 战斗初始护甲
	for wa in [attacker, defender]:
		for found in wa.actor().get_equip_feature_all("白刃战初始护甲"):
			var equip = found[0]
			# 暂时用临时变量来控制次数
			var key = "{0}.{1}.护甲效果".format([equip.type, equip.id])
			var times = Global.intval(wa.get_tmp_variable(key, 0))
			if times >= 2:
				continue
			var bu = wa.battle_actor_unit()
			if bu == null:
				continue
			wa.set_tmp_variable(key, times + 1)
			var ske = SkillHelper.new_ske_from_equip_simulation(wa.actorId, found[0])
			ske.battle_change_unit_armor(bu, found[1])
			ske.battle_report()

	set_next_step(0)
	return

func _process(delta: float) -> void:
	var bf = DataManager.get_current_battle_fight()
	var scene_battle = SceneManager.current_scene()
	if scene_battle == null:
		return
	if scene_battle.bgm:
		SoundManager.play_bgm();
	
	if not DataManager.battle_run:
		return
	if FlowManager.has_task():
		return
	if is_instance_valid(player_control):
		#必须全部玩家都能走
		player_control._process(delta)
		if player_control.get_view_model() in [4, 10]:
			return
	
	#只需要服务器去处理顺序数据
	if AutoLoad.get_local_id() != 1:
		return;
	var currentStep = get_current_step()
	var nextStep = get_next_step()
	if nextStep == currentStep:
		return
	set_current_step(nextStep)
	currentStep = get_current_step()
	match currentStep:
		0:#等待双方布阵结束
			FlowManager.add_flow("check_formation_ready");
		1:#初始化所有单位的剩余行动次数
			SkillHelper.decrease_skill_cd(30000);
			SkillHelper.decrease_skill_variable(30000);
			SkillHelper.decrease_ban_actor_skill(30000);
			SkillHelper.decrease_actor_scene_skill(30000)
			
			SceneManager.hide_all_tool();
			for i in DataManager.battle_units.size():
				var bu:Battle_Unit = DataManager.battle_units[i];
				if(bu.disabled):
					continue;
				bu.turn_init();
			scene_battle.battle_state.hide();
			scene_battle.battle_tactic.hide();
			scene_battle.main_bottom.update_data();
			scene_battle.main_bottom.show();
			DataManager.common_variable["白兵.技能触发武将"] = [bf.get_attacker_id(), bf.get_defender_id()]
			FlowManager.add_flow("before_turn_start_trigger")
		2:#单位开始行动
			unit_action()
		3:#单位行动完成时
			unit_actioned()
		4:#（处理玩家呼出的暂停）
			check_player_action()
		5:#切换行动方
			DataManager.set_env("白兵.行动单位", -1)
			var prevSide = DataManager.get_env_int("白兵.行动方")
			var side = prevSide + 1
			DataManager.set_env("白兵.行动方", side)
			# 同兵种，切换攻守方行动
			if side >= DataManager.battle_actors.size():
				side = 0
				DataManager.set_env("白兵.行动方", 0)
				DataManager.battle_type_no += 1
				#当前轮次全兵种行动攻守都完成行动
				if DataManager.battle_type_no >= DataManager.battle_type_sort.size():
					bf.next_turn()
					set_next_step(1)
					return
			# 兵种切换行动前
			var currentType = DataManager.battle_type_sort[DataManager.battle_type_no]
			var currentTypeCount = 0
			for bu in DataManager.battle_units:
				if bu == null or bu.disabled:
					continue
				if bu.get_unit_type() != currentType:
					continue
				if side == 0 and bu.leaderId != bf.get_attacker_id():
					continue
				if side == 1 and bu.leaderId != bf.get_defender_id():
					continue
				bu.action_turn_init()
				currentTypeCount += 1
			if currentTypeCount == 0:
				# 当前方没有该兵种，直接切
				DataManager.game_trace("{0}无{1}，跳过".format([
					_side_name(side), currentType
				]))
				set_current_step(4)
				set_next_step(5)
				return
			#set_next_step(6)
			# 直接到第六步
			check_battle_need_over()
		6:#插入到检查A键暂停之前：检查是否满足白兵结束条件
			check_battle_need_over()
		7:#AI行为
			for wa in [bf.get_attacker(), bf.get_defender()]:
				if wa == null or wa.disabled:
					continue
				if wa.get_controlNo() >= 0:
					continue
				#玩家被包围不开放投降
				if ai_control.think_about_surrend(wa.actorId):
					set_next_step(6)
					return;#投降
				#前进后退状态更改
				var changed = ai_control.think_about_order(wa.actorId)
				bf.set_unit_state(wa.actorId, changed)
				# 尝试发动主动技
				if ai_control.think_about_active_skill(wa.actorId):
					FlowManager.add_flow("wait_AI_active_skill")
					wait_for_AI_active_skill()
					return
				var considerTactic = false
				# 检查敌人状态
				var enemy = wa.get_battle_enemy_war_actor()
				if enemy == null:
					continue
				var enemyChoice = bf.get_units_state(enemy.actorId, "将")
				if DataManager.diffculities >= 3 \
					and enemyChoice == "后退" \
					and wa.actorId == bf.get_defender_id():
					# 究极守方，攻方后退，尝试战术
					considerTactic = true
				elif bf.turns() > 1:
					considerTactic = true
				if considerTactic and ai_control.think_about_tactic(wa.actorId):
					DataManager.common_variable["当前武将"] = wa.actorId
					FlowManager.add_flow("before_AI_tactic")
					return
			set_next_step(8)
		8:
			wait_for_AI_tactic()
		9:
			wait_for_AI_active_skill()
	return

func unit_action():
	set_current_step(2)
	set_next_step(2)
	# 处理闲时对话
	if check_wait_dialogs():
		return

	# 支持强袭、拔矢等技能产生的临时插入回合
	if run_instant_action():
		if trace:
			DataManager.game_trace("INSTANT ACTION injected")
		return

	SceneManager.hide_all_tool();
	player_control.wait_for_player_call();

	var bf = DataManager.get_current_battle_fight()
	var side = DataManager.get_env_int("白兵.行动方")
	var currentActorId = bf.get_defender_id()
	var states = bf.get_defender_state()
	if side == 0:
		currentActorId = bf.get_attacker_id()
		states = bf.get_attacker_state()
	var currentType = DataManager.battle_type_sort[DataManager.battle_type_no]
	var wa = DataManager.get_war_actor(currentActorId)

	# 玩家按下暂停键触发
	SkillHelper.auto_trigger_skill(currentActorId, 31000, "unit_action")

	# 增加对「死战」状态的支持
	if wa.get_buff("全军死战")["回合数"] > 0:
		for k in states:
			if k == "将":
				continue
			states[k] = "前进"
		bf.set_unit_state(currentActorId, states)

	# 增加对「混乱」buff 的支持
	# 混乱覆盖死战
	if wa.get_buff("混乱")["回合数"] > 0:
		var random_states = ["包围", "后退", "待机"]
		for k in states:
			if k == "将":
				continue
			random_states.shuffle()
			states[k] = random_states[0]
		bf.set_unit_state(currentActorId, states)

	var prevActionNo = DataManager.get_env_int("白兵.行动单位")
	var currentActionNo = -1
	var action = ""
	var actionUnit = null
	for i in DataManager.battle_units.size():
		var unit:Battle_Unit = DataManager.battle_units[i]
		if unit.leaderId != currentActorId:
			continue
		if unit.get_unit_type() != currentType:
			continue
		action = unit.combat_action()
		if action == "":
			#无行动时，清空可行动步数
			unit.wait_action_times = 0
			continue
		if action == "单挑":
			#进入单挑界面
			DataManager.set_env("白兵.行动单位", currentActionNo)
			FlowManager.add_flow("go_to_solo")
			return
		currentActionNo = i
		actionUnit = unit
		break
	if currentActionNo == -1 or actionUnit == null:
		if trace:
			DataManager.game_trace("UNIT_ACTION for {0}#{1}: NONE".format([
				currentType, _side_name(side),
			]))
		set_next_step(5)
		return
	
	if prevActionNo != currentActionNo:
		# 切换单位
		actionUnit.clear_once_flags(true)
		if prevActionNo >= 0 && prevActionNo <= DataManager.battle_units.size():
			var prevUnit = DataManager.battle_units[prevActionNo]
			prevUnit.other_wait_type = ""
			prevUnit.dic_other_variable.erase("被格挡")
		DataManager.unset_env("白兵.剑类影响目标")

	DataManager.set_env("白兵.行动单位", currentActionNo)
	
	if trace:
		DataManager.game_trace("UNIT_ACTION for {0}#{1}: {2}->{3}".format([
			currentType, _side_name(side), currentActionNo, action,
		]))
	if SkillHelper.auto_trigger_skill(currentActorId, 30001, "after_unit_action"):
		return
	after_unit_action()
	return

func after_unit_action():
	var unitId = DataManager.get_env_int("白兵.行动单位")
	if unitId < 0 or unitId >= DataManager.battle_units.size():
		return
	var unit = DataManager.battle_units[unitId]
	if unit == null or unit.disabled:
		return
	unit.action_run_call_UI()

#等待双方布阵结束
func check_formation_ready():
	set_current_step(0);
	set_next_step(0);
	var bf = DataManager.get_current_battle_fight()
	var scene_battle = SceneManager.current_scene();
	SceneManager.hide_all_tool();
	if bf.init_formation():
		return

	scene_battle.unit_updated = false;
	FlowManager.force_change_controlNo(0);
	DataManager.common_variable["白兵.技能触发武将"] = [bf.get_attacker_id(), bf.get_defender_id()]
	FlowManager.add_flow("after_formation_set_trigger")
	return

#单位行动结束时调用
func unit_actioned():
	set_current_step(3)
	set_next_step(3)

	var currentUnitId = DataManager.get_env_int("白兵.行动单位")
	var bf = DataManager.get_current_battle_fight()
	var unit = bf.battle_unit(currentUnitId)
	if unit == null:
		set_next_step(4)
		return
	
	# 攻方单位，绕到城门后方，城门直接开启
	if unit.get_side() == Vector2.LEFT:
		var unitLeft = DataManager.get_battle_unit_by_position(unit.unit_position + Vector2.LEFT)
		if unitLeft != null and not unitLeft.disabled and unitLeft.get_unit_type() == "城门":
			unitLeft.disabled = true
			SoundManager.play_se2("res://resource/sounds/se/open_gate.ogg")
	
	# 待机行动不触发后续事件，也不触发完整流程，直接下一个单位
	if unit.get_unit_type() != "将" and unit.last_action_name == "待机":
		unit.complete_action_task()
		check_player_action()
		return
	if(DataManager.common_variable.has("白兵.攻击目标")):
		var _unit = DataManager.battle_units[int(DataManager.common_variable["白兵.攻击目标"][0])];
		if(_unit.wait_action_name != ""):
			return;
	if(DataManager.common_variable.has("白兵.攻击来源")):
		var _unit = DataManager.battle_units[int(DataManager.common_variable["白兵.攻击来源"])];
		if(_unit.wait_action_name != ""):
			return;
	SkillHelper.auto_trigger_skill(unit.leaderId, 30007)

	var wa = DataManager.get_war_actor(unit.leaderId)
	if wa != null:
		var enemy = wa.get_battle_enemy_war_actor()
		if enemy != null:
			SkillHelper.auto_trigger_skill(enemy.actorId, 30017)

	# 疾驰和坐骑骅骝的效果
	# 第一动为移动时，行动次数 +1
	# 每回合一次
	if unit.get_unit_type() == "将" \
		and unit.wait_action_times == unit.get_action_times() - 1 \
		and unit.last_action_name == "移动" \
		and Global.intval(unit.get_tmp_variable("疾驰", 0)) != 1:
		if SkillRangeBuff.max_val_for_actor("疾驰", unit.leaderId) > 0 \
			or unit.actor().get_equip_feature_max("疾驰") > 0:
			unit.add_status_effect("疾驰")
			unit.set_tmp_variable("疾驰", 1)
			unit.wait_action_times += 1

	var scene_battle = SceneManager.current_scene();
	scene_battle.main_bottom.update_data();
	scene_battle.unit_updated = false;#刷新显示
	unit.complete_action_task();

	# 行动完毕技能触发，不支持 flow
	SkillHelper.auto_trigger_skill(unit.leaderId, 30002)

	# @since 1.98 镔铁双戟
	unit.check_for_kill_instant()

	check_battle_need_over()
	return

#检查白兵结束条件是否满足
func check_battle_need_over():
	set_current_step(6)
	set_next_step(6)
	# 默认的下一步是 4，即检查玩家暂停
	var nextStep = 4
	var bf = DataManager.get_current_battle_fight()
	var side = DataManager.get_env_int("白兵.行动方")
	var wa = bf.get_attacker()
	if side == 1:
		wa = bf.get_defender()
	if wa.get_controlNo() < 0:
		# 轮到 AI 行动，只有这时考虑 7
		nextStep = 7
	if not bf.check_battle_should_over():
		#不结束，继续
		set_next_step(nextStep)
		return

	var loser = bf.get_loser()
	if loser == null:
		#不结束，继续
		set_next_step(nextStep)
		return

	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		#不结束，继续
		set_next_step(nextStep)
		return

	# 胜负已分，结束整场白兵战
	if loser.get_controlNo() >= 0:
		FlowManager.set_current_control_playerNo(loser.get_controlNo())
	elif winner.get_controlNo() >= 0:
		FlowManager.set_current_control_playerNo(winner.get_controlNo())
	else:
		# 没有任何玩家可控制时，由1P控制（防错机制）
		FlowManager.set_current_control_playerNo(0)

	LoadControl.end_script()
	FlowManager.add_flow("load_script|battle/player_end.gd")
	FlowManager.add_flow("battle_player_end")
	return

func battle_over():
	var wf = DataManager.get_current_war_fight()
	var bf = DataManager.get_current_battle_fight()
	if bf.loserId < 0:
		FlowManager.add_flow("check_battle_need_over")
		return
	var attacker = bf.get_attacker()
	var defender = bf.get_defender()

	# 战斗结束技能触发，不支持回调
	SkillHelper.auto_trigger_skill(attacker.actorId, 30099)
	SkillHelper.auto_trigger_skill(defender.actorId, 30099)

	DataManager.battle_run = false;
	#失败方若武将未死，则扣粮，并且后退一步	
	var loser = bf.get_loser()
	var winner = loser.get_battle_enemy_war_actor()
	DataManager.unset_env("后退位置")
	#撤退的情况
	if not loser.actor().is_status_dead() and loser.wvId != winner.wvId:
		var disv = loser.position - winner.position;
		# 远程袭击均不触发后退
		if abs(disv.x) + abs(disv.y) == 1:
			#被定止，定止回合数-1，抵消后退
			var stopped = loser.get_buff("定止")
			if stopped["回合数"] > 0:
				loser.set_buff("定止", stopped["回合数"] - 1, stopped["来源武将"], "", true)
			else:
				var pos = loser.position + disv
				DataManager.common_variable["后退位置"] = {"x":pos.x, "y":pos.y}

	#双方剩余兵力（包括禁用状态兵种）总量写入武将兵力属性
	bf.attackerRemaining = int(ceil(bf.get_battle_sodiers(attacker.actorId, true, false)))
	bf.defenderRemaining = int(ceil(bf.get_battle_sodiers(defender.actorId, true, false)))
	var recover = bf.get_env_dict("战后兵力")
	if str(bf.get_attacker_id()) in recover:
		bf.attackerRemaining = Global.intval(recover[str(bf.get_attacker_id())])
	if str(bf.get_defender_id()) in recover:
		bf.defenderRemaining = Global.intval(recover[str(bf.get_defender_id())])
	attacker.actor().set_soldiers(bf.attackerRemaining)
	defender.actor().set_soldiers(bf.defenderRemaining)

	SkillHelper.auto_trigger_skill(attacker.actorId, 30004, "")
	SkillHelper.auto_trigger_skill(defender.actorId, 30004, "")

	#城门血量总计
	var doorHP = bf.get_door_hp()
	var positon = bf.get_position()
	if positon.x >= 0 and bf.get_terrian() == "walldoor":
		wf.target_city().set_door_hp(positon, doorHP/3.0)

	#清空白兵数据
	DataManager.battle_units.clear();
	DataManager.battle_first_sort=[];
	DataManager.battle_type_sort=[];
	SceneManager.hide_all_tool();
	LoadControl.end_script();
	wf.battle_over()
	SceneManager.current_scene().main_bottom.hide()
	SceneManager.black.show();
	
	FlowManager.add_flow("go_to_scene|res://scene/scene_war/scene_war.tscn");
	FlowManager.add_flow("back_to_war")
	return
	
func go_to_solo():
	var current_action_no = int(DataManager.common_variable["白兵.行动单位"]);
	var unit:Battle_Unit = DataManager.battle_units[current_action_no];
	if(unit.has_action_task()=="单挑"):
		unit.complete_action_task();
	
	DataManager.battle_run = false
	DataManager.solo_run = true
	FlowManager.add_flow("go_to_scene|res://scene/scene_solo/scene_solo.tscn")
	FlowManager.add_flow("solo_run_start")
	return

#从单挑界面回来时调用
func back_from_solo():
	var bf = DataManager.get_current_battle_fight()
	if bf.check_battle_should_over():
		var loser = bf.get_loser()
		var winner = loser.get_battle_enemy_war_actor()
		# 胜负已分，结束整场白兵战
		if loser.get_controlNo() >= 0:
			FlowManager.set_current_control_playerNo(loser.get_controlNo())
		elif winner.get_controlNo() >= 0:
			FlowManager.set_current_control_playerNo(winner.get_controlNo())
		else:
			# 没有任何玩家可控制时，由1P控制（防错机制）
			FlowManager.set_current_control_playerNo(0)
		LoadControl.end_script()
		FlowManager.add_flow("battle_over")
		return

	DataManager.battle_run = true;
	SceneManager.black.hide();

	var defenderState = bf.get_units_state(bf.get_defender_id(), "将")
	var attackerState = bf.get_units_state(bf.get_attacker_id(), "将")
	if defenderState == "后退":
		DataManager.battle_type_no = DataManager.battle_type_sort.find("将");
		var current_action_no = DataManager.common_variable["白兵.行动单位"];
		for bu in DataManager.battle_units:
			if bu == null or bu.disabled or bu.leaderId != bf.get_defender_id():
				continue
			current_action_no = bu.unitId;
			bu.remove_action_task();
			bu.wait_action_times = 2;
			var wa = DataManager.get_war_actor(bu.leaderId)
			bf.change_battle_morale(wa.actorId, -7, "撤出单挑")
			bf.change_battle_courage(wa.actorId, -10, "撤出单挑")
			break;
		DataManager.common_variable["白兵.行动单位"] = current_action_no;
	elif attackerState == "后退":
		DataManager.battle_type_no = DataManager.battle_type_sort.find("将");
		var current_action_no = DataManager.common_variable["白兵.行动单位"];
		for bu in DataManager.battle_units:
			if bu == null or bu.disabled or bu.leaderId != bf.get_attacker_id():
				continue
			current_action_no = bu.unitId;
			bu.remove_action_task();
			bu.wait_action_times = 2;
			var wa = DataManager.get_war_actor(bu.leaderId)
			bf.change_battle_morale(wa.actorId, -7, "撤出单挑")
			bf.change_battle_courage(wa.actorId, -10, "撤出单挑")
			break;
		DataManager.common_variable["白兵.行动单位"] = current_action_no;

	#刷新显示
	SceneManager.current_scene().clear_units()
	#防止连锁技能未执行完毕
	var st_info = SkillHelper.get_current_skill_trigger();
	if (st_info != null):
		return;
	FlowManager.add_flow("unit_actioned");
	return

func wait_for_AI_tactic():
	set_current_step(8)
	set_next_step(4)
	return

func wait_for_AI_active_skill():
	set_current_step(9)
	set_next_step(-1)
	return

func after_formation_set_trigger():
	set_current_step(-1)
	set_next_step(-1)
	var actorIds = DataManager.get_env_int_array("白兵.技能触发武将")
	while not actorIds.empty():
		var actorId = actorIds.pop_front()
		DataManager.set_env("白兵.技能触发武将", actorIds)
		if SkillHelper.auto_trigger_skill(actorId, 30005, "after_formation_set_trigger"):
			return
	set_next_step(1)
	return

func before_turn_start_trigger():
	set_current_step(-1)
	set_next_step(-1)
	var actorIds = Array(DataManager.common_variable["白兵.技能触发武将"])
	while not actorIds.empty():
		var actorId = actorIds.pop_front()
		DataManager.common_variable["白兵.技能触发武将"] = actorIds
		if SkillHelper.auto_trigger_skill(actorId, 30009, "before_turn_start_trigger"):
			return
	set_next_step(2)
	return

# 检查和执行特殊的临时回合
# @return false 表示无临时回合
func run_instant_action()->bool:
	while true:
		var bia = Battle_Instant_Action.pop_first()
		if bia == null:
			#没有可用的
			return false
		if not bia.need_state.empty():
			if not bia.need_state.has(bia.get_unit_state()):
				#当前状态不在可用的里面
				continue
		var action_unit = DataManager.battle_units[bia.unitId]
		return action_unit.prepare_instant_action(bia)
	return false

# 检查并处理闲时对话
# @return 是否有对话待处理
func check_wait_dialogs():
	var bf = DataManager.get_current_battle_fight()
	for wa in [bf.get_attacker(), bf.get_defender()]:
		if wa == null or wa.disabled:
			continue
		var d = wa.get_next_dialog(30000)
		if d == null:
			continue
		# 播放对话
		DataManager.set_env("白兵.闲时对话", d.output())
		FlowManager.add_flow("battle_free_talk")
		return true
	return DataManager.common_variable.has("白兵.闲时对话")

func _side_name(side:int)->String:
	match side:
		0:
			return "攻方"
		1:
			return "守方"
	return "未知#" + str(side)

func check_player_action()->void:
	set_current_step(4)
	set_next_step(4)
	var bf = DataManager.get_current_battle_fight()
	var pause_list = DataManager.get_env_int_array("白兵.呼叫暂停")
	if pause_list.empty():
		set_next_step(2)
		return
	var pause_controlNo = pause_list.pop_front()
	DataManager.set_env("白兵.呼叫暂停", pause_list)
	var actorIds = []
	for wa in [bf.get_attacker(), bf.get_defender()]:
		if pause_controlNo == wa.get_controlNo():
			actorIds.append(wa.actorId)
	if actorIds.empty():
		set_next_step(2)
		return
	if actorIds.size() == 1:
		DataManager.set_env("当前武将", actorIds[0])
		FlowManager.add_flow("battle_set_state")
		return
	var called = DataManager.get_env_int("白兵.轮流控制武将", -1)
	for actorId in actorIds:
		if actorId == called:
			continue
		DataManager.set_env("白兵.轮流控制武将", actorId)
		DataManager.set_env("当前武将", actorId)
		FlowManager.add_flow("battle_set_state")
		return
	set_next_step(2)
	return
