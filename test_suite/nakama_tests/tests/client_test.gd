extends "res://base_test.gd"

func setup() -> void:
	var username := str(randi_range(1000, 100000))
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)
	# One call per HTTP method: POST, PUT, GET, and DELETE.
	var auth: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null):
		return
	var session: NakamaSession = auth.value
	if assert_false(session.has_expired()):
		return
	var update: NakamaResult = await client.update_account_async(session, username)
	if assert_cond(update.error == null):
		return
	var account: NakamaResult = await client.get_account_async(session)
	if assert_cond(account.error == null):
		return
	var user: NakamaTypes.User = account.value.user
	if assert_cond(user.username == username):
		return
	var group: NakamaResult = await client.create_group_async(session, "MyGroupName3")
	if assert_cond(group.error == null):
		return
	var created: NakamaTypes.Group = group.value
	var delete: NakamaResult = await client.delete_group_async(session, created.id)
	if assert_cond(delete.error == null):
		return
	done()
	return

func _process(_delta: float) -> void:
	assert_time(3)
