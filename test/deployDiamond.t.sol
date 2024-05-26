// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "forge-std/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/SocialMediaFacet.sol";
import "../contracts/facets/UserRegistrationFacet.sol";
import {LibAppStorage} from "../contracts/libraries/LibAppStorage.sol";






contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    SocialMediaFacet socialFacet;
     UserRegistrationFacet userFacet;


      address A = address(0xa);
    address B = address(0xb);
    bytes32 ebuka = 0x6bdd6dbf4c9d5511440208baa4a0ddd39e4c9fe2a5b84910e9b03e2fd8c49807;
    bytes32 ifeanyi = 0x6bdd6dbf4c9d5511440208baa4a0ddd39e4c9fe2a5b84910e9b03e2fd8c49806;
 
// // 
//     address A = address(0xa);
//     address B = address(0xb);

//     AuctionFacet auctionFacets;


    function setUp() public {
        //deplslloy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
          userFacet = new  UserRegistrationFacet();
        socialFacet = new SocialMediaFacet();

        
        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(socialFacet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("SocialMediaFacet")
            })
        );

         cut[3] = (
            FacetCut({
                facetAddress: address(userFacet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("UserRegistrationFacet")
            })
        );

        // //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        
        


        userFacet = UserRegistrationFacet(address(diamond));

        A = mkaddr("ebukizy1");
            B = mkaddr("davido");

    }

    function testUserRegistration() public{
        switchSigner(A);
        userFacet.createAccount(ebuka, "01/03/2024");
        uint registeredCount = userFacet.getAllUser().length;
        assertEq(registeredCount, 1);
    }

    function testUserCannot_RegisterWithSameUserName() external {
        switchSigner(A);
        userFacet.createAccount(ebuka, "01/03/2024");
        uint registeredCount = userFacet.getAllUser().length;
        assertEq(registeredCount, 1);
        vm.expectRevert(
            abi.encodeWithSelector(UserName_Already_Taken.selector)
        );
         userFacet.createAccount(ebuka, "01/03/2024");

    }

    function testUserCannot_RgisterWithSameAddress() external {
        switchSigner(A);
        userFacet.createAccount(ebuka, "01/03/2024");
        uint registeredCount = userFacet.getAllUser().length;
        assertEq(registeredCount, 1);
        switchSigner(A);
        vm.expectRevert(
            abi.encodeWithSelector(User_Already_Register.selector)
        );
         userFacet.createAccount(ifeanyi, "01/03/2024");
    }


    function testSetUpProfile() external {
        testUserRegistration(); // Ensure the user is registered first
        switchSigner(A); // Switch to the user's address
        userFacet.setUpProfile(ebuka, "LOVE.PNG"); // Call setUpProfile

        LibAppStorage.User memory _user = userFacet.getUser(A);
        assertEq(_user.userBio, ebuka);
        assertEq(_user.imageUrl, "LOVE.PNG");
    }

    function testSetUpProfileRevertsOnEmptyBio() external {
        testUserRegistration(); // Ensure the user is registered first
        switchSigner(A); // Switch to the user's address
        vm.expectRevert(
            abi.encodeWithSelector(invalid_description.selector)
        );
        userFacet.setUpProfile(bytes32(0), "LOVE.PNG"); // Call setUpProfile with empty bio
    }

    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}


    // function testAuctionFacet() public {
    //     switchSigner(A);
    //     // emax721.safeMint(A, 1);

    //     // auctionFacets.submitNFTForAuction(address(emax721), 1, 2000, 1
    // }



    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }

    }
}
