address 0x1111 {
module DEXScripts {

    // NOTE: Functions are 'native' for simplicity. They may or may not be native in actuality.
    native public(script) fun add_manager(a0: signer, a1: address);
    native public(script) fun delete_manager(a0: signer, a1: address);
    native public(script) fun deposit<T0: store>(a0: signer, a1: u128);
    native public(script) fun init_dex<T0: store>(a0: signer);
    native public(script) fun transfer<T0: store>(a0: signer, a1: address, a2: u128);
    native public(script) fun withdrawal<T0: store>(a0: signer, a1: address, a2: u128);

}
}
