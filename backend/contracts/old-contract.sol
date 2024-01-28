// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
pragma abicoder v2;

import "./standart_token/token/ERC1155/ERC1155.sol";
import "./standart_token/token/ERC20/ERC20.sol";

// для REMIX
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract Contract is ERC20, ERC1155 {

    address Owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    uint public unicue_nft; //сколько видов nftшек создано в системе (то же самое что id)
    uint public unicue_collection; //сколько создано коллекций

    struct NFT {
        uint   Id;
        string Name;
        string Desimals;
        string ImageName; //path to photo
        uint   TotalReliased;
        uint   DataSet;
    }

    struct NftData {
        uint Id_Collection;
        string Name_Collection;
        string Description_Collection;
        bool Buy; //если колекция была куплена, пользователи могут продавать nft отдельно
    }

    // nft которые выставлены на продажу
    struct Sell_Nft {
        uint Id;
        NFT Nft;
        address Owner;
        uint Price;
        NftData Data;
    }

    struct Collection {
        uint Id;
        string Name;
        string Description;
        uint[] NftInCollection;
        uint[] AmountForNft;
    }

    // ставка к аукциону
    struct Bet {
        address Owner;
        uint Price;
    }

    struct Action {
        uint Id;
        Collection Collection;
        // address Owner;
        uint Time_Start;
        uint Time_End;
        uint Min_Price;
        uint Max_Price;
        // uint Id_Max_Bet;
    }


    // nft
    mapping (uint => NFT) public nft; //nft info
    mapping (uint => address) owner_nft;
    mapping (uint => uint) nft_price; //тут храниться стоимость nft
    mapping (uint => NftData) nft_data; //если nft в коллекции, тут лежит инфа о коллекции
    mapping (address => uint) user_amount_unicue_nft; // это нужно для удобства вывода nft пользователя
    mapping(uint => bool) SellOrNotSell_NFT; //get address user and id -> nft инфу о которой хотим узнать

    Sell_Nft[] public Sell_Only_Nft; //это массив для одиноких nftшек


    //  collection
    mapping (uint => Collection) public collection;
    mapping (uint => address) owner_collection;
    mapping (uint => bool) SellOrNotSell_Collection;
    mapping (address => uint) user_amount_unicue_collection; // это нужно для удобства вывода коллекций пользователя

    // action
    mapping (uint => Bet[]) public bet_to_action;
    Action[] public action;


    // user
    // mapping (address => string) User;

    // //при регистрации пользователя мы получаем это значение с фронта (а регистрации у нас не будет!!!!!)
    // //но когда мы регистрируем пользователей в конмтрукторе, мы сами задаём это значение (ручками пишем первые 4 значения из адреса)
    // //потом просто будем сравнивать строки (когда это потребуется)
    // mapping (address => string) UserReferralCode;  

    // mapping (string => bool)   MyReferralCode;     //вводился ли код пользователя кем-то
    // mapping (address => bool)   FriendReferralCode; //вводил ли пользователь чей-то код
    // mapping (address => uint8)  Discont;     

    modifier OnlyOwner() {
        require(msg.sender == Owner, "you're not owner");
        _;
    }


    function GetAllSellNft() public view returns(Sell_Nft[] memory) {
        return Sell_Only_Nft;
    }

    function GetAllAction() public view returns(Action[] memory) {
        return action;
    }

    function GetBetToAction(uint id) public view returns(Bet[] memory) {
        return bet_to_action[id];
    }








    function BuyProfi(uint amount) public payable {
        require(msg.value == amount, "Invalid msg.value");
        payable(Owner).transfer(amount);
        ERC20._transfer(Owner, msg.sender, amount);

    }

    // function Balance() public view returns(uint) {
    //     return ERC20.balanceOf(msg.sender);
    // }

    


    // function Auth() public view returns(string memory name, uint balance, string memory refCode, uint discont) {
    //     name = User[msg.sender];
    //     balance = ERC20.balanceOf(msg.sender);
    //     refCode = UserReferralCode[msg.sender];
    //     discont = Discont[msg.sender];
    // }

    // специальная структура для упрощения жизни фронтендера (чтобы не мучаться с совмещением двух массивов, как в прошлый раз)
    struct NftForUserLk {
        NFT NFT;
        uint Amount;
        // uint Price;
        NftData Data;
    }

    
    function GetAllUser_Nfts() public view returns(NftForUserLk[] memory) {
        uint ost = unicue_nft - user_amount_unicue_nft[msg.sender];
        NftForUserLk[] memory _nft = new NftForUserLk[](unicue_nft - ost);

        uint push;

        for (uint i = 0; i < unicue_nft; i++) {
            if (ERC1155.balanceOf(msg.sender, i) > 0) {
                _nft[push] = NftForUserLk(
                    nft[i], 
                    // ERC1155.balanceOf(msg.sender, i),
                    nft_price[i],
                    NftData(0, "", "", false) //заглушка, на фронте при выводе nft надо добавить проверку пустое значениеили нет, если пустое - не показывать, если не пустое - показывать
                );
                push += 1;
            } 
        }

        return _nft;
    }


    function GetAllUser_Collection() public view returns(Collection[] memory) {
        uint ost = unicue_collection - user_amount_unicue_collection[msg.sender];
        Collection[] memory _collection = new Collection[](unicue_collection - ost);

        uint push;

        for (uint i = 0; i < unicue_collection; i++) {
            if (owner_collection[i] == msg.sender) {
                _collection[push] = collection[i];
                push += 1;
            }
        }

        return _collection;
    } 

    
    function SetNft(
            string memory name,
            string memory description,
            string memory pathToImage,
            uint price, uint amount) public OnlyOwner() {
        
        require(amount > 0, "invalid amount token");

        ERC1155._mint(
            msg.sender, 
            unicue_nft, 
            amount, 
            ""
        );

        nft[unicue_nft] = NFT(
            unicue_nft,
            name,
            description,
            pathToImage,
            amount,
            block.timestamp
        );    
        nft_price[unicue_nft] = price;  
        owner_nft[unicue_nft] = msg.sender;

        user_amount_unicue_nft[msg.sender] += 1;
        unicue_nft += 1;
    }

    function SellNft(uint id, uint newPrice) public  {
        require(id <= unicue_nft, "nft does't exist");
        require(owner_nft[id] == msg.sender, "you are not owner this nft");
        require(SellOrNotSell_NFT[id] == false, "this nft already sale");  

        if (keccak256(abi.encode(nft_data[id].Name_Collection)) != keccak256(abi.encode(""))) {
            require(nft_data[id].Buy == true, "you are not sell this nft");
        }

        SellOrNotSell_NFT[id] = true;
        Sell_Only_Nft.push(Sell_Nft(
            Sell_Only_Nft.length,
            nft[id],
            msg.sender,
            newPrice,
            nft_data[id]
        ));
    }

    function BuyNft(uint id) public {
        uint price = Sell_Only_Nft[id].Price;
        address _owner = Sell_Only_Nft[id].Owner;

        require(id <= Sell_Only_Nft.length, "nft does't exist");
        require(_owner != msg.sender, "this you're nft, you are not buy him");
        require(ERC20.balanceOf(msg.sender) >= price, "invalid money");

        ERC20._transfer(msg.sender, Owner, price);

        ERC1155._safeTransferFrom(
            _owner, 
            msg.sender, 
            Sell_Only_Nft[id].Nft.Id, 
            ERC1155.balanceOf(_owner, id), 
            ""
        );

        owner_nft[id] = msg.sender;

        if (id < Sell_Only_Nft.length) {
            Sell_Only_Nft[Sell_Only_Nft.length - 1].Id = id;
            Sell_Only_Nft[id] = Sell_Only_Nft[Sell_Only_Nft.length - 1];
        }

        // TODO сделать так, чтобы инфа в nft_data обновилась на true

        Sell_Only_Nft.pop();
        SellOrNotSell_NFT[id] = false;

        user_amount_unicue_nft[msg.sender] += 1;
        user_amount_unicue_nft[_owner] -= 1;
    }










    function SetCollection(string memory name, string memory description) public OnlyOwner() {
        collection[unicue_collection] = Collection(
            unicue_collection,
            name, 
            description,
            new uint[](0),
            new uint[](0)
        );

        owner_collection[unicue_collection] = msg.sender;
        user_amount_unicue_collection[msg.sender] += 1;

        unicue_collection += 1;
    }


    function SetNftForCollection(
            uint idCollection,
            string memory name,
            string memory description,
            string memory pathToImage, uint price, 
            uint amount) public OnlyOwner() {

        require(amount > 0, "invalid amount");
        require(idCollection <= unicue_collection, "collection does'n exist");

        nft_data[unicue_nft] = NftData(idCollection, collection[idCollection].Name, collection[idCollection].Description, false);

        collection[idCollection].NftInCollection.push(unicue_nft);
        collection[idCollection].AmountForNft.push(amount);

        SetNft(name, description, pathToImage, price, amount);
    }



    function SetAction(
            uint idCollection,
            uint start,
            uint end,
            uint min,
            uint max) public OnlyOwner() {
        require(SellOrNotSell_Collection[idCollection] == false, "this collection already sale");
        // require(start >= block.timestamp && end >= block.timestamp, "Invalid time");
        require(min > 0 && max > min, "Invalid price");
        require(idCollection <= unicue_collection, "collection does'n exist");

        SellOrNotSell_Collection[idCollection] = true;

        bet_to_action[action.length].push(Bet(address(0), 0));

        action.push(Action(
            action.length,
            collection[idCollection],
            // msg.sender,
            start,
            end,
            min,
            max
            // 0
        ));
    }

    function SetBet(uint id, uint bet) public {
        require(id <= action.length, "action does't exist");
        // require(action[id].Time_Start <= block.timestamp, "action is not started"); //разкоментить для итогового решения, для тестов эти параметры мешаются, но они работают
        // require(action[id].Time_End >= block.timestamp, "action the end");
        require(ERC20.balanceOf(msg.sender) >= bet, "invalid money");
        require(bet > bet_to_action[id][bet_to_action[id].length - 1].Price, "bet is small");
        require(bet >= action[id].Min_Price, "bet is lasnet in minimal bet"); //мне лень пользоваться переводчиком
        require(bet <= action[id].Max_Price, "bet is bigger");

        // action[id].Id_Max_Bet = bet_to_action[id].length;

        bet_to_action[id].push(Bet(
            msg.sender,
            bet
        ));
    }


    function EndAction(uint id) public OnlyOwner() {
        address owner_bet = bet_to_action[id][bet_to_action[id].length - 1].Owner;
        uint price = bet_to_action[id][bet_to_action[id].length - 1].Price;

        require(id <= action.length, "action does'n exist");
        require(bet_to_action[id].length > 1, "null bet, you're not end this action");

        ERC20._transfer(owner_bet, Owner, price);

        ERC1155._safeBatchTransferFrom(
            Owner, 
            owner_bet, 
            action[id].Collection.NftInCollection, 
            action[id].Collection.AmountForNft, 
            ""
        );

        user_amount_unicue_nft[owner_bet] += action[id].Collection.NftInCollection.length;

        owner_collection[action[id].Collection.Id] = owner_bet;
        SellOrNotSell_Collection[action[id].Collection.Id] = false;


        if (id < action.length) {
            bet_to_action[id] = bet_to_action[action.length - 1];

            action[action.length - 1].Id = id;
            action[id] = action[action.length - 1];
        }

        delete bet_to_action[action.length - 1];
        action.pop();



        user_amount_unicue_collection[Owner] -= 1;
        user_amount_unicue_collection[owner_bet] += 1;
    }


    // function EnterReferralCode(string memory code) public {
    //     require(keccak256(abi.encode(UserReferralCode[msg.sender])) != keccak256(abi.encode(code)), "this is you're refferal code!");
    //     require(FriendReferralCode[msg.sender] == false, "you actived referral code!");
    //     require(MyReferralCode[code] == false, "this code alreadyactived");

    //     MyReferralCode[code] = true;
    //     Discont[msg.sender] += 1;
    // }











    constructor() ERC20("Professional", "PROFI") ERC1155("./images/") {
        // в папках проекта изменить параметр в функции decimals контракта ERC20 с 18и на 6 (так указано в тз)
        ERC20._mint(Owner, 1000000);

        // User[Owner] = "Owner";
        // UserReferralCode[Owner] = "PROFI5B382024";

        // User[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = "Tom";
        // UserReferralCode[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = "PROFIAb842024";

        // User[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = "Max";
        // UserReferralCode[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = "PROFI4B202024";

        // User[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = "Jack";
        // UserReferralCode[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = "PROFI78732024";
    }

}