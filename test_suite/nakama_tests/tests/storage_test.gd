extends "res://base_test.gd"

const COLLECTION = "ACollection"
const K1 = "Question"
const K2 = "Answer"
const V1 = {"question": "Ultimate question"}
const V2 = {"answer": "42"}

func setup():
	var client := Nakama.new(NakamaConfig.SERVER_KEY, NakamaConfig.HOST, NakamaConfig.PORT, NakamaConfig.SCHEME)

	var auth: NakamaResult = await client.authenticate_custom_async("MyIdentifier")
	if assert_cond(auth.error == null):
		return
	var session: NakamaSession = auth.value

	var objs: Array[NakamaTypes.WriteStorageObject] = []
	for pair in [[K1, V1], [K2, V2]]:
		var obj := NakamaTypes.WriteStorageObject.new(COLLECTION, pair[0], JSON.stringify(pair[1]), "", 1, 1)
		objs.append(obj)
	var write: NakamaResult = await client.write_storage_objects_async(session, objs)
	if assert_cond(write.error == null):
		return

	var objs_ids: Array[NakamaTypes.ReadStorageObjectId] = []
	var delete_ids: Array[NakamaTypes.DeleteStorageObjectId] = []
	for a in write.value.acks:
		var read_id := NakamaTypes.ReadStorageObjectId.new(a.collection, a.key, a.user_id)
		objs_ids.append(read_id)
		var delete_id := NakamaTypes.DeleteStorageObjectId.new(a.collection, a.key, a.version)
		delete_ids.append(delete_id)

	var read: NakamaResult = await client.read_storage_objects_async(session, objs_ids)
	if assert_cond(read.error == null):
		return
	if assert_equal(read.value.objects.size(), 2):
		return
	if assert_equal(read.value.objects[0].collection, COLLECTION):
		return
	if assert_cond(read.value.objects[0].key in [K1, K2]):
		return
	if assert_cond(JSON.stringify(JSON.parse_string(read.value.objects[0].value)) in [JSON.stringify(V1), JSON.stringify(V2)]):
		return

	# Delete one
	var del: NakamaResult = await client.delete_storage_objects_async(session, [delete_ids[0]])
	if assert_cond(del.error == null):
		return

	# Confirm that one was deleted
	var read2: NakamaResult = await client.read_storage_objects_async(session, objs_ids)
	if assert_cond(read2.error == null):
		return
	if assert_equal(read2.value.objects.size(), 1):
		return
	if assert_equal(read2.value.objects[0].collection, COLLECTION):
		return
	if assert_equal(read2.value.objects[0].key, objs_ids[1].key):
		return
	if assert_cond(JSON.stringify(JSON.parse_string(read2.value.objects[0].value)) in [JSON.stringify(V1), JSON.stringify(V2)]):
		return
	done()
	return

func _process(_delta):
	assert_time(3)
