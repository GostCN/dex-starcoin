address 0x1111 {
module DEXScripts {
    use 0x2222::DEXStarCoin;

    //init dex starcoin pool and manager list
    public(script) fun init_dex<DexToken: store>(account: signer) {
        DEXStarCoin::init_dex<DexToken>(&account);
    }

    //add a new manager
    public(script) fun add_manager(account: signer, user_address: address) {
        DEXStarCoin::add_manager(&account, user_address);
    }

    //delete a manager
    public(script) fun delete_manager(account: signer, user_address: address) {
        DEXStarCoin::delete_manager(&account, user_address);
    }

    //user deposit
    public(script) fun deposit<DexToken: store>(user: signer, amount: u128) {
        DEXStarCoin::deposit<DexToken>(&user, amount);
    }

    //account or manager transfer : across chain
    public(script) fun transfer<DexToken: store>(account: signer, user_address: address, amount: u128) {
        DEXStarCoin::transfer<DexToken>(&account, user_address, amount);
    }

    //account or manager withdrawal : current chain
    public(script) fun withdrawal<DexToken: store>(account: signer, user_address: address, amount: u128) {
        DEXStarCoin::withdrawal<DexToken>(&account, user_address, amount);
    }

}
}