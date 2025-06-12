extends Resource

var iwa;

#AI-白兵战攻击宣言
func _init() -> void:
	iwa = Global.load_script(DataManager.mod_path+"sgz_script/war/IWar_Attack.gd")
	return

#获得可攻击的最佳目标{"目标":-1,"评分":0}
func best_attack_target(from_actorId:int)->Dictionary:
	var from_wa = DataManager.get_war_actor(from_actorId);
	var from_actor = ActorHelper.actor(from_actorId)
	var target_dic = {"目标":-1,"评分":0};
	
	#最终分数 = 效果数值*命中率%/所需的机动力
	var res = iwa.get_can_attack_actors(from_actorId)
	for t_actorId in res[0]:
		var to_wa = DataManager.get_war_actor(t_actorId);
		var to_actor = ActorHelper.actor(t_actorId)
		to_wa.battle_init(true);#初始化白兵数据，以能提前模拟白兵结果
		#战斗力=(士气+战术)*兵力/1000+武*体/100
		var tar_combat_power = (to_wa.battle_morale+to_wa.battle_tactic_point)* to_actor.get_soldiers()/1000.0+to_actor.get_hp()*to_actor.get_power()*4/100.0;
		#战斗力高的，评分反而低
		var score = min(30, from_actor.get_soldiers()*2/max(1,tar_combat_power))/max(1,iwa.get_attack_ap(from_actorId,t_actorId));
		if DataManager.endless_model:
			score += 50;
		if(score>target_dic["评分"] || target_dic["目标"]<0):
			target_dic["目标"]=t_actorId;
			target_dic["评分"]=score;
	
	return target_dic;
