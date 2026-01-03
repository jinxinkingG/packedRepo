extends "effect_20000.gd"

# 斧手大战场效果，包括回调
#【斧手】白刃战，锁定技。战争开始时，你有 500 {斧手}。白刃战主将被攻击，进入单挑时，若你的 {斧手} 数量大于 0，你率 {斧手} 掩护主将撤出战斗，并与敌将开始白刃战。每日限1次。

func on_trigger_20013() -> bool:
	var setting = ske.get_war_skill_val_int_array()
	if setting.size() != 2:
		setting = [1, 500]
	ske.set_war_skill_val(setting)
	return false

func on_trigger_20020() -> bool:
	var prevSkeData = DataManager.get_env_dict("战争.斧手.环境")
	var targetId = DataManager.get_env_int("战争.斧手.目标")
	DataManager.clear_common_variable(["战争.斧手."])
	if prevSkeData.empty() or targetId < 0:
		return false
	return true

func effect_20688_start() -> void:
	var msg = "刀斧手伺候！\n（【{0}】发起攻击".format([ske.skill_name])
	me.attach_free_dialog(msg, 0)
	start_battle_and_finish(actorId, ske.actorId)
	return
