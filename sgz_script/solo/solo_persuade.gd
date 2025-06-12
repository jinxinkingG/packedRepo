extends Resource
const view_model_name = "单挑-玩家-步骤";

#01-休想,02-回到白兵,03-回到大战场,04-加入我方
const PERSUADE_RESULTS:Array = [
	#本方知+德>=180
	[
		#目标忠>=80
		[
			#目标体>=80
			[01,01,01,01,01,01,01,01],
			#50<=目标体<80
			[01,01,01,01,01,01,01,01],
			#目标体<50
			[01,01,01,01,02,02,02,02],
		],
		#50<=目标忠<80
		[
			#目标体>=80
			[01,01,01,01,01,01,01,02],
			#50<=目标体<80
			[01,01,01,01,01,01,01,01],
			#目标体<50
			[01,01,01,01,02,02,03,03],
		],
		#目标忠<50
		[
			#目标体>=80
			[01,01,01,01,01,01,04,04],
			#50<=目标体<80
			[01,01,03,03,04,04,04,04],
			#目标体<50
			[02,02,02,02,04,04,04,04],
		]
	],
	#130<=本方知+德<180
	[
		#目标忠>=80
		[
			#目标体>=80
			[01,01,01,01,01,01,01,01],
			#50<=目标体<80
			[01,01,01,01,01,01,02,02],
			#目标体<50
			[01,01,01,01,01,01,02,02],
		],
		#50<=目标忠<80
		[
			#目标体>=80
			[01,01,01,01,01,01,01,01],
			#50<=目标体<80
			[01,01,01,01,02,02,03,03],
			#目标体<50
			[01,01,01,01,02,02,02,02],
		],
		#目标忠<50
		[
			#目标体>=80
			[01,01,01,01,03,03,04,04],
			#50<=目标体<80
			[01,01,03,03,03,03,04,04],
			#目标体<50
			[01,01,03,03,04,04,04,04],
		]
	],
	#本方知+德<130
	[
		#目标忠>=80
		[
			#目标体>=80
			[01,01,01,01,01,01,01,01],
			#50<=目标体<80
			[01,01,01,01,01,01,01,01],
			#目标体<50
			[01,01,01,01,02,02,02,02],
		],
		#50<=目标忠<80
		[
			#目标体>=80
			[01,01,01,01,01,01,01,01],
			#50<=目标体<80
			[01,01,02,02,02,02,03,03],
			#目标体<50
			[01,01,02,02,03,03,03,03]
		],
		#目标忠<50
		[
			#目标体>=80
			[01,01,01,01,04,04,04,04],
			#50<=目标体<80
			[01,01,02,02,04,04,04,04],
			#目标体<50
			[01,01,04,04,04,04,04,04]
		]
	]
]


#说服
func _init() -> void:
	LoadControl.view_model_name = view_model_name;
	FlowManager.bind_import_flow("solo_persuade",self,"solo_persuade");
	FlowManager.bind_import_flow("solo_persuade_1",self,"solo_persuade_1");
	FlowManager.bind_import_flow("solo_persuade_2",self,"solo_persuade_2");
	FlowManager.bind_import_flow("solo_persuade_3_join_us",self,"solo_persuade_3_join_us");

func _input_key(delta: float):
	var bf = DataManager.get_current_battle_fight()
	var scene_solo:Control = SceneManager.current_scene();
	var bottom = SceneManager.lsc_menu;
	match LoadControl.get_view_model():
		101:
			Global.wait_for_confirmation("solo_persuade_2")
		102:
			if not Global.wait_for_confirmation(""):
				return
			var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
			var actorId = DataManager.solo_actor_by_side(side);
			var war_actor = DataManager.get_war_actor(actorId);
			var war_enrmy = war_actor.get_battle_enemy_war_actor();
			var enemyActor = ActorHelper.actor(war_enrmy.actorId)
			var result = int(DataManager.common_variable["结果"]);
			match result:
				1:#休想
					FlowManager.add_flow("solo_turn_end");
				2:#回到白兵
					bf.set_unit_state(war_enrmy.actorId, {"将": "后退"})
					FlowManager.add_flow("solo_run_end");
				3:#回到大战场
					bf.loserId = war_enrmy.actorId
					bf.lostType = BattleFight.ResultEnum.ActorRetreat
					FlowManager.add_flow("solo_run_end");
				4:#加入我方
					var enemy_unit_actor = war_enrmy.battle_actor_unit();
					if war_enrmy.actor_surrend_to(war_actor.wvId):
						enemyActor.set_loyalty(max(10,79-enemyActor.get_loyalty()));#投降忠赋值
						#下跪投降，算到主动投诚里，大战场保留方块
						enemy_unit_actor.is_surrend = true;
						FlowManager.add_flow("solo_persuade_3_join_us");
					else:
						FlowManager.add_flow("solo_turn_end");
		103:#确认对方投降了
			Global.wait_for_confirmation("solo_run_end")
	return

func solo_persuade():
	LoadControl.set_view_model(100);
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no]
	var actorId = DataManager.solo_actor_by_side(side)
	var wa = DataManager.get_war_actor(actorId)
	var enemy = wa.get_battle_enemy_war_actor()
	var result = solo_persuade_result(wa, enemy)
	DataManager.set_env("结果", result)
	FlowManager.add_flow("solo_persuade_1")
	return

func solo_persuade_1():
	LoadControl.set_view_model(101);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side)
	var wa = DataManager.get_war_actor(actorId)
	var target = wa.get_battle_enemy_war_actor()
	var msg = ""
	var mood = 2
	var result = DataManager.get_env_int("结果")
	match result:
		1:#休想
			msg = "汝等终将败于我军\n何不趁早投降？"
		2:#回到白兵
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "为此等君主赌上性命\n非明智之举\n将军不如早退"
			else:
				msg = "将军身躯已不可再战\n请勿做无谓的抵抗"
		3:#回到大战场
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "为此等君主赌上性命\n非明智之举\n将军不如早退"
			else:
				msg = "将军身躯已不可再战\n请勿做无谓的抵抗"
		4:#加入我方
			msg = "将军乃当世英雄\n不想与将军为敌\n何不与吾等共图大事"
	SceneManager.show_solo_dialog(msg, actorId, mood)
	return

func solo_persuade_2():
	LoadControl.set_view_model(102);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var wa = DataManager.get_war_actor(actorId);
	var target = wa.get_battle_enemy_war_actor()
	var msg = ""
	var mood = 2
	var result = DataManager.get_env_int("结果")
	match result:
		1:#休想
			msg = "一派胡言！\n杀了你这兔崽子！"
			mood = 0;
		2:#回到白兵
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "……也有道理"
				mood = 3
			else:
				msg = "如此也好\n日后再分胜负"
		3:#回到大战场
			if target.actor().get_loyalty() < target.actor().get_hp():
				msg = "……也有道理"
				mood = 3
			else:
				msg = "如此也好\n日后再分胜负"
		4:#加入我方
			msg = "此亦天命\n吾愿效犬马之劳"
	SceneManager.show_solo_dialog(msg, target.actorId, mood)
	return

func solo_persuade_3_join_us():
	LoadControl.set_view_model(103);
	var scene_solo = SceneManager.current_scene();
	var side:String = DataManager.solo_sort[DataManager.solo_sort_no];
	var actorId = DataManager.solo_actor_by_side(side);
	var war_actor = DataManager.get_war_actor(actorId);
	var enemyActor = ActorHelper.actor(war_actor.get_battle_enemy_war_actor().actorId)
	if(war_actor.is_AI_use()):
		#AI就显示加入敌军
		SceneManager.show_confirm_dialog("{0}加入敌军".format([enemyActor.get_name()]));
	else:
		SceneManager.show_confirm_dialog("{0}加入我军".format([enemyActor.get_name()]));
	return

# 计算说服结果
# 原版算法
func solo_persuade_result(from:War_Actor, target:War_Actor)->int:
	if from == null or target == null:
		return 1
	var d12 = from.actor().get_wisdom() + from.actor().get_moral()
	var a = 0
	if d12 < 180:
		a += 1
	if d12 < 130:
		a += 1
	var b = 0
	var loy = target.actor().get_loyalty()
	if loy < 80:
		b += 1
	if loy < 50:
		b += 1
	var c = 0
	var hp = target.actor().get_hp()
	if hp < 65:
		c += 1
	if hp < 40:
		c += 1
	var results = Array(PERSUADE_RESULTS[a][b][c]).duplicate()
	results.shuffle()
	var result = results[0]
	if target.actor().get_loyalty() == 100 and result in [3,4]:
		result = 1
	return result
