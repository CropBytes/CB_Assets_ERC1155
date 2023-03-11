// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Burnable.sol)

pragma solidity ^0.8.0;

import "../ERC1155.sol";
import "../../../access/AccessControl.sol";
/**
 * @dev Extension of {ERC1155} that allows token holders to destroy both their
 * own tokens and those that they have been approved to use.
 *
 * _Available since v3.1._
 */
abstract contract ERC1155Locking is ERC1155, AccessControl {

    mapping(address => bool) private _locks;

    mapping(address => bool) private _permanentLocks;

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event Lock(address indexed account);
    event Unlock(address indexed account);
    event PermanentLock(address indexed account);
    event PermanentUnlock(address indexed account);

    function _lock(address account) internal virtual
    {
      _locks[account] = true;
      emit Lock(account);
    }

    function _unlock(address account) internal virtual
    {
      _locks[account] = false;
      emit Unlock(account);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _lockPermanent(address account) internal virtual
    {
      _permanentLocks[account] = true;
      emit PermanentLock(account);
    }

    function _unlockPermanent(address account) internal virtual
    {
      _permanentLocks[account] = false;
      emit PermanentUnlock(account);
    }

    function getLock(address account) external view returns(bool)
    {
      return _locks[account];
    }

    function _hasLock(address account) internal virtual view returns(bool)
    {
      return _locks[account];
    }

    function getPermanentLock(address account) external view returns(bool)
    {
      return _permanentLocks[account];
    }

    function _hasPermanentLock(address account) internal virtual view returns(bool)
    {
      return _permanentLocks[account];
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        require(_locks[from] == false || hasRole(ADMIN_ROLE, _msgSender()), "ERC1155: Account is Locked");
        require(_permanentLocks[from] == false, "ERC1155: Account is permanently Locked");
    }
}
