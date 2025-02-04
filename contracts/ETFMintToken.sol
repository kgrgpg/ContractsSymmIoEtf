// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ETFMintToken
 * @dev ERC20 token contract for ETF minting with collateral locking.
 *
 * Users can lock collateral by sending Ether via lockCollateral().
 * The locked collateral is recorded in a mapping.
 *
 * The contract owner (typically the backend service after verifying conditions)
 * can call mintETFTokens() to mint new ETF tokens for a user, provided that the user
 * has locked collateral.
 */
contract ETFMintToken is ERC20, Ownable {
    // Mapping to record collateral locked per user (in wei)
    mapping(address => uint256) private _collateralLocked;

    event CollateralLocked(address indexed user, uint256 amount);
    event TokensMinted(address indexed user, uint256 amount);

    /**
     * @dev Constructor that gives the token its name and symbol,
     * and sets the deployer as the initial owner.
     */
    constructor() ERC20("ETFMintToken", "EMT") Ownable(msg.sender) {}

    /**
     * @notice Lock collateral by sending Ether.
     * @dev The function is payable. The amount sent is added to the caller's collateral.
     */
    function lockCollateral() external payable {
        require(msg.value > 0, "Must send some Ether as collateral");
        _collateralLocked[msg.sender] += msg.value;
        emit CollateralLocked(msg.sender, msg.value);
    }

    /**
     * @notice Returns the amount of collateral locked for a user.
     * @param user The address of the user.
     * @return The locked collateral amount in wei.
     */
    function getLockedCollateral(address user) external view returns (uint256) {
        return _collateralLocked[user];
    }

    /**
     * @notice Mints ETF tokens to a specified address.
     * @dev Can only be called by the contract owner.
     * It requires that the target address has locked some collateral.
     * @param to The recipient address.
     * @param amount The amount of tokens to mint (in the token's smallest unit).
     * @return A boolean indicating success.
     */
    function mintETFTokens(address to, uint256 amount) external onlyOwner returns (bool) {
        require(_collateralLocked[to] > 0, "No collateral locked for this user");
        _mint(to, amount);
        emit TokensMinted(to, amount);
        return true;
    }
}