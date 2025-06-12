extends "effect_10000.gd"

#郡守锁定技
#【郡守】内政，太守锁定技。同城其他武将执行内政开发时（包括，开发土地，产业，人口，防灾），你的经验+150

const EFFECT_ID = 10061

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	if ske.actorId == self.actorId:
		# 自己不触发
		return false
	var cityId = get_working_city_id()
	if cityId < 0:
		return false
	var city = clCity.city(cityId)
	if city.get_leader_id() != self.actorId:
		return false
	var action = str(get_env("内政.命令"))
	if not action in ["开发", "防灾"]:
		return false
	ActorHelper.actor(self.actorId).add_exp(150)
	return false
