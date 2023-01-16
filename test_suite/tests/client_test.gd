extends "res://base_test.gd"

func setup():
	var username = str(randi_range(1000, 100000))
	var client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)
	# POST
	var session = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(session.is_valid()) or assert_cond(!session.is_expired()):
		return
	# PUT
	var update = await client.update_account_async(session, username)
	if assert_false(update.is_exception()):
		return
	# GET
	var account : NakamaAPI.ApiAccount = await client.get_account_async(session)
	if assert_false(account.is_exception()):
		return
	if assert_cond(account.user.username == username):
		return
	# POST - DELETE
	var group : NakamaAPI.ApiGroup = await client.create_group_async(session, "MyGroupName3")
	if assert_false(group.is_exception()):
		return
	var delete = await client.delete_group_async(session, group.id)
	if assert_false(delete.is_exception()):
		return
	# All good
	done()
	return

func _process(_delta):
	assert_time(3)
