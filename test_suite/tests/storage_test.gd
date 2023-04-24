extends "res://base_test.gd"

const COLLECTION = "ACollection"
const K1 = "Question"
const K2 = "Answer"
const V1 = {"question": "Ultimate question"}
const V2 = {"answer": "42"}

func setup():
	var username = str(randi_range(1000, 100000))
	var client = Nakama.create_client(Config.SERVER_KEY, Config.HOST, Config.PORT, Config.SCHEME)

	var session = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(session.is_valid()):
		return

	var objs = [
		NakamaWriteStorageObject.new(COLLECTION, K1, 1, 1, to_json(V1), ""),
		NakamaWriteStorageObject.new(COLLECTION, K2, 1, 1, to_json(V2), "")
	]
	var write : NakamaAPI.ApiStorageObjectAcks = await client.write_storage_objects_async(session, objs)
	if assert_false(write.is_exception()):
		return

	var objs_ids = []
	for a in write.acks:
		#var obj : NakamaAPI.ApiStorageObjectAck = a
		objs_ids.append(NakamaStorageObjectId.new(a.collection, a.key, a.user_id, a.version))

	var read : NakamaAPI.ApiStorageObjects = await client.read_storage_objects_async(session, objs_ids)
	if assert_false(read.is_exception()):
		return
	if assert_equal(read.objects.size(), 2):
		return
	if assert_equal(read.objects[0].collection, COLLECTION):
		return
	if assert_cond(read.objects[0].key in [K1, K2]):
		return
	if assert_cond(to_json(parse_json(read.objects[0].value)) in [to_json(V1), to_json(V2)]):
		return

	# Delete one
	var del = await client.delete_storage_objects_async(session, [objs_ids[0]])
	if assert_false(del.is_exception()):
		return

	# Confirm that one was deleted
	var read2 : NakamaAPI.ApiStorageObjects = await client.read_storage_objects_async(session, objs_ids)
	if assert_false(read2.is_exception()):
		return
	if assert_equal(read2.objects.size(), 1):
		return
	if assert_equal(read2.objects[0].collection, COLLECTION):
		return
	if assert_equal(read2.objects[0].key, objs_ids[1].key):
		return
	if assert_cond(to_json(parse_json(read2.objects[0].value)) in [to_json(V1), to_json(V2)]):
		return
	done()
	return

func _process(_delta):
	assert_time(3)

func to_json(value) -> String:
	return JSON.stringify(value)

func parse_json(value):
	var json = JSON.new()
	if json.parse(value) != OK:
		return null
	return json.get_data()
