extends Resource


#--------俘虏判断-------------
func think_about_surrend(actorId:int)->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf == null:
		return false

	#原版3个难度下，AI武将体力分别小于45 40 30，有55,50,30的概率投降
	var need_hp_lower = [45,40,20,13,13];
	var surrend_rates = [55,50,30,20,20];
	
	var hp_lower:int = need_hp_lower[DataManager.diffculities];
	var surrend_rate:int = surrend_rates[DataManager.diffculities];
	
	var actor = ActorHelper.actor(actorId)
	var war_actor = DataManager.get_war_actor(actorId);
	var war_enemy:War_Actor = war_actor.get_battle_enemy_war_actor();
	if actor.get_hp() > hp_lower:
		return false;
	#忠<100才进入俘虏判断
	#TODO, 加对话提示
	if actor.get_loyalty() >= 100:
		return false;
	
	#厌恶的势力，被包围也不投降
	#TODO, 加对话提示
	if actor.get_dislike_vstate_id() == war_enemy.vstate().id:
		return false
	
	var actor_unit = war_actor.battle_actor_unit();
	if actor_unit == null or actor_unit.disabled:
		return false;
	#周围存在的敌方单位
	var num = 0;
	for v in StaticManager.NEARBY_DIRECTIONS:
		var position = actor_unit.unit_position+v;
		var t_unit = DataManager.get_battle_unit_by_position(position);
		if(t_unit==null || t_unit.disabled):
			continue;
		if(t_unit.leaderId!=actorId):
			num+=1;
	#至少存在两个敌方单位
	var at_least_units = 2;
	if(num < at_least_units):
		return false;
	
	# 记录上次检验投降的回合数（默认0）
	var checkKey = "白兵.AI投降判断.{0}".format([actorId])
	var checkTurn = DataManager.get_env_int(checkKey, 0)
	if checkTurn >= bf.turns():
		# 如果本回合已经检验过，则不再验证
		return false
	DataManager.set_env(checkKey, bf.turns())
	
	if(!Global.get_rate_result(surrend_rate)):
		return false;

	actor_unit.is_surrend = true;
	#投降忠赋值
	actor.set_loyalty(max(10, 79-actor.get_loyalty()))
	
	return true;

#--------后退与前进判断-------------
func think_about_order(actorId:int)->Dictionary:
	var bf = DataManager.get_current_battle_fight()
	#4个难度下，AI武将撤退概率30、45、55、60
	var retreat_rates = [30,45,55,60,60]
	var rate = retreat_rates[DataManager.diffculities]
	#根据持续回合数进行补正
	rate = min(70, rate + max(0,(bf.turns()-5)*3));
	var actor = ActorHelper.actor(actorId)
	var wa = DataManager.get_war_actor(actorId)
	var enemy:War_Actor = wa.get_battle_enemy_war_actor();
	var enemyActor = enemy.actor()
	
	var states = bf.get_attacker_state()
	if actorId == bf.get_defender_id():
		states = bf.get_defender_state()

	var actorSoldiers = bf.get_battle_sodiers(actorId)
	var emenySoldiers = bf.get_battle_sodiers(enemy.actorId)
	
	var checkKey = "白兵.AI行为变更判断.{0}".format([actorId])
	var checkTurn = DataManager.get_env_int(checkKey, 0)
	if checkTurn >= bf.turns():
		# 如果本回合已经检验过，则不再验证
		return states
	DataManager.set_env(checkKey, bf.turns())

	# 挑战难度优先动作
	var ret = think_about_priored_order_ng(wa, enemy)
	if not ret.empty():
		return ret

	# 究极难度，文官被突脸，懂得后撤
	if DataManager.diffculities >= 3:
		#究极及以上难度
		if actorId == bf.get_defender_id() \
			and not bf.is_terrian_city() \
			and actor.get_wisdom() >= 70 \
			and enemyActor.get_power() >= actor.get_power() + 20 \
			and actorSoldiers > 900 \
			and actor.get_hp() >= 15:
			#文官被攻击时，只要体力足够，尽可能保留兵力撤退
			if Global.get_rate_result(rate):
				states["将"] = "后退"

		var battle_unit:Battle_Unit = wa.battle_actor_unit()
		if battle_unit == null:
			return states
		var side_dir:Vector2 = battle_unit.get_side();
		
		#检查是不是已经完全没有退路了
		var is_around = false;
		var check_v = [];
		if(side_dir.x>0):#如果在右边
			check_v =[[side_dir],[Vector2.UP,Vector2(1,-1)],[Vector2.DOWN,Vector2(1,1)]];
		else:
			check_v =[[side_dir],[Vector2.UP,Vector2(-1,-1)],[Vector2.DOWN,Vector2(-1,1)]];
		var all_yes = true;
		for p_list in check_v:
			var on_yes = false;
			for sd in p_list:
				var ounit = DataManager.get_battle_unit_by_position(sd+battle_unit.unit_position);
				if(ounit!=null && !ounit.disabled && ounit.leaderId!=actorId):
					on_yes = true;
					break;
			if(!on_yes):
				all_yes = false;
				break;
		if(all_yes):
			is_around = true;
		
		#判断敌将有无使用咒缚
		if enemy.get_buff("咒缚")["回合数"] > 0 or is_around:
			for k in states:
				if states[k] == "后退":
					states[k] = "待机"
			return states
	
	if bf.turns() < 5:
		return states
	rate = retreat_rates[DataManager.diffculities]

	# 补丁：如果是挑战难度太守府，防守方是不允许撤退的
	if DataManager.diffculities >= 3\
		and bf.get_terrian_cn() == "太守府"\
		and actorId == bf.get_defender_id():
		rate = 0

	#自身兵力<200
	if actorSoldiers < 200:
		if bf.turns() > 30 and actorId == bf.get_attacker_id():
			# 久战不克，僵持住了，退
			for k in states:
				states[k] = "后退"
			return states
		#自身兵力+400<敌方兵力
		if actorSoldiers + 400 < emenySoldiers:
			#AI概率后退
			if Global.get_rate_result(rate):
				for k in states:
					states[k] = "后退"
	
	if states["将"] != "后退":
		#除武将外，全员前进
		for k in states:
			states[k] = "前进"
		states["将"] = "待机"

		if actorId == bf.get_defender_id() and bf.is_terrian_city():
			if emenySoldiers + 400 >= actorSoldiers or emenySoldiers >= 200:
				for k in states:
					if k == "将":
						continue
					states[k] = "前进"
				states["弓"] = "待机"
			if emenySoldiers < 400:
				for k in states:
					if k == "将":
						continue
					states[k] = "前进"
		else:
			#非城类战斗，主将体武胆之和210+才有概率前进
			var score = actor.get_hp()+actor.get_courage()+actor.get_power()
			if score >= 210 and Global.get_rate_result(60):
				states["将"] = "前进"
	else:
		# 武将已经在后退
		if DataManager.diffculities >= 2:
			if Global.get_rate_result(rate):
				#AI武将反复横跳的原因：判断对方武比自己低20，且自己体>=40就有一定概率从后退改前进
				if enemyActor.get_power() + 20 <= actor.get_power() and actor.get_hp() >= 40:
					for k in states:
						states[k] = "前进"
	
	if DataManager.diffculities >= 3:
		if Global.get_rate_result(rate):
			if actorSoldiers == 0 and emenySoldiers == 0:
				if actor.get_power() + actor.get_hp() < enemyActor.get_power() + enemyActor.get_hp() \
					or actor.get_hp() + 20 < enemyActor.get_hp():
					states["将"] = "后退"
				elif bf.turns() > 20:
					states["将"] = "前进"
	return states

#--------战术执行------------
func think_about_tactic(actorId:int)->bool:
	var wa = DataManager.get_war_actor(actorId)
	if wa == null or not wa.can_use_tactic():
		return false
	var enemy = wa.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	var actor_unit = wa.battle_actor_unit()
	if actor_unit == null:
		return false

	var bf = DataManager.get_current_battle_fight()

	var states = {}
	var enemy_states = {}
	if actorId == bf.get_attacker_id():
		states = bf.get_attacker_state()
		enemy_states = bf.get_defender_state()
	elif actorId == bf.get_defender_id():
		states = bf.get_defender_state()
		enemy_states = bf.get_attacker_state()
	else:
		return false

	var it = Global.load_script(DataManager.mod_path+"sgz_script/battle/ITactic.gd")
	var tactics = Array(it.get_actor_tactic(actorId, false))
	if tactics.empty():
		return false
	
	var actor = ActorHelper.actor(wa.actorId)
	var enemy_actor = ActorHelper.actor(enemy.actorId)
	
	if actor.get_hp() < 50:
		tactics.erase("挑衅")
	elif actor.get_hp() + actor.get_power() <= enemy_actor.get_hp() + enemy_actor.get_power():
		tactics.erase("挑衅")

	if DataManager.get_env_int("白兵.拒绝单挑") == actorId:
		#AI拒绝过挑衅，不会再主动发起单挑
		tactics.erase("挑衅")

	if DataManager.battle_unit_type_hp(actorId, "弓") <= 0 \
		and actor_unit.get_shoot_distance() <= 0:
		tactics.erase("强弩")
		tactics.erase("火矢")
	
	var should_call_stop = false;
	# 攻方才喜欢用咒缚
	if actorId == bf.get_attacker_id() \
		and DataManager.diffculities >= 3 \
		and actor.get_power() >= enemy_actor.get_power() + 20 \
		and bf.get_units_state(enemy.actorId, "将") == "后退" \
		and tactics.has("咒缚"):
		#敌人后退，主动释放咒缚
		should_call_stop = true
	
	if should_call_stop:
		tactics = ["咒缚"]
	else:
		tactics.erase("咒缚")

	# 守城战，能用火矢就用火矢，且不挑衅
	if actorId == bf.get_defender_id() and bf.is_terrian_city():
		tactics.erase("挑衅")
		if tactics.has("火矢"):
			tactics = ["火矢"]

	# 我方足够强且敌方兵力少，无须普通战术
	if DataManager.diffculities > 3 \
		and actor.get_power() >= enemy_actor.get_power() + 20 \
		and enemy_actor.get_soldiers() <= 200:
		tactics.erase("士气向上")
		tactics.erase("火矢")
		tactics.erase("强弩")
		tactics.append("咒缚")

	if tactics.empty():
		return false
	tactics.shuffle()
	
	DataManager.common_variable["值"] = tactics[0]
	return true

#---------尝试主动技-----------
func think_about_active_skill(actorId:int)->bool:
	for skill in SkillHelper.get_actor_active_skills(actorId):
		for effect in SkillHelper.get_skill_effects(actorId, skill, ["主动"]):
			var gd = Global.load_script(effect.path)
			gd.actorId = actorId
			if not gd.check_AI_perform():
				continue
			# 小战场的仙术无效，在发动前阻止
			if skill.has_feature("仙") \
				and skill.has_feature("对敌"):
				var wa = DataManager.get_war_actor(actorId)
				var enemy = null if wa == null else wa.get_battle_enemy_war_actor()
				if enemy != null and enemy.actor().get_equip_feature_max("仙术无效") > 0:
					var msg = "旁门左道，于我皆为虚妄！\n（{0}发动【{1}】失败".format([
						wa.get_name(), skill.name,
					])
					enemy.attach_free_dialog(msg, 0, 30000)
					SkillHelper.set_skill_cd(30000, effect.id, actorId, 99999, skill.name)
					return false
			var ske = effect.create_ske_for(actorId)
			SkillHelper.save_skill_effectinfo(ske)
			LoadControl.load_script(effect.path)
			FlowManager.add_flow("effect_{0}_AI_start".format([effect.id]))
			return true
	return false

func think_about_priored_order_ng(wa:War_Actor, enemy:War_Actor)->Dictionary:
	var bf = DataManager.get_current_battle_fight()
	if DataManager.diffculities < 4:
		return {}
	var states = bf.get_attacker_state()
	if wa.actorId == bf.get_defender_id():
		states = bf.get_defender_state()
	# 挑战难度，守城门，弓兵第二回合前进，第三回合待机
	if bf.get_terrian_cn() == "城门" and wa.actorId == bf.get_defender_id():
		if bf.turns() == 2:
			states["将"] = "待机"
			states["弓"] = "前进"
			return states
		elif bf.turns() == 3:
			states["将"] = "待机"
			states["弓"] = "待机"
			return states
	# 以下暂时废弃
	return {}
	# 如果武将在可被弓兵攻击到的位置待机，尝试摆脱
	var bu = wa.battle_actor_unit()
	if bu == null or bu.disabled:
		return {}
	var shootingThreaten = false
	var rng = 5
	if enemy.get_buff("强弩")["回合数"] > 0:
		rng = 7
	for dir in StaticManager.NEARBY_DIRECTIONS:
		for x in range(1, rng):
			var pos = bu.unit_position + dir * x
			var target = DataManager.get_battle_unit_by_position(pos)
			if target == null or target.disabled:
				continue
			if target.leaderId == wa.actorId:
				break
			if target.leaderId == enemy.actorId and target.shootable(bu):
				shootingThreaten = true
				break
		if shootingThreaten:
			break
	if shootingThreaten:
		if states["将"] != "后退":
			# 全军前进
			for k in states:
				states[k] = "前进"
			return states
	else:
		# 没有弓箭威胁时，检查武将位置是否过于靠前
		var tooFar = false
		if bu.get_side().x < 0 and bu.unit_position.x > 2:
			tooFar = true
		if bu.get_side().x > 0 and bu.unit_position.x < 13:
			tooFar = true
		if states["将"] != "前进" and tooFar:
			states["将"] = "后退"
			return states
		if states["将"] == "后退" and not tooFar:
			states["将"] = "待机"
			return states
	return {}
