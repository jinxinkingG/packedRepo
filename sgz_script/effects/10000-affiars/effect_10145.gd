extends "effect_10000.gd"

#流光主动技
#【流光】内政，君主主动技。你可铸一剑，名为「流光剑」，并装备给自身。游戏中限1次。

const EFFECT_ID = 10145
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const LIUGUANG_WEAPON_ID = 46  # 流光剑的ID

func effect_10145_start() -> void:
	# 不检查当前是否已经装备，依靠技能 CD 来控制
	# 如果用户用修改器或其他方式提前获取了流光剑，允许发动

	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	# 显示确认对话框
	var msg = "家祖志在天下\n吾当继之，岂在{0}一隅！\n铸剑以志".format([
		city.get_region()
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirm")
	return

func effect_10145_confirm() -> void:
	var cityId = get_working_city_id()

	# 换装流光剑
	var liuguang = clEquip.equip(LIUGUANG_WEAPON_ID, "武器")
	var switched = ske.change_actor_equip(cityId, liuguang)

	# 技能永久CD
	ske.affair_cd(99999)

	# 显示成功消息
	var msg = "此剑开锋之日，山海互换！\n（换装{0}\n（{1}已放入装备库".format([
		liuguang.name(), switched.name()
	])
	play_dialog(actorId, msg, 0, 2999)
	return
