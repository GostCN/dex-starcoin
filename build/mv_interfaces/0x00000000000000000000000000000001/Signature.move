address 0x1 {
module Signature {

    // NOTE: Functions are 'native' for simplicity. They may or may not be native in actuality.
    native public fun ed25519_validate_pubkey(a0: vector<u8>): bool;
    native public fun ed25519_verify(a0: vector<u8>, a1: vector<u8>, a2: vector<u8>): bool;

}
}
