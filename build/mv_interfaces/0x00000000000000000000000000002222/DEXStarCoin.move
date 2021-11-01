address 0x2222 {
module DEXStarCoin {

    use 0x1::Event;
    use 0x1::Token;
    use 0x2222::DEXStarCoin;

    struct DexDepositEvent has drop, store {
        from: address,
        to: address,
        token_code: Token::TokenCode,
        amount: u128,
        time: u64,
    }
    struct DexStarcoinPool<T0: store> has store, key {
        tokens: Token::Token<T0>,
        deposit_event: Event::EventHandle<DEXStarCoin::DexDepositEvent>,
        withdrawal_event: Event::EventHandle<DEXStarCoin::DexWithdrawalEvent>,
        transfer_event: Event::EventHandle<DEXStarCoin::DexTransferEvent>,
    }
    struct DexTransferEvent has drop, store {
        from: address,
        to: address,
        token_code: Token::TokenCode,
        amount: u128,
        time: u64,
    }
    struct DexWithdrawalEvent has drop, store {
        from: address,
        to: address,
        token_code: Token::TokenCode,
        amount: u128,
        time: u64,
    }
    struct ManagerChangeEvent has drop, store {
        manager: address,
        type: u8,
        time: u64,
    }
    struct ManagerList has store, key {
        managers: vector<address>,
        manager_change_event: Event::EventHandle<DEXStarCoin::ManagerChangeEvent>,
    }

    // NOTE: Functions are 'native' for simplicity. They may or may not be native in actuality.
    native public fun add_manager(a0: &signer, a1: address);
    native public fun delete_manager(a0: &signer, a1: address);
    native public fun deposit<T0: store>(a0: &signer, a1: u128);
    native public fun init_dex<T0: store>(a0: &signer);
    native public fun transfer<T0: store>(a0: &signer, a1: address, a2: u128);
    native public fun withdrawal<T0: store>(a0: &signer, a1: address, a2: u128);

}
}
