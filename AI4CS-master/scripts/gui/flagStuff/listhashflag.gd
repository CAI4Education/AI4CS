extends Node
class_name ListHashFlag

# dizionario: challenge_name -> hash
const VALID_HASHES := {
	"challenge1": "4171647cf661bb4915262d7a329a5c0757fc051edc822dddd5bbf9a9f1cfc874",
	"challenge2": "e7bb553fdc3bad2d87017427ff816eaad3c366a180df4b58cb8a1acdf0c2447e",
	"challenge3": "bcdb638a75ac849f72e7cbdb938088a1c3d753cf5f3bfe3643b5b908bc56ee85",
	"challenge4": "f794586245e8b2c427cdabdf4de984d2c030fcae6149e3410b8241d88ab668fa",
	"challenge5": "90b727f44202a5520639eb9ef354017eef2883714d62c560057fde7017979482",
	"challenge6": "e6cee59ce923998d01629a4f94cc8fc41954324a63bdffef61d3a274242ae81c",
	"challenge7": "512b772e7e00c7aeaa880b84f3262b7f7e64e5a17d9ba799d0fd8da835543a87",
	"challenge8": "bea6882e612b093e49abe0700da0a1e5ecabc99bffc3b96aed74b67026a73b0f",
	"challenge9": "13d83962e78fc219018c03ddfe6657d1e25dc63ceb89dd5e62793c704515b425",
	"challenge10": "a5c71abc0dd7632410ace7181cc52e69b4bd79738d162d228b234ce9e3c9425e",
	"challenge11": "8794be5a5d0cb335feb4121f48a04192c4e55799b1314961eefa7a3e0d59ea26",
	"challenge12": "402c34053dcdfc8bc7e21efef42be686844a8ebab6366b0fa2f21906d88820ca",
	"challenge13": "1c2dd327e7554898ae929210d066fe236afe7a1966bf3e3c9db8f74774507d5b",
	"challenge14": "3ef162822a6d263c8ee50e2081b17d3b290d7fb7b2b601891987b570a49e83fe",
	"challenge16": "0100539ce99ea2a4cee1cc2822d31aa892f75a87e5364d44a43c861293a06967",
	"challenge15": "0a6ec33056b04dcd92e7f103b5d8bd0e964fae3285a278f1eee0168d6de7ae22",
	"challenge17": "63a5c4589fb6a0c4c9f2e4f9d7e26f42729441e3aa5cd08e523d4f3dacaa6585",
	"challenge18": "97f474079e678bf3f3f25778a4470e1a061b433a1bbe1efe7f6a704d7b2ef286",
	"challenge19": "1949a6386dec55ec0a1451b3c7b446d1dcc4169f6a1fd8e37e3853a2fb3c9b1f",

}

static func is_valid(challenge_name: String, hash: String) -> bool:
	if not VALID_HASHES.has(challenge_name):
		return false
	return VALID_HASHES[challenge_name] == hash
