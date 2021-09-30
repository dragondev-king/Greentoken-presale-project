    // SPDX-License-Identifier: MIT

    /**
    * &&&&&&   &&&&&&&  &&&& &&&&   &&&&     &&&&   &&&&&   &&&&&&  &&&&&&& &&&    &&     &&
    * &&&&&&&  &&&&&&&& &&&&&&&&&  &&&&&&   &&&&&&  &&&&&&  &&&&&&& &&&&&&  && &&  &&    &&&
    * &&   &&& &&       && &&& && &&    && &&       &&   && &&      &&      && &&  &&    &&&&&
    * &&    && &&&&&&   &&  &  && &&    && &&  &&&& &&&&&&  &&&&&&  &&&&&   &&  && &&  &&&&&&
    * @@    @@ @@@@@    @@     @@ @@    @@ @@  @@@@ @@@@@   @@@@@   @@@@@@  @@  @@ @@  &&&&&&&&
    * @@   @@@ @@       @@     @@ @@    @@ @@    @@ @@ @@   @@      @@      @@  @@ @@ &&&&&&&&&&
    * @@@@@@@  @@@@@@@@ @@     @@  @@@@@@   @@@@@@  @@  @@  @@@@@@@ @@@@@@  @@  @@ @@     &&
    * @@@@@@   @@@@@@@  @@     @@   @@@@     @@@@   @@  @@@ @@@@@@  @@@@@@@ @@    @@@     &&
    *
    * Demo Green Token for R&D firm
    * - Total Supply
    *      1 quadrillion Tokens
    * - Token name & symbol
    *      DemoGreen, "DMG"
    *
    * - Token distribution
    *      10% for Company Foundations
    *      5% for Partnership and Licensing Agent
    *      5% for Green and Clean Environment Reward
    *      5% for Airdrop
    *      5% for NFT Marketplace
    *      
    *      70% for Sale
    *      30% for Presale
    *      40% for Public Sale over Pancaleswap.
    *
    * - Great Tokenomics
    *      5% of each transaction will be distributed to all token holders
    *      5% of each transaction will be used for buyback
    *      5% of each transaction will be used for Green & Clean Environment reference
    */

    pragma solidity ^0.8.7;

    import "@openzeppelin/contracts/utils/Context.sol";
    import "@openzeppelin/contracts/utils/Address.sol";
    import "@openzeppelin/contracts/utils/math/SafeMath.sol";
    import "@openzeppelin/contracts/interfaces/IERC20.sol";
    import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
    import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
    import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
    import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
    import "./OwnableE.sol";

    // DemoGreen Contract
contract DemoGreen is Context, IERC20, OwnableE {
    using SafeMath for uint256;
    using Address for address;

    // Green & Clean Environment Reward Address
    address payable public rewardAddress = payable(0x1b0155e319d0c77DA13A1644b1d200794c18Ec87);
    // Contest Address
    address payable public contestAddress = payable(0x4c4b60d86CFfBF2eFaF98C927359525c0406BA3F);
    // Partnership and Licensing Agent Address
    address payable public partnershipAddress = payable(0x3eD588aC5310e0D16bf98632Ea7a8b472B9CA6DC);
    // Company Foundation
    address payable public companyAddress = payable(0x178077A67422168f0Ba36fF73638B00AE86d083e);
    // Airdrop Address
    address payable public airdropAddress = payable(0xB5150f00795Ac7C887D00a19BE8F73b89025F983);
    // Marketplace Address
    address payable public marketplaceAddress = payable(0x399ABE01fA03Ec00417C05193D7bC6C22E64C51E);
    // Burn Address
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1 * 10**15 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    // Token Name & Token Symbol & Token Decimals
    string private _name = "DemoGreen";
    string private _symbol = "DMG";
    uint8 private _decimals = 9;

    // Distribution fee to HODLings
    uint256 public _taxFee = 5;
    uint256 private _previousTaxFee = _taxFee;

    // Burn Fee + Reward Fee
    uint256 public _swapFee = 10;
    uint256 private _previousSwapFee = _swapFee;

    // Reward Fee percentage in Swap Fee ( 5 / 10 = 0.5 )
    uint256 public greenAndCleanEnvironmentRewardDivisor = 2;
    uint256 public contestDivisor = 3;

    // Max transaction amount
    uint256 public _maxTxAmount = 3 * 10**12 * 10**9; // 0.3% of Total Supply
    uint256 private minimumTokensBeforeSwap = 2 * 10**11 * 10**9; // Minimum Tokens to do Swap
    uint256 private buyBackUpperLimit = 1 * 10**18; // Buyback Upper Limit in BNB. 1 BNB(ETH) by default.

    // External Address Max amounts
    uint256 public _companyAmount = 1 * 10**14 * 10**9; // 10 percent of total supply
    uint256 public _rewardAmount = 5 * 10**13 * 10**9; // 5 percent of total supply
    uint256 public _partnershipAmount = 5 * 10**13 * 10**9; // 5 percent of total supply
    uint256 public _airdropAmount = 5 * 10**13 * 10**9; // 5 percent of total supply
    uint256 public _marketplaceAmount = 5 * 10**13 * 10**9; // 5 percent of total supply

    uint256 public _presaleAmount = 3 * 10**14 * 10**9; // 30 percent of total supply

    // PancakeSwap(Uniswap) Router and Pair Address
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    // Flags for features
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public buyBackEnabled = true;

    // Anti-Bot, Anti-Whale features.
    bool public antiWhalesEnabled = true;
    bool public antiBotEnabled = true;

    mapping(address => bool) private _isBlacklisted;

    uint256 private _start_timestamp = block.timestamp;

    // Events
    event RewardLiquidityProviders(uint256 tokenAmount);
    event BuyBackEnabledUpdated(bool enabled);
    event AntiWhalesEnabledUpdated(bool enabled);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SwapETHForTokens(uint256 amountIn, address[] path);
    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal;

        // PancakeSwap Router address:
        // (BSC testnet) 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        // (BSC mainnet) V2 0x10ED43C718714eb63d5aA57B78B54704E256024E
        // UniswapV2 Router address:
        // (Kovan testnet) 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {

        return _tFeeTotal;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {

        return minimumTokensBeforeSwap;
    }

    function buyBackUpperLimitAmount() public view returns (uint256) {

        return buyBackUpperLimit;
    }

    function deliver(uint256 tAmount) public {

        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }


    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {

        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferGreenAndCleanEnvironmentRewardTokens() external onlyOwner() {

        require(balanceOf(rewardAddress) + _rewardAmount == _rewardAmount, "Green and Clean Environment Reward can have only 5% of total supply");
        transfer(rewardAddress, _rewardAmount);
    }

    function transferPartnershipAndLicensingAgentTokens() external onlyOwner() {

        require(balanceOf(partnershipAddress) + _partnershipAmount == _partnershipAmount, "Partnership and Licensing Agent can have only 5% of total supply");
        transfer(partnershipAddress, _partnershipAmount);
    }

    function transferCompanyTokens() external onlyOwner() {

        require(balanceOf(companyAddress) + _companyAmount == _companyAmount, "Company Foundation can have only 10% of total supply");
        transfer(companyAddress, _companyAmount);
    }

    function transferAirdropTokens() external onlyOwner() {

        require(balanceOf(airdropAddress) + _airdropAmount == _airdropAmount, "Airdrop can have only 5% of total supply");
        transfer(airdropAddress, _airdropAmount);
    }

    function transferMarketplaceTokens() external onlyOwner() {

        require(balanceOf(marketplaceAddress) + _marketplaceAmount == _marketplaceAmount, "Marketplace can have only 5% of total supply");
        transfer(marketplaceAddress, _marketplaceAmount);
    }

    function transferTokensToPresale(address presaleAddress) external onlyOwner() {

        require(presaleAddress != address(0), 'Presale address can not be zero address');
        require(balanceOf(presaleAddress) + _presaleAmount == _presaleAmount, "Marketplace can have only 5% of total supply");
        transfer(presaleAddress, _presaleAmount);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Addresses in Blacklist can't do buy or sell.
        require(_isBlacklisted[from] == false && _isBlacklisted[to] == false, "Blacklisted addresses can't do buy or sell");

        if(from != owner() && to != owner()) {
            if(antiWhalesEnabled) {
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;

        if (!inSwapAndLiquify && swapAndLiquifyEnabled && to == uniswapV2Pair) {
            if (overMinimumTokenBalance) {
                contractTokenBalance = minimumTokensBeforeSwap;
                swapTokens(contractTokenBalance);
            }
            uint256 balance = address(this).balance;
            if (buyBackEnabled && balance > uint256(1 * 10**18)) {

                if (balance > buyBackUpperLimit)
                    balance = buyBackUpperLimit;

                buyBackTokens(balance.div(100));
            }
        }

        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }

        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapTokens(uint256 contractTokenBalance) private lockTheSwap {

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractTokenBalance);
        uint256 transferredBalance = address(this).balance.sub(initialBalance);

        //Send to Green And Clean Environment Reward address
        transferToAddressETH(rewardAddress, transferredBalance.div(_swapFee).mul(greenAndCleanEnvironmentRewardDivisor));
        transferToAddressETH(contestAddress, transferredBalance.div(_swapFee).mul(contestDivisor));
    }


    function buyBackTokens(uint256 amount) private lockTheSwap {

    if (amount > 0) {
        swapETHForTokens(amount);
    }
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapETHForTokens(uint256 amount) private {

        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        // make the swap
        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp.add(300)
        );

        emit SwapETHForTokens(amount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {

        if(!takeFee)
            removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwap) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeSwap(tSwap);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwap) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeSwap(tSwap);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwap) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeSwap(tSwap);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tSwap) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeSwap(tSwap);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getAntiDumpMultiplier() private view returns (uint256) {

        uint256 time_since_start = block.timestamp - _start_timestamp;
        uint256 hour = 60 * 60;

        if (antiBotEnabled) {

            if (time_since_start < 1 * hour) {

                return (5);

            } else if (time_since_start < 2 * hour) {

                return (4);

            } else if (time_since_start < 3 * hour) {

                return (3);

            } else if (time_since_start < 4 * hour) {

                return (2);

            } else {

                return (1);

            }

        } else {

            return (1);

        }
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        (uint256 tTransferAmount, uint256 tFee, uint256 tSwap) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tSwap, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tSwap);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {

        uint256 multiplier = _getAntiDumpMultiplier();
        uint256 tFee = calculateTaxFee(tAmount).mul(multiplier);
        uint256 tSwap = calculateSwapFee(tAmount).mul(multiplier);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tSwap);
        return (tTransferAmount, tFee, tSwap);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tSwap, uint256 currentRate) private pure returns (uint256, uint256, uint256) {

        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rSwap = tSwap.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rSwap);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeSwap(uint256 tSwap) private {

        uint256 currentRate =  _getRate();
        uint256 rSwap = tSwap.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rSwap);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tSwap);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {

        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateSwapFee(uint256 _amount) private view returns (uint256) {

        return _amount.mul(_swapFee).div(10**2);
    }

    function removeAllFee() private {

        if(_taxFee == 0 && _swapFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousSwapFee = _swapFee;

        _taxFee = 0;
        _swapFee = 0;
    }

    function restoreAllFee() private {

        _taxFee = _previousTaxFee;
        _swapFee = _previousSwapFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {

        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner() {

        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner() {

        _isExcludedFromFee[account] = false;
    }

    function setAddressAsBlacklisted(address account) public onlyOwner {

        _isBlacklisted[account] = true;
    }

    function setAddressAsWhitelisted(address account) public onlyOwner {

        _isBlacklisted[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {

        _taxFee = taxFee;
    }

    function setSwapFeePercent(uint256 swapFee) external onlyOwner() {

        _swapFee = swapFee;
    }

    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {

        _maxTxAmount = maxTxAmount;
    }

    function setGreenAndCleanEnvironmentRewardDivisor(uint256 divisor) external onlyOwner() {

        greenAndCleanEnvironmentRewardDivisor = divisor;
    }

    function setNumTokensSellToAddToLiquidity(uint256 _minimumTokensBeforeSwap) external onlyOwner() {

        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setBuybackUpperLimit(uint256 buyBackLimit) external onlyOwner() {

        buyBackUpperLimit = buyBackLimit * 10**18;
    }

    function setGreenAndCleanEnvironmentRewardAddress(address _rewardAddress) external onlyOwner() {

        rewardAddress = payable(_rewardAddress);
    }

    function setContestAddress(address _contestAddress) external onlyOwner() {

        contestAddress = payable(_contestAddress);
    }

    function setPartnershipAndLicensingAgentAddress(address _partnershipAddress) external onlyOwner() {

        partnershipAddress = payable(_partnershipAddress);
    }

    function setCompanyFoundationAddress(address _companyAddress) external onlyOwner() {

        companyAddress = payable(_companyAddress);
    }

    function setAirdropAddress(address _airdropAddress) external onlyOwner() {

        airdropAddress = payable(_airdropAddress);
    }

    function setMarketplaceAddress(address _marketplaceAddress) external onlyOwner() {

        marketplaceAddress = payable(_marketplaceAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner() {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setBuyBackEnabled(bool _enabled) public onlyOwner() {

        buyBackEnabled = _enabled;
        emit BuyBackEnabledUpdated(_enabled);
    }

    function setAntiWhaleEnabled(bool _enabled) public onlyOwner() {

        antiWhalesEnabled = _enabled;
        emit AntiWhalesEnabledUpdated(_enabled);
    }

    function prepareForPreSale() external onlyOwner() {

    setSwapAndLiquifyEnabled(false);
    _taxFee = 0;
    _swapFee = 0;
        _previousTaxFee = 0;
        _previousSwapFee = 0;
    _maxTxAmount = 1 * 10**15 * 10**9;
    }

    function afterPreSale() external onlyOwner() {

        setSwapAndLiquifyEnabled(true);
        _taxFee = 5;
        _swapFee = 10;
        _maxTxAmount = 3 * 10**12 * 10**9;
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {

        recipient.transfer(amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}
}