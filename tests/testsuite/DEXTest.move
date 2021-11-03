//! account: dummy, 0x2
//! sender:dummy
address dummy = {{dummy}};
module dummy::Dummy {
    use 0x1::Account;
    use 0x1::Token;

    struct ETH has copy, drop, store {}

    struct USDT has copy, drop, store {}

    struct SharedMintCapability<TokenType: store> has key, store {
        cap: Token::MintCapability<TokenType>,
    }

    struct SharedBurnCapability<TokenType> has key {
        cap: Token::BurnCapability<TokenType>,
    }

    public fun initialize<TokenType: store>(account: &signer) {
        Token::register_token<TokenType>(account, 9);
        Account::do_accept_token<TokenType>(account);
        let burn_cap = Token::remove_burn_capability<TokenType>(account);
        move_to(account, SharedBurnCapability<TokenType> { cap: burn_cap });
        let mint_cap = Token::remove_mint_capability<TokenType>(account);
        move_to(account, SharedMintCapability<TokenType> { cap: mint_cap });
    }

    public fun mint_token<TokenType: store>(account: &signer, amount: u128) acquires SharedMintCapability {
        let token = mint<TokenType>(amount);
        Account::deposit_to_self(account, token);
    }

    /// Burn the given token.
    public fun burn<TokenType: store>(token: Token::Token<TokenType>) acquires SharedBurnCapability {
        let cap = borrow_global<SharedBurnCapability<TokenType>>(token_address<TokenType>());
        Token::burn_with_capability(&cap.cap, token);
    }

    public fun mint<TokenType: store>(amount: u128): Token::Token<TokenType> acquires SharedMintCapability {
        let cap = borrow_global<SharedMintCapability<TokenType>>(token_address<TokenType>());
        Token::mint_with_capability<TokenType>(&cap.cap, amount)
    }

    public fun token_address<TokenType: store>(): address {
        Token::token_address<TokenType>()
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: dummy
script {
    use dummy::Dummy::{Self, ETH};

    const MULTIPLE: u128 = 1000000000;

    fun register_token(sender: signer) {
        Dummy::initialize<ETH>(&sender);
        // Dummy::initialize<USDT>(&sender);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! account: maket, 0x2222
//! sender: maket
address maket = {{maket}};
script {
    use 0x1111::DEXScripts;
    use dummy::Dummy::{ETH};

    fun init_config(sender: signer) {
        DEXScripts::init_dex<ETH>(sender);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: maket
address maket = {{maket}};
script {
    use 0x1111::DEXScripts;

    fun add_manager(sender: signer) {
        DEXScripts::add_manager(sender, @0x666666);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: maket
address maket = {{maket}};
script {
    use 0x1111::DEXScripts;

    fun add_manager(sender: signer) {
        DEXScripts::add_manager(sender, @0x888888);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: maket
address maket = {{maket}};
script {
    use 0x1111::DEXScripts;

    fun delete_manager(sender: signer) {
        DEXScripts::delete_manager(sender, @0x666666);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: maket
address maket = {{maket}};
script {
    use 0x1111::DEXScripts;

    fun delete_manager(sender: signer) {
        DEXScripts::delete_manager(sender, @0x999999);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! account: jack, 0x121212
//! sender: jack
address jack = {{jack}};
script {
    use 0x1111::DEXScripts;
    use dummy::Dummy::{Self, ETH};

    const MULTIPLE: u128 = 10000;

    fun deposit(sender: signer) {
        Dummy::mint_token<ETH>(&sender, 20 * MULTIPLE);
        DEXScripts::deposit<ETH>(sender, 10 * MULTIPLE);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: maket
address maket = {{maket}};
script {
    use 0x1111::DEXScripts;
    use dummy::Dummy::{ETH};

    const MULTIPLE: u128 = 10000;

    fun transfer(sender: signer) {
        DEXScripts::transfer<ETH>(sender, @0x121212, 1 * MULTIPLE, 66u128);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: maket
address jack = {{jack}};
script {
    use 0x1111::DEXScripts;
    use dummy::Dummy::{ETH};

    const MULTIPLE: u128 = 10000;

    fun withdrawal(sender: signer) {
        DEXScripts::withdrawal<ETH>(sender, @0x121212, 1 * MULTIPLE, 11u128);
    }
}
// check: "Keep(EXECUTED)"

//! new-transaction
//! account: manager01, 0x888888
//! sender: manager01
address manager01 = {{manager01}};
script {
    use 0x1111::DEXScripts;
    use dummy::Dummy::{ETH};

    const MULTIPLE: u128 = 10000;

    fun withdrawal(sender: signer) {
        DEXScripts::withdrawal<ETH>(sender, @0x121212, 1 * MULTIPLE, 2u128);
    }
}
// check: "Keep(EXECUTED)"
