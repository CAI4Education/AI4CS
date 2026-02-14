extends Node
class_name HashFlag

# Algoritmo è SHA256
static func compute(challenge_name: String, flag: String) -> String:
	var text := challenge_name + flag
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(text.to_utf8_buffer())
	var hash_bytes := ctx.finish()
	print(hash_bytes.hex_encode())
	return hash_bytes.hex_encode()
