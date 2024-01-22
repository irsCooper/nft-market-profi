// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
pragma abicoder v2;

// import "./standart_token/token/ERC1155/ERC1155.sol";
// import "./standart_token/token/ERC20/ERC20.sol";

// для REMIX
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract Contract is ERC20, ERC1155 {

    address Owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    uint public unicue_nft; //сколько видов nftшек создано в системе (то же самое что id)
    uint public unicue_collection; //сколько создано коллекций

    struct NFT {
        uint Id;
        string Name;
        string Desimals;
        string ImageName; //path to photo
        string TotalReliased;
        uint   DataSet;
    }

    struct Sell_Nft {
        uint Id;
        NFT Nft;
        address Owner;
        uint AmountForSale;
        uint Price;
    }

    struct Collection {
        uint Id;
        string Name;
        string Description;
        uint[] NftInCollection;
        uint[] AmountForNft;
    }

    struct Bet {
        uint Id;
        address Owner;
        uint Price;
    }

    struct Action {
        uint Id;
        Collection Collection;
        address Owner;
        uint Time_Start;
        uint Time_End;
        uint Min_Price;
        uint Max_Price;
        uint Id_Max_Bet;
    }


    // nft
    mapping (uint => NFT) public nft; //nft info
    mapping (address => uint) user_amount_unicue_nft;
    mapping (address => mapping(uint => bool)) SellOrNotSell_NFT; //get address user and id -> nft инфу о которой хотим узнать

    Sell_Nft[] public Sell_Only_Nft; //это массив для одиноких nftшек


    //  collection
    mapping (uint => Collection) public collection;
    mapping (uint => address) owner_collection;
    mapping (uint => bool) SellOrNotSell_Collection;
    mapping (address => uint) user_amount_unicue_collection;

    modifier CheckSell(uint id, uint _type) {
        if(_type == 1) {
            require(SellOrNotSell_NFT[msg.sender][id] == false, "this nft already sale");  
        }
        else{
            require(SellOrNotSell_Collection[id] == false, "this collection already sale");
        }
        _;
    }


    // action
    mapping (uint => Bet[]) bet_to_action;
    Action[] public action;


    // user
    mapping (address => string) User;

    //при регистрации пользователя мы получаем это значение с фронта (а регистрации у нас не будет!!!!!)
    //но когда мы регистрируем пользователей в конмтрукторе, мы сами задаём это значение (ручками пишем первые 4 значения из адреса)
    //потом просто будем сравнивать строки (когда это потребуется)
    mapping (address => string) UserReferralCode;  

    mapping (address => bool)   MyReferralCode;     //вводился ли код пользователя кем-то
    mapping (address => bool)   FriendReferralCode; //вводил ли пользователь чей-то код
    mapping (address => uint8)  Discont;     

    modifier OnlyOwner() {
        require(msg.sender == Owner, "you're not owner");
        _;
    }


    function Auth() public view returns(string memory name, uint balance, string memory refCode, uint discont) {
        name = User[msg.sender];
        balance = ERC20.balanceOf(msg.sender);
        refCode = UserReferralCode[msg.sender];
        discont = Discont[msg.sender];
    }

    // специальная структура для упрощения жизни фронтендера (чтобы не мучаться с совмещением двух массивов, как в прошлый раз)
    struct NftForUserLk {
        NFT NFT;
        uint Amount;
    }

    function GetAllUser_Nfts() public view returns(NftForUserLk[] memory) {
        uint ost = unicue_nft - user_amount_unicue_nft[msg.sender];
        NftForUserLk[] memory _nft = new NftForUserLk[](unicue_nft - ost);

        uint push;

        for (uint i = 0; i < unicue_nft; i++) {
            if (ERC1155.balanceOf(msg.sender, i) > 0) {
                _nft[push] = NftForUserLk(nft[i], ERC1155.balanceOf(msg.sender, i));
                push += 1;
            } 
        }

        return _nft;
    }

    function GetAllUser_Collection() public view returns(Collection[] memory _collection) {

    } 














    constructor() ERC20("Professional", "PROFI") ERC1155("./images/") {
        // в папках проекта изменить параметр в функции decimals контракта ERC20 с 18и на 6 (так указано в тз)
        ERC20._mint(Owner, 1000000);

        User[Owner] = "Owner";
        UserReferralCode[Owner] = "5B38";

        User[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = "Tom";
        UserReferralCode[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = "Ab84";

        User[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = "Max";
        UserReferralCode[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = "4B20";

        User[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = "Jack";
        UserReferralCode[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = "7873";
    }

}