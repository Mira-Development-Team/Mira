// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../proposable/ProposableOwnableUpgradeable.sol";
import "./ControllerInterface.sol";
import "../factory/MembersInterface.sol";
import "../token/IndexToken.sol";
import "../factory/FactoryInterface.sol";

/// @title Mira Protocol Controller
/// @author Mira Finance
/// @notice Controller contract that calls the actual token mint and burn
/// @notice as well as controls roles
/// @dev This contract uses the upgradeable pattern
contract Controller is ControllerInterface, ProposableOwnableUpgradeable {
    ///=============================================================================================
    /// State Variables
    ///=============================================================================================

    IndexToken public token;

    MembersInterface public members;

    FactoryInterface public factory;

    ///=============================================================================================
    /// Modifiers
    ///=============================================================================================

    modifier onlyFactory() {
        require(msg.sender == address(factory), "sender not authorized for minting or burning.");
        _;
    }

    ///=============================================================================================
    /// Initializer
    ///=============================================================================================

    function initialize(address _token) external initializer {
        token = IndexToken(_token);
        __Ownable_init();
    }

    ///=============================================================================================
    /// Setters
    ///=============================================================================================

    /// @notice Sets the members contract impl
    /// @param _members address
    /// @return type bool
    function setMembers(address _members) external onlyOwner returns (bool) {
        members = MembersInterface(_members);
        emit MembersSet(members);
        return true;
    }

    /// @notice Sets the Factory contract impl
    /// @param _factory address
    /// @return type bool
    function setFactory(address _factory) external onlyOwner returns (bool) {
        factory = FactoryInterface(_factory);
        emit FactorySet(factory);
        return true;
    }

    ///=============================================================================================
    /// Pause
    ///=============================================================================================

    function factoryPause(bool pause) external override onlyOwner returns (bool) {
        if (pause) {
            factory.pause();
        } else {
            factory.unpause();
        }
        emit FactoryPause(pause);
        return true;
    }

    ///=============================================================================================
    /// Token
    ///=============================================================================================

    /// @notice Calls the mint function on the actual token
    /// @notice only callable via Factory (approved mint request)
    /// @param to address
    /// @param amount uint256
    /// @return type bool
    function mint(address to, uint256 amount) external override onlyFactory returns (bool) {
        require(to != address(0), "invalid to address");
        token.mint(to, amount);
        return true;
    }

    /// @notice Calls the burn function on the actual token
    /// @notice only callable via Factory (approved burn request)
    /// @param from address
    /// @param value uint256
    /// @return type bool
    function burn(address from, uint256 value) external override onlyFactory returns (bool) {
        token.burn(from, value);
        return true;
    }

    ///=============================================================================================
    /// Non Mutable
    ///=============================================================================================

    /// @notice Returns whether or not a given address is a issuer
    /// @dev Uses index mapping to check if data is valid
    /// @param addr address
    /// @return bool
    function isIssuer(address addr) external view override returns (bool) {
        return members.isIssuer(addr);
    }

    /// @notice Returns whether or not a given address is a merchant
    /// @dev Uses index mapping to check if data is valid
    /// @param addr address
    /// @return bool
    function isMerchant(address addr) external view override returns (bool) {
        return members.isMerchant(addr);
    }

    function getToken() external view override returns (address) {
        return address(token);
    }

    ///=============================================================================================
    /// Override
    ///=============================================================================================

    function renounceOwnership() public view override onlyOwner {
        revert("renouncing ownership is blocked.");
    }
}
