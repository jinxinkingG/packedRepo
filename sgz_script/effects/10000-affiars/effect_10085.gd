extends "effect_10000.gd"

#养士内政锁定技部分 #获得标记
#【养士】内政&大战场，锁定技。你执行「市集开发」时，获得X个[士]标记（X=提升人口数/10），[士]标记上限为3000。战争中你可通过主动发动此技能，消耗指定数量的[士]，获得对应数量的兵力，但不能超过兵力上限。

const FLAG_ID = 10068
const FLAG_NAME = "士"
const FLAG_LIMIT = 3000

func on_trigger_10012() -> bool:
	if DataManager.get_env_str("内政.命令") != "开发":
		return false
	var cmd = DataManager.get_current_develop_command()
	if cmd.type != "人口":
		return false
	var flag = SkillHelper.get_skill_flags_number(10000, FLAG_ID, actorId, FLAG_NAME)
	var x = int(cmd.pop / 10)
	x = min(FLAG_LIMIT - flag, x)
	if x <= 0:
		return false
	SkillHelper.set_skill_flags(10000, FLAG_ID, actorId, FLAG_NAME, flag + x)
	var city = cmd.city()
	city.add_city_property("人口", -x)
	if DataManager.get_scene_actor_control(actorId) >= 0:
		var msg = "草莽之间，亦有义徒\n（{0}新增人口转化为「士」".format([x])
		city.attach_free_dialog(msg, actorId, 1)
	return false
