extends "effect_30002.gd" # 直接继承冲阵，修改效果

#冲魄锁定技 #武将增强
#【冲魄】小战场,锁定技。你或对方处于[咒缚]状态时，你每次攻击，将对攻击范围内的所有敌兵，依次攻击1次，每次伤害递减20%，伤害下限为20%。

func get_attack_tag(marked:Array, attacked:int)->String:
	return "冲阵"

func skill_available()->bool:
	# 让位于上位技能
	if SkillHelper.actor_has_skills(actorId, ["冲阵"]):
		return false
	if me != null and me.get_buff("咒缚")["回合数"] > 0:
		return true
	var enemy = me.get_battle_enemy_war_actor()
	if enemy != null and enemy.get_buff("咒缚")["回合数"] > 0:
		return true
	return false

func get_loss_rate()->float:
	return 0.2
