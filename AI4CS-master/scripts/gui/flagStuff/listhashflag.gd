extends Node
class_name ListHashFlag

# dizionario: challenge_name -> hash
const VALID_HASHES := {
	"challenge1": "60c4f2320cbc60088468787d32620af7b28aa8beebe74c4d7a9b4a5946acaced",
	"challenge2": "26807f463aeca862de79b6d2c833ce3967149cb626970c29927f837d2165f3b7",
	"challenge3": "bfc79ef3329d56988909bfaf06330eb4f1bdd4cb4485086ab424fae8439f8d4e"
}

static func is_valid(challenge_name: String, hash: String) -> bool:
	if not VALID_HASHES.has(challenge_name):
		return false
	return VALID_HASHES[challenge_name] == hash
