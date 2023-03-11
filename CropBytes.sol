// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./OZ_contracts/token/ERC1155/ERC1155.sol";
import "./OZ_contracts/access/AccessControl.sol";
import "./OZ_contracts/security/Pausable.sol";
import "./OZ_contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "./OZ_contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "./OZ_contracts/token/ERC1155/extensions/ERC1155Locking.sol";

contract CropBytes is ERC1155, AccessControl, Pausable, ERC1155Burnable, ERC1155Supply, ERC1155Locking {
    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string public name = "CropBytes";
    string private _contractUri = "https://blockchain.ethernia.com/metadata/contract-metadata";

    constructor() ERC1155("https://testnet.ethernia.com/blockchain/") {
        _grantRole(OWNER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setURI(string memory newuri) public onlyRole(ADMIN_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(OWNER_ROLE) {
        _pause();
    }

    function updateContractURI(string memory uri) public onlyRole(ADMIN_ROLE) {
        _contractUri = uri;
    }

    function contractURI() public view returns (string memory) {
        return _contractUri;
    }

    function unpause() public onlyRole(OWNER_ROLE) {
        _unpause();
    }

    //The function will mint assets
    //Once an asset is minted, it cannot be called again for the same asset
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mint(account, id, amount, data);
    }

    //The function will mint assets in batch
    //Once an asset is minted, it cannot be called again for the same asset
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    //Transfer directly from senders address to "to" address
    function transfer(address to, uint256 id, uint256 amount, bytes memory data)
        public
    {
        address owner = _msgSender();
        _safeTransferFrom(owner, to, id, amount, data);
    }

    //Batch transfer from sender address to "to" aoddress
    function transferBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
    {
        address owner = _msgSender();
        _safeBatchTransferFrom(owner, to, ids, amounts, data);
    }

    //The function locks the user assets from preventing further transfer. Only admin role can call this function
    function permanentLock(address account)
        public
        onlyRole(ADMIN_ROLE)
    {
        _lockPermanent(account);
    }

    //The function unlocks the user assets.
    function permanentUnlock(address account)
        public
        onlyRole(ADMIN_ROLE)
    {
        _unlockPermanent(account);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply, ERC1155Locking)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl, ERC1155Locking)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
