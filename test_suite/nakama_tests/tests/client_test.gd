extends "res://base_test.gd"

func setup():
	var username = str(randi_range(1000, 100000))
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	# POST
	var auth: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null) or assert_false(auth.value.has_expired()):
		return
	var session: NakamaSession = auth.value
	# PUT
	var update: NakamaResult = await client.update_account_async(session, username)
	if assert_cond(update.error == null):
		return
	# GET
	var account: NakamaResult = await client.get_account_async(session)
	if assert_cond(account.error == null):
		return
	if assert_cond(account.value.user.username == username):
		return
	# POST - DELETE
	var group: NakamaResult = await client.create_group_async(session, "MyGroupName3")
	if assert_cond(group.error == null):
		return
	var delete: NakamaResult = await client.delete_group_async(session, group.value.id)
	if assert_cond(delete.error == null):
		return
	done()
	return

func _process(_delta):
	assert_time(3)
