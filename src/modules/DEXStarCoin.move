address 0x2222 {
module DEXStarCoin {
    use 0x1::Event;
    use 0x1::Account;
    use 0x1::Signer;
    use 0x1::Token;
    use 0x1::Vector;
    use 0x1::Timestamp;

    const DEX_STARCOIN_ADDRESS: address = @0x2222;

    //error
    const PERMISSION_DENIED: u64 = 200001;
    const MANAGER_NOT_EXIST: u64 = 210001;
    const DEX_POOL_NOT_EXIST: u64 = 220001;
    const AMOUNT_INVALID: u64 = 230001;
    const AMOUNT_NOT_ENOUGH: u64 = 230002;
    const AMOUNT_DEX_NOT_ENOUGH: u64 = 230003;


    //******************** body ********************
    // contract token pool
    struct DexStarcoinPool<DexToken: store> has key, store {
        tokens: Token::Token<DexToken>,
        //custom deposit withdrawal event : current chain
        deposit_event: Event::EventHandle<DexDepositEvent>,
        //account or manager withdrawal event : current chain
        withdrawal_event: Event::EventHandle<DexWithdrawalEvent>,
        //account or manager transfer event : across chain 
        transfer_event: Event::EventHandle<DexTransferEvent>,
    }

    //multiple manager's address
    struct ManagerList has key, store {
        managers: vector<address>,
        manager_change_event: Event::EventHandle<ManagerChangeEvent>,
    }

    //******************** event ********************
    //manager change Event
    struct ManagerChangeEvent has drop, store {
        manager: address,
        //1=add, 2=delete
        type: u8,
        time: u64,
    }

    //custom deposit event 
    struct DexDepositEvent has drop, store {
        //from user address
        from: address,
        //target user address
        to: address,
        token_code: Token::TokenCode,
        amount: u128,
        time: u64,
    }

    //custom withdrawal event 
    struct DexWithdrawalEvent has drop, store {
        //from user address
        from: address,
        //target user address
        to: address,
        withdrawalId: u128,
        token_code: Token::TokenCode,
        amount: u128,
        time: u64,
    }

    //account or manager transfer event 
    struct DexTransferEvent has drop, store {
        //from user address
        from: address,
        //target user address
        to: address,
        withdrawalId: u128,
        token_code: Token::TokenCode,
        amount: u128,
        time: u64,
    }

    //******************** transaction ********************
    //init dex starcoin pool and manager list
    public fun init_dex<DexToken: store>(account: &signer) {
        //Permission check
        let account_address = Signer::address_of(account);
        assert(DEX_STARCOIN_ADDRESS == account_address, PERMISSION_DENIED);

        // init dex starcoin pool
        if (!exists<DexStarcoinPool<DexToken>>(account_address)) {
            move_to(account, DexStarcoinPool<DexToken> {
                tokens: Token::zero(),
                deposit_event: Event::new_event_handle<DexDepositEvent>(account),
                withdrawal_event: Event::new_event_handle<DexWithdrawalEvent>(account),
                transfer_event: Event::new_event_handle<DexTransferEvent>(account),
            });
        };

        // init manager list
        if (!exists<ManagerList>(account_address)) {
            move_to(account, ManagerList {
                managers: Vector::empty(),
                manager_change_event: Event::new_event_handle<ManagerChangeEvent>(account),
            });
        };
    }

    //add a new manager
    public fun add_manager(account: &signer, user_address: address) acquires ManagerList {
        //Permission check
        let account_address = Signer::address_of(account);
        assert(DEX_STARCOIN_ADDRESS == account_address, PERMISSION_DENIED);

        assert(exists<ManagerList>(DEX_STARCOIN_ADDRESS), MANAGER_NOT_EXIST);

        let manager_list = borrow_global_mut<ManagerList>(DEX_STARCOIN_ADDRESS);
        let has_exist = false;
        let len = Vector::length(&manager_list.managers);
        if (len > 0) {
            let manager_tmp = Vector::borrow_mut(&mut manager_list.managers, 0);
            let k = 0;
            while (k < len) {
                if (user_address == *manager_tmp) {
                    has_exist = true;
                    break
                };
                if ((k + 1) == len) {
                    break
                };
                k = k + 1;
                manager_tmp = Vector::borrow_mut(&mut manager_list.managers, k);
            };
        };

        if (!has_exist) {
            Vector::push_back(&mut manager_list.managers, user_address);
            Event::emit_event(
                &mut manager_list.manager_change_event,
                ManagerChangeEvent {
                    manager: user_address,
                    //1=add, 2=delete
                    type: 1u8,
                    time: Timestamp::now_milliseconds(),
                }
            );
        };
    }

    //delete a manager
    public fun delete_manager(account: &signer, user_address: address)  acquires ManagerList {
        //Permission check
        let account_address = Signer::address_of(account);
        assert(DEX_STARCOIN_ADDRESS == account_address, PERMISSION_DENIED);

        assert(exists<ManagerList>(DEX_STARCOIN_ADDRESS), MANAGER_NOT_EXIST);

        let manager_list = borrow_global_mut<ManagerList>(DEX_STARCOIN_ADDRESS);
        let len = Vector::length(&manager_list.managers);
        let has_exist = false;
        let k = 0;
        if (len > 0) {
            let manager_tmp = Vector::borrow_mut(&mut manager_list.managers, 0);
            while (k < len) {
                if (user_address == *manager_tmp) {
                    has_exist = true;
                    break
                };
                if ((k + 1) == len) {
                    break
                };
                k = k + 1;
                manager_tmp = Vector::borrow_mut(&mut manager_list.managers, k);
            };
        };

        if (has_exist) {
            let _ = Vector::remove<address>(&mut manager_list.managers, k);
            Event::emit_event(
                &mut manager_list.manager_change_event,
                ManagerChangeEvent {
                    manager: user_address,
                    //1=add, 2=delete
                    type: 2u8,
                    time: Timestamp::now_milliseconds(),
                }
            );
        };
    }

    //user deposit
    public fun deposit<DexToken: store>(user: &signer, amount: u128) acquires DexStarcoinPool {
        //check
        assert(amount > 0, AMOUNT_INVALID);
        assert(exists<DexStarcoinPool<DexToken>>(DEX_STARCOIN_ADDRESS), DEX_POOL_NOT_EXIST);

        let dex_token_pool = borrow_global_mut<DexStarcoinPool<DexToken>>(DEX_STARCOIN_ADDRESS);
        let deposit_token = Account::withdraw<DexToken>(user, amount);
        Token::deposit<DexToken>(&mut dex_token_pool.tokens, deposit_token);

        //send deposit event
        let user_address = Signer::address_of(user);
        Event::emit_event(
            &mut dex_token_pool.deposit_event,
            DexDepositEvent {
                //from user address
                from: user_address,
                //target user address
                to: user_address,
                token_code: Token::token_code<DexToken>(),
                amount: amount,
                time: Timestamp::now_milliseconds(),
            }
        );
    }

    //account or manager transfer : across chain
    public fun transfer<DexToken: store>(account: &signer, user_address: address, amount: u128, withdrawalId: u128) acquires DexStarcoinPool, ManagerList {
        let account_address = Signer::address_of(account);
        //check and transfer 
        predicate_withdrawal<DexToken>(account_address, user_address, amount);

        let dex_token_pool = borrow_global_mut<DexStarcoinPool<DexToken>>(DEX_STARCOIN_ADDRESS);
        //send transfer event
        Event::emit_event(
            &mut dex_token_pool.transfer_event,
            DexTransferEvent {
                //from user address
                from: account_address,
                //target user address
                to: user_address,
                withdrawalId: withdrawalId,
                token_code: Token::token_code<DexToken>(),
                amount: amount,
                time: Timestamp::now_milliseconds(),
            }
        );
    }

    //account or manager withdrawal : current chain
    public fun withdrawal<DexToken: store>(account: &signer, user_address: address, amount: u128, withdrawalId: u128) acquires DexStarcoinPool, ManagerList {
        let account_address = Signer::address_of(account);
        //check and withdrawal
        predicate_withdrawal<DexToken>(account_address, user_address, amount);

        let dex_token_pool = borrow_global_mut<DexStarcoinPool<DexToken>>(DEX_STARCOIN_ADDRESS);
        //send withdrawal event
        Event::emit_event(
            &mut dex_token_pool.withdrawal_event,
            DexWithdrawalEvent {
                //from user address
                from: account_address,
                //target user address
                to: user_address,
                withdrawalId: withdrawalId,
                token_code: Token::token_code<DexToken>(),
                amount: amount,
                time: Timestamp::now_milliseconds(),
            }
        );
    }

    //predicate and transfer/withdrawal
    fun predicate_withdrawal<DexToken: store>(account_address: address, user_address: address, amount: u128) acquires DexStarcoinPool, ManagerList {
        //check
        assert(amount > 0, AMOUNT_INVALID);
        assert(exists<DexStarcoinPool<DexToken>>(DEX_STARCOIN_ADDRESS), DEX_POOL_NOT_EXIST);

        let has_dex_account = DEX_STARCOIN_ADDRESS == account_address;

        let has_manager_account = false;
        if (exists<ManagerList>(DEX_STARCOIN_ADDRESS)) {
            let manager_list = borrow_global_mut<ManagerList>(DEX_STARCOIN_ADDRESS);
            let len = Vector::length(&manager_list.managers);
            let k = 0;
            if (len > 0) {
                let manager_tmp = Vector::borrow_mut(&mut manager_list.managers, 0);
                while (k < len) {
                    if (account_address == *manager_tmp) {
                        has_manager_account = true;
                        break
                    };
                    if ((k + 1) == len) {
                        break
                    };
                    k = k + 1;
                    manager_tmp = Vector::borrow_mut(&mut manager_list.managers, k);
                };
            };
        };

        //no permission transfer/withdrawal
        assert(has_dex_account || has_manager_account, PERMISSION_DENIED);

        let dex_token_pool = borrow_global_mut<DexStarcoinPool<DexToken>>(DEX_STARCOIN_ADDRESS);
        let dex_balance = Token::value<DexToken>(&dex_token_pool.tokens);

        //predicate dex balance greater than amount
        assert(dex_balance >= amount, AMOUNT_DEX_NOT_ENOUGH);

        let withdrawal_token = Token::withdraw<DexToken>(&mut dex_token_pool.tokens, amount);
        Account::deposit<DexToken>(user_address, withdrawal_token);
    }
}
}