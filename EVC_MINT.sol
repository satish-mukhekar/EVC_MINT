// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8 .0;

import "./Counters.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Strings.sol";
import "./SafeERC20.sol";

contract Avtars is Ownable, ERC721Enumerable {

    using SafeERC20
    for IERC20;
    using Counters
    for Counters.Counter;
    using Strings
    for uint256;

    address public _token = 0xf8e81D47203A594245E36C48e151709F0C19fBe8; //busd
    address public delegateAddress = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

    uint256[8] public costs = [100 ether, 500 ether, 1000 ether, 2500 ether, 5000 ether, 10000 ether, 25000 ether, 50000 ether];
    uint256[8] public NFT_Quantities = [10, 10, 10, 10, 10, 10, 10, 10];

    uint256 public maxSupply = 113600;
    uint256 public maxMintAmount = 10;

    string public baseExtension = ".json";
    string public baseURI = "ipfs://QmZLfZHMA5bXDPWRAeMvBAGokxgm1rF2DbgyrFrTfeoAv4/";


    bool public paused = false;
    bool public delegate = false;

    uint public calcualte;

    mapping(address => bool) public whitelisted;
    uint256[] public NFTidArray;

    /////////////////////////

    mapping(address => uint256) public referralCount;
    mapping(address => uint256) public referralRank;
    mapping(address => address) public myReferrer;
    mapping(address => address[]) public referrals;

    // mapping(address => address[]) public recentjoinuser;/
    mapping(address => uint256) public joinTimestamp;


    mapping(address => mapping(address => uint)) public userInvsetment;
    mapping(address => address[]) public upgradingRank;
    mapping(address => uint) public teamVloume;
    mapping(address => bool)[8] public hasTokens;
    mapping(address => mapping(address => uint)) public userInvestment;
    mapping(address => individualLevel) public individualLevelinfo;
    uint public rankTarget = 10000 ether;


    struct individualLevel {
        bool level1;
        bool level2;
        bool level3;
        bool level4;
        bool level5;
        bool level6;
        bool level7;
    }

    struct teamStatistic {
        address _user;
        uint _rank;
        uint _totalPartners;
        string nftLevel;
        uint totalTeamSales;
    }
    Counters.Counter[8] public NFT_Counters;


    ////////////////////////

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        NFT_Counters[1]._value = 20;
        NFT_Counters[2]._value = 30;
        NFT_Counters[3]._value = 40;
        NFT_Counters[4]._value = 50;
        NFT_Counters[5]._value = 60;
        NFT_Counters[6]._value = 70;
        NFT_Counters[7]._value = 80;
    }

    ///////////////////

    function setReferrer(address referrer) internal {
        if (myReferrer[msg.sender] == address(0)) {
            require(referrer != msg.sender, "Cannot refer yourself");
            myReferrer[msg.sender] = referrer;
            referrals[referrer].push(msg.sender);
            referralCount[referrer]++;
            joinTimestamp[msg.sender] = block.timestamp; // Record the join timestamp
        } else if (myReferrer[msg.sender] != address(0)) {
            require(myReferrer[msg.sender] == referrer, "fill correct referral address");
        }
    }


    function getReferrals(address referrer) public view returns(address[] memory) {
        return referrals[referrer];
    }

    function upLifting(address _referrer) internal {

        address three;
        address four;
        address five;
        address six;
        address seven;

        referralRank[_referrer] = 1;

        if (_referrer != address(0)) {
            referralCount[_referrer]++;
        }
        bool isExist = false;
        for (uint i = 0; i < upgradingRank[_referrer].length; i++) {
            if (upgradingRank[_referrer][i] == msg.sender) {
                isExist = true;
                break;
            }
        }
        if (userInvsetment[msg.sender][_referrer] >= rankTarget && !isExist) {
            upgradingRank[_referrer].push(msg.sender);
        }

        if (upgradingRank[_referrer].length >= 3) {
            referralRank[_referrer] = 2;

            three = myReferrer[_referrer];
            four = myReferrer[three];
            five = myReferrer[four];
            six = myReferrer[five];
            seven = myReferrer[six];

            referralRank[three] = 3;
            referralRank[four] = 4;
            referralRank[five] = 5;
            referralRank[six] = 6;
            referralRank[seven] = 7;
        }
    }

    function getTeamSaleVolume(address user) public view returns(uint) {
        uint totalInvestment = userInvestment[user][user];
        for (uint i = 0; i < referrals[user].length; i++) {
            address member = referrals[user][i];
            totalInvestment += userInvestment[member][user];
            if (referrals[member].length > 0) {
                totalInvestment += getTeamSaleVolume(member);
            }
        }
        return totalInvestment;
    }


    function rankupLifting(address _user) public {
        if (referralRank[_user] == 6) {
            if (getTeamSaleVolume(_user) >= 700 && checkRank(_user) && hasTokens[6][_user]) {
                referralRank[_user] = 7;
            }
        } else if (referralRank[_user] == 5) {
            if (getTeamSaleVolume(_user) >= 600 && checkRank(_user) && hasTokens[5][_user]) {
                referralRank[_user] = 6;
            }
        } else if (referralRank[_user] == 4) {
            if (getTeamSaleVolume(_user) >= 500 && checkRank(_user) && hasTokens[4][_user]) {
                referralRank[_user] = 5;
            }
        } else if (referralRank[_user] == 3) {
            if (getTeamSaleVolume(_user) >= 400 && checkRank(_user) && hasTokens[3][_user]) {
                referralRank[_user] = 4;
            }
        } else if (referralRank[_user] == 2) {
            if (getTeamSaleVolume(_user) >= 300 && checkRank(_user) && hasTokens[2][_user]) {
                referralRank[_user] = 3;
            }
        } else if (referralRank[_user] == 1) {
            if (getTeamSaleVolume(_user) >= 200 && checkRank(_user) && hasTokens[1][_user]) {
                referralRank[_user] = 2;
            }
        } else if (referralRank[_user] == 0) {
            if (getTeamSaleVolume(_user) >= 100 && hasTokens[0][_user]) {
                referralRank[_user] = 1;
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //  FUntion to get recentjoined in team
    function getTeamAddresses(address _user) internal view returns(address[] memory) {
        address[] memory teamAddresses = new address[](1);
        teamAddresses[0] = _user;
        uint numReferrals = referrals[_user].length;

        for (uint i = 0; i < numReferrals; i++) {
            address member = referrals[_user][i];
            address[] memory memberTeam = getTeamAddresses(member);
            address[] memory concatenated = new address[](teamAddresses.length + memberTeam.length);
            for (uint j = 0; j < teamAddresses.length; j++) {
                concatenated[j] = teamAddresses[j];
            }
            for (uint j = 0; j < memberTeam.length; j++) {
                concatenated[teamAddresses.length + j] = memberTeam[j];
            }
            teamAddresses = concatenated;
        }
        return teamAddresses;
    }


    function filterFunction(address _account) internal view returns(address[] memory) {

        address[] memory filterarray = getTeamAddresses(_account);
        address[] memory teamAddressesWithoutFirst = new address[](filterarray.length - 1);
        for (uint i = 0; i < filterarray.length - 1; i++) {
            teamAddressesWithoutFirst[i] = filterarray[i + 1];
        }
        return teamAddressesWithoutFirst;
    }


    function recentlyJoined2(address _account) public view returns(address[] memory) {
        address[] memory teamAddresses = filterFunction(_account);
        uint256[] memory joinTimestamps = new uint256[](teamAddresses.length);
        for (uint256 i = 0; i < teamAddresses.length; i++) {
            joinTimestamps[i] = joinTimestamp[teamAddresses[i]];
        }
        sortAddressesByTimestamp(teamAddresses, joinTimestamps);
        uint256 arrayLength = teamAddresses.length > 1 ? teamAddresses.length : 0;
        uint256 resultLength = arrayLength > 10 ? 10 : arrayLength;
        address[] memory addressesToReturn = new address[](resultLength);
        for (uint256 i = 0; i < resultLength; i++) {
            addressesToReturn[i] = teamAddresses[arrayLength - i - 1];
        }
        return addressesToReturn;
    }

    function sortAddressesByTimestamp(address[] memory addressesArr, uint256[] memory timestampsArr) internal pure {
        uint256 n = addressesArr.length;
        for (uint256 i = 0; i < n - 1; i++) {
            for (uint256 j = i + 1; j < n; j++) {
                if (timestampsArr[i] > timestampsArr[j]) {
                    (addressesArr[i], addressesArr[j]) = (addressesArr[j], addressesArr[i]);
                    (timestampsArr[i], timestampsArr[j]) = (timestampsArr[j], timestampsArr[i]);
                }
            }
        }

    }

    /////recentjoined

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function checkRank(address _user) public view returns(bool) {
        uint usercurrentrank = referralRank[_user];
        uint memberrankCount;
        for (uint i = 0; i < referrals[_user].length; i++) {
            address member = referrals[_user][i];

            if (referralRank[member] >= usercurrentrank) {
                memberrankCount++;
            }

            if (memberrankCount >= 3) {
                return true;
            }
        }
        if (memberrankCount < 3) {
            for (uint i = 0; i < referrals[_user].length; i++) {
                address member = referrals[_user][i];
                if (referralRank[member] < usercurrentrank) {
                    bool found = legSearch(member, usercurrentrank);
                    if (found == true) {
                        memberrankCount++;
                    }
                }
                if (memberrankCount >= 3) {
                    return true;
                }
            }
        }
        return false;
    }


    function legSearch(address member, uint currentrank) internal view returns(bool) {
        if (referrals[member].length == 0) {
            return false;
        }
        for (uint i = 0; i < referrals[member].length; i++) {
            address referrer = referrals[member][i];
            if (referralRank[referrer] >= currentrank) {
                return true;
            }
            if (legSearch(referrer, currentrank)) {
                return true;
            }
        }
        return false;
    }


    function getTotalPartners(address _user) public view returns(uint) {
        uint totalPartners;
        if (referrals[_user].length > 0) {
            totalPartners += referrals[_user].length;
            for (uint i = 0; i < referrals[_user].length; i++) {
                uint partnersTotal = getTotalPartners(referrals[_user][i]);
                totalPartners += partnersTotal;
            }
        }
        return totalPartners;
    }

    function teamSalesINformation(address _user) public view returns(teamStatistic[] memory) {
        teamStatistic[] memory teamStatisticsArray = new teamStatistic[](referrals[_user].length);
        for (uint i = 0; i < referrals[_user].length; i++) {
            address user = referrals[_user][i];
            uint userRank = referralRank[user];
            uint Totalpartner = getTotalPartners(user);
            uint teamTurnover = getTeamSaleVolume(user);
            string memory ownNFT;
            if (hasTokens[7][user]) {
                ownNFT = "CryptoCap Tycoon";
            } else if (hasTokens[6][user]) {
                ownNFT = "Bitcoin Billionaire";
            } else if (hasTokens[5][user]) {
                ownNFT = "Blockchain Mogul";
            } else if (hasTokens[4][user]) {
                ownNFT = "Crypto King";
            } else if (hasTokens[3][user]) {
                ownNFT = "Crypto Investor";
            } else if (hasTokens[2][user]) {
                ownNFT = "Crypto Entrepreneur";
            } else if (hasTokens[1][user]) {
                ownNFT = "Crypto Enthusiast";
            } else if (hasTokens[0][user]) {
                ownNFT = "Crypto Newbies";
            }
            teamStatistic memory teamStatisticsInfo = teamStatistic(user, userRank, Totalpartner, ownNFT, teamTurnover);
            teamStatisticsArray[i] = teamStatisticsInfo;
        }
        return teamStatisticsArray;
    }


    /////////////////// admin function 

    function createReffralarray(address _ref, address to) public onlyOwner {
        {
            referrals[_ref].push(to);
            joinTimestamp[to] = block.timestamp; // Record the join timestamp
        }
    }

    function changeRank(address _user, uint _rank) public onlyOwner {
        require(_rank <= 7, "rank cannot be more than 7");
        referralRank[_user] = _rank;
    }

    function changeinvestment(address _user, uint _value, address _referrer) public onlyOwner {
        userInvsetment[_user][_referrer] = _value;
    }

    function setNftLevel(address _useradd, uint _level) public {
        if (_level == 1) {
            hasTokens[0][_useradd] = true;
        }
        if (_level == 2) {
            hasTokens[1][_useradd] = true;
        }
        if (_level == 3) {
            hasTokens[2][_useradd] = true;
        }
        if (_level == 4) {
            hasTokens[3][_useradd] = true;
        }
        if (_level == 5) {
            hasTokens[4][_useradd] = true;
        }
        if (_level == 6) {
            hasTokens[5][_useradd] = true;
        }
        if (_level == 7) {
            hasTokens[6][_useradd] = true;
        }
        if (_level == 8) {
            hasTokens[7][_useradd] = true;
        }
    }
    //////////////////

    //User
    function mintNFT(uint _level, uint _mintPrice, bool _delegate, address _referrer) public {
        uint level = _level - 1;
        require(level >= 0 && level <= 7, "Invalid NFT level");
        require(!hasTokens[level][msg.sender], "You already have an NFT of this level!");
        require(!paused, "Minting is paused");
        require(totalSupplyOfLevel(_level) < NFT_Quantities[level], "Cannot mint more NFTs of this level");
        setReferrer(_referrer); // constant referrer

        if (msg.sender != owner()) {
            if (!whitelisted[msg.sender]) {
                uint requiredPrice = costs[level];
                require(_mintPrice >= requiredPrice, "Insufficient payment amount");
                if (_delegate == true) {
                    uint sharePrice = requiredPrice * 10 / 100;
                    uint newMintPrice = requiredPrice + sharePrice;
                    require(_mintPrice >= newMintPrice, "Insufficient payment amount; if delegate is true, add 10% more.");
                    uint256 transferValue = _mintPrice - requiredPrice - sharePrice;
                    uint shareToDelegate = sharePrice + transferValue;
                    IERC20(_token).safeTransferFrom(msg.sender, address(this), requiredPrice);
                    IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, shareToDelegate);
                } else {
                    IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
                }
            }
        }
        NFT_Counters[level].increment();
        uint256 tokenId = NFT_Counters[level].current();
        NFTidArray.push(tokenId);
        userInvestment[msg.sender][_referrer] += _mintPrice;
        _safeMint(msg.sender, tokenId);
        hasTokens[level][msg.sender] = true;
        // rankupLifting(msg.sender);
        rankUpdate();
    }


    //View
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns(string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension));
    }

    function totalSupplyOfLevel(uint256 _level) public view returns(uint256) {
        uint level = _level - 1;
        uint256 total = NFT_Counters[level].current();
        if (level == 0) {
            return total;
        } else if (level == 1) {
            return total - 20;
        } else if (level == 2) {
            return total - 30;
        } else if (level == 3) {
            return total - 40;
        } else if (level == 4) {
            return total - 50;
        } else if (level == 5) {
            return total - 60;
        } else if (level == 6) {
            return total - 70;
        } else if (level == 7) {
            return total - 80;
        } else {
            return total;
        }
    }


    //Internal
    function rankUpdate() internal {
        for (uint i = 0; i < NFTidArray.length; i++) {
            address owner = ERC721.ownerOf(NFTidArray[i]);
            rankupLifting(owner);
        }
    }


    function getMyReferrer(address _user) public view returns(address) {
        return myReferrer[_user];
    }

    function getReferralCount(address _user) public view returns(uint) {
        return referralCount[_user];
    }

    //Admin
    function setBaseURI(
        string memory _baseURI

    ) external onlyOwner {
        baseURI = _baseURI;
    }

    function setCost(uint256[] memory newCosts) public onlyOwner {
        require(newCosts.length == 8, "Invalid number of cost values");
        for (uint256 i = 0; i < newCosts.length; i++) {
            costs[i] = newCosts[i];
        }
    }

    function burn(uint256 tokenId_) public onlyOwner {
        _burn(tokenId_);
        uint256 level = tokenId_ / 10; // Integer division to determine the level
        if (level >= 0 && level <= 7) {
            NFT_Counters[level].decrement();
        }
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setToken(address _newtoken) public onlyOwner {
        _token = _newtoken;
    }

    function setDelegateAddress(address _delegateAddress) public onlyOwner {
        delegateAddress = _delegateAddress;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function withdraw() public payable onlyOwner {
        IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
    }

}

/*
0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 - owner
0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
0x617F2E2fD72FD9D5503197092aC168c91465E7f2
0x17F6AD8Ef982297579C203069C1DbfFE4348c372
0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7
0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C
0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC

0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
0x583031D1113aD414F02576BD6afaBfb302140225
0xdD870fA1b7C4700F2BD7f44238821C26f7392148


                                  5B3
                                /  |  \
                              /    |    \
                           Ab8    4B2      787
                           /\     /  \      / \
                          /  \   |    |    /   \
                       dD8  583  4B0 147  CA3   0A0
                        |         |               |
                        |         |               |

                        1aE       03C            5c6
                        |                         |
                        |                         |
                        617                       17F

0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,["0xdD870fA1b7C4700F2BD7f44238821C26f7392148","0x583031D1113aD414F02576BD6afaBfb302140225"]

0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,["0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB","0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C"]

0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,["0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c","0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC"]

0xdD870fA1b7C4700F2BD7f44238821C26f7392148,["0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C"]

0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB,["0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7"]

0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC,["0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678"]
0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C,["0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678,["0x17F6AD8Ef982297579C203069C1DbfFE4348c372"]
*/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
95000000000000000000000
31000000000000000000000

1,100000000000000000000,false,0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
500000000000000000000 false ether;
1000000000000000000000 false ether;
2500000000000000000000 false ether;
5000000000000000000000 false ether;
10000000000000000000000 false ether;
25000000000000000000000 false ether;
50000000000000000000000 false ether;


                5B3
              /  |  \
           Ab8  4B2   787
         /  |   |  |   |   \
      dD8 583  4B0 147 CA3  0A0
       |         |           |
      1aE       03C         5c6
*/




/*
extra addresses:

0x145497854C104D8907b0FA2f267BC03CdaC15A73
0x3d3Fea0c7951b93ED9985819BfA53c78Eb0E9079
0x855888e5a566900F5B35F7E7C599d06A1C8453C3






*/
