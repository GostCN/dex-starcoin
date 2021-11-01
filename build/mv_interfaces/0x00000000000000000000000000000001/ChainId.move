address 0x1 {
module ChainId {

    struct ChainId has key {
        id: u8,
    }

    // NOTE: Functions are 'native' for simplicity. They may or may not be native in actuality.
    native public fun get(): u8;
    native public fun initialize(a0: &signer, a1: u8);

}
}
