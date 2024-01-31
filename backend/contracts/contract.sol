// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
pragma abicoder v2;

import "./standart_token/token/ERC1155/ERC1155.sol";
import "./standart_token/token/ERC20/ERC20.sol";

// для REMIX
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract Contract is ERC20, ERC1155 {

    //для remix
    // address Owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    address Owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    uint public unicue_nft; //сколько видов nftшек создано в системе (то же самое что id)
    uint public unicue_collection; //сколько создано коллекций в системе (то же самое что id)

    struct NFT {
        uint   Id;
        string Name;
        string Desimals;
        string ImagePath;     //path to photo
        uint   TotalReliased;
        uint   DataSet;
    }


    //уникальная структура, котору мы можем отображать в лк пользователя и когда nft продаётся
    //облегчаем контракт, чтобы у нас не было 33 структуры
    struct Sell_Nft {
        uint Id;           //нужно заполнять и учитывать только когда показываем при продаже
        NFT NFT;
        address Owner;     //нужно заполнять и учитывать только когда показываем при продаже
        uint Price;        //нужно заполнять и учитывать только когда показываем при продаже
        bool In_Colection; //на фронтке мы будем обрабатывать этот параметр, если true, то показывает инфу ниже
        string Name_Collection;
        string Description_Collection;
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
        uint Time_Start;
        uint Time_End;
        uint Min_Price;
        uint Max_Price;
    }

    struct User {
        string Login;
        string Refferal_Code;
        uint Discont;
    }


    // nft
    mapping (uint => NFT) public nft; //nft info
    mapping (uint => bool) nft_in_collection; //если nft в коллекции, тут true
    mapping (uint => uint) nft_number_collection; //тут лежить номер коллекции, если nft находится в ней
    mapping (address => uint) user_amount_unicue_nft; // это нужно для удобства вывода nft пользователя
    mapping (uint => bool) SellOrNotSell_NFT; //get address user and id -> nft инфу о которой хотим узнать

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
    mapping (address => User) user;
    mapping (string => address) MyReferralCodeAddress;
    mapping (string => bool)    MyReferralCodeBool;     //вводился ли код пользователя кем-то
   

    modifier OnlyOwner() {
        require(msg.sender == Owner, "you are not owner");
        _;
    }

// +
    function GetAllSellNft() public view returns(Sell_Nft[] memory) {
        return Sell_Only_Nft;
    }

// +
    function GetAllAction() public view returns(Action[] memory) {
        return action;
    }

    function GetBetToAction(uint id) public view returns(Bet[] memory) {
        return bet_to_action[id];
    }


// +
    function Auth() public view returns(User memory _user, uint balance) {
        _user = user[msg.sender];
        balance = ERC20.balanceOf(msg.sender);
    }

    
    // +
    function GetAllUser_Nfts() public view returns(Sell_Nft[] memory) {
        // uint ost = unicue_nft - user_amount_unicue_nft[msg.sender];
        // Sell_Nft[] memory _nft = new Sell_Nft[](unicue_nft - ost);
        Sell_Nft[] memory _nft = new Sell_Nft[](user_amount_unicue_nft[msg.sender]);

        uint push;

        for (uint i = 0; i < unicue_nft; i++) {
            if (ERC1155.balanceOf(msg.sender, i) > 0) {
                _nft[push] = Sell_Nft(
                    0,          //не заполняем т.к. это отображается в лк пользователя, и этот параметр нам не нужен
                    nft[i],
                    address(0), //не заполняем т.к. это отображается в лк пользователя, и этот параметр нам не нужен
                    0,          //не заполняем т.к. это отображается в лк пользователя, и этот параметр нам не нужен
                    nft_in_collection[i],
                    collection[nft_number_collection[i]].Name,
                    collection[nft_number_collection[i]].Description
                );
                push += 1;
            } 
        }

        return _nft;
    }

// +
    function GetAllUser_Collection() public view returns(Collection[] memory) {
        //работает - не трогаем
        // uint ost = unicue_collection - user_amount_unicue_collection[msg.sender];
        // Collection[] memory _collection = new Collection[](unicue_collection - ost);
        Collection[] memory _collection = new Collection[](user_amount_unicue_collection[msg.sender]);

        uint push;

        for (uint i = 0; i < unicue_collection; i++) {
            if (owner_collection[i] == msg.sender) {
                _collection[push] = collection[i];
                push += 1;
            }
        }

        return _collection;
    } 

    // +
    function SetNft(
            string memory name,
            string memory description,
            string memory pathToImage,
            uint amount) public OnlyOwner() {
        
        require(amount > 0, "invalid amount token");

        //создаём нфтишку в системе 
        ERC1155._mint(
            msg.sender, 
            unicue_nft, 
            amount, 
            ""
        );

        //записываем инфу о ней для себя
        nft[unicue_nft] = NFT(
            unicue_nft,
            name,
            description,
            pathToImage,
            amount,
            block.timestamp
        );    

        //обновляем общее кол-во нфтишек в системе, и кол-во у пользователя
        user_amount_unicue_nft[msg.sender] += 1;
        unicue_nft += 1;
    }

    // +
    function SellNft(uint id, uint newPrice) public  {
        // && SellOrNotSell_NFT[id] == false
        require(id <= unicue_nft && ERC1155.balanceOf(msg.sender, id) > 0, "invalid input"); 

        SellOrNotSell_NFT[id] = true;
        Sell_Only_Nft.push(Sell_Nft(
            Sell_Only_Nft.length,
            nft[id],
            msg.sender,
            newPrice,
            nft_in_collection[id],
            collection[nft_number_collection[id]].Name,
            collection[nft_number_collection[id]].Description
        ));
    }

    // +
    function BuyNft(uint id) public {
        //назначаем переменные для нашего удобства и облегчения контракта
        uint price = Sell_Only_Nft[id].Price;
        address _owner = Sell_Only_Nft[id].Owner;
        uint nft_id = Sell_Only_Nft[id].NFT.Id;

        require(id <= Sell_Only_Nft.length && _owner != msg.sender && ERC20.balanceOf(msg.sender) >= price, "nft problem");

        //переводим монетки
        ERC20._transfer(msg.sender, _owner, price);

        //переводим нфтишку
        ERC1155._safeTransferFrom(
            _owner, 
            msg.sender, 
            nft_id, 
            ERC1155.balanceOf(_owner, nft_id), 
            ""
        );

        //обновляем кол-во нфтишек у пользователей
        user_amount_unicue_nft[msg.sender] += 1;
        user_amount_unicue_nft[_owner] -= 1;   

        //если не последняя, переписываем на её место последнюю, ибо в солидити можно удалять только последний элемент
        if (id < Sell_Only_Nft.length - 1) {
            Sell_Only_Nft[Sell_Only_Nft.length - 1].Id = id; //это делать обязательно, иначе возникнет путаница и всё сломается
            Sell_Only_Nft[id] = Sell_Only_Nft[Sell_Only_Nft.length - 1];
        }

        Sell_Only_Nft.pop();
        SellOrNotSell_NFT[nft_id] = false; //была исправлена ошибка

    }









// +
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

// +
    function SetNftForCollection(
            uint idCollection,
            string memory name,
            string memory description,
            string memory pathToImage, 
            uint amount) public OnlyOwner() {

        require(amount > 0 && idCollection <= unicue_collection, "invalid amount or collection does not exist");

        //назначаем параметры того, что нфтишка принадлешить коллекции
        nft_in_collection[unicue_nft] = true;
        nft_number_collection[unicue_nft] = idCollection;

        //добавляем её в коллекцию
        collection[idCollection].NftInCollection.push(unicue_nft);
        collection[idCollection].AmountForNft.push(amount);

        //создаём нфтишку
        SetNft(name, description, pathToImage, amount);
    }


// +
    function SetAction(
            uint idCollection,
            uint start,
            uint end,
            uint min,
            uint max) public OnlyOwner() {
        require(SellOrNotSell_Collection[idCollection] == false && idCollection <= unicue_collection, "invalid collection");
        //это обязательная проверка на время
        require(start >= block.timestamp && end >= block.timestamp, "Invalid time"); //для тестов можно комнтить, но в итоговом решении она должна быть

        //обновляем статус коллекции на - продаётся
        SellOrNotSell_Collection[idCollection] = true;

        //инициализируем мапинг (если мы это не сделаем, то мы не сможем с ним работать)
        //на фронте первую ставку не показываем, она дефолтная, для того, чтобы всё работало
        //в функции EndAction есть проверка на кол-во ставок, если кроме этой ставок сделано не было, мы не сможем закончить аукцион
        //можно проверять, можно не проверять, но тогда в случае чего ERC20 будет ругаться, и функция в любом случае вернёт ошибку
        //так что, лучше проверять
        bet_to_action[action.length].push(Bet(address(0), 0));

        action.push(Action(
            action.length,
            collection[idCollection],
            start,
            end,
            min,
            max
        ));
    }

    // +
    function SetBet(uint id, uint bet) public {
        //это обязательная проверка на время
        require(id <= action.length && action[id].Time_Start <= block.timestamp && action[id].Time_End >= block.timestamp, "invaid time"); //для тестов можно комнтить, но в итоговом решении она должна быть
        require(ERC20.balanceOf(msg.sender) >= bet && bet > bet_to_action[id][bet_to_action[id].length - 1].Price && bet >= action[id].Min_Price && bet <= action[id].Max_Price, "invalid money of invalid bet");

        bet_to_action[id].push(Bet(
            msg.sender,
            bet
        ));

        if (bet == action[id].Max_Price) {
            EndAction(id);
        }
    }

    // +
    function EndAction(uint id) public OnlyOwner() {
        //назначаем переменные, так как мы вызываем эти параметры несколько раз 1 - нам проще, 2 - констракт легче
        address owner_bet = bet_to_action[id][bet_to_action[id].length - 1].Owner;
        uint price = bet_to_action[id][bet_to_action[id].length - 1].Price;

        require(id <= action.length && bet_to_action[id].length > 1, "action does not exist or null bet, you are not end this action");

        //переводим токены (монетки) от владельца ставки владельцу системы (потому что аукционы может созлдавать только он)
        ERC20._transfer(owner_bet, Owner, price);

        //переводим нфтишки
        ERC1155._safeBatchTransferFrom(
            Owner, 
            owner_bet, 
            action[id].Collection.NftInCollection, 
            action[id].Collection.AmountForNft, 
            ""
        );

        //изменяем количество нфтишек у пользователей 
        user_amount_unicue_nft[owner_bet] += action[id].Collection.NftInCollection.length; 
        user_amount_unicue_nft[Owner] -= action[id].Collection.NftInCollection.length;

        //назначаем коллекции нового владельца и обновляем статус коллекции - не продаётся
        owner_collection[action[id].Collection.Id] = owner_bet;
        SellOrNotSell_Collection[action[id].Collection.Id] = false;

        //если это не последний аукцион, перепишем на место того, который хотим удалить последний
        //так делаем потому что .pop() может удалить только последный элемент
        if (id < action.length) {
            //если мы переписываем аукцион, то его айдишник изменится, значит и ставки мы тоже должны переписать
            bet_to_action[id] = bet_to_action[action.length - 1];

            action[action.length - 1].Id = id;
            action[id] = action[action.length - 1];
        }

        //обязательно чистим мапинг 
        delete bet_to_action[action.length - 1];
        action.pop();

        //изменяем количество коллекций у пользователей 
        user_amount_unicue_collection[Owner] -= 1;
        user_amount_unicue_collection[owner_bet] += 1;
    }

// +
    // ввести реферальный код
    function EnterReferralCode(string memory code) public {
        //ставниваем строчки
        require(keccak256(abi.encode(user[msg.sender].Refferal_Code)) != keccak256(abi.encode(code)) && user[msg.sender].Discont == 0, "this is you are refferal code! or you actived referral code!");
        require(MyReferralCodeBool[code] == false, "this code alreadyactived");

        user[MyReferralCodeAddress[code]].Discont += 1;
        ERC20._mint(msg.sender, 100);

        MyReferralCodeBool[code] = true;
    }




    //ERC20("Professional", "PROFI") - этой строчкой мы задаём name и simbol токена (монетки)
    //ERC1155("./images/") - тут указывается uri адрес для токена, но мы пишем сюда любую заглушку, ибо оно не используется в нашем коде
    constructor() ERC20("Professional", "PROFI") ERC1155("./images/") {
        // в папках проекта изменить параметр в функции decimals контракта ERC20 с 18и на 6 (так указано в тз)
        ERC20._mint(Owner, 1000000);


        user[Owner] = User("Owner", "PROFI70992024", 0);

        user[0x70997970C51812dc3A010C7d01b50e0d17dc79C8] = User("Tom", "PROFI3C442024", 0);
        ERC20._transfer(Owner, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 200000);

        user[0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC] = User("Max", "PROFI90F72024", 0);
        ERC20._transfer(Owner, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, 300000);

        user[0x90F79bf6EB2c4f870365E785982E1f101E93b906] = User("Jack", "PROFI15d32024", 0);
        ERC20._transfer(Owner, 0x90F79bf6EB2c4f870365E785982E1f101E93b906, 400000);

        //remix
        // user[0x70997970C51812dc3A010C7d01b50e0d17dc79C8] = User("Tom", "PROFI4B202024", 0);
        // ERC20._transfer(Owner, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 200000);

        // user[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = User("Max", "PROFI78732024", 0);
        // ERC20._transfer(Owner, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 300000);

        // user[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = User("Jack", "PROFI617F2024", 0);
        // ERC20._transfer(Owner, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 400000);
    }

}