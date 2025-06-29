// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Contract is ERC20("Professional", "PROFI"), ERC1155("./images/") {

    //эти параметры нужны для назначения уникального номера нфт и коллекции
    uint nft_unicue;
    uint collection_unicue = 1;

    //для  remix
    // address Owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    address Owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;


    //пользователь
    struct User {
        string Name;
        string RefCode;
        string FriendRefCode;
        uint Discont;
        bool ActiveRefCode;
    }


    //нфт
    struct NFT {
        uint Id;
        string Name;
        string Desc;
        string Image;
        uint Price;
        uint Amount;
        uint TimeSet;
    }

    //продающиеся нфт
    struct Sell_Nft {
        uint Id;
        NFT NFT;
        address Owner;
        string Name_Col;
        string Desc_Col;
        bool SellOrNot;
    }

    //коллекция
    struct Collection {
        uint Id;
        string Name;
        string Desc;
        uint[] Nfts;
        uint[] AmountNfts;
    }


    //ставка
    struct Bet {
        address Owner;
        uint Price;
    }


    //аукцион
    struct Action {
        uint Id;
        Collection Collection;
        uint Start;
        uint End;
        uint Min;
        uint Max;
    }


    //вот тут хранятся данные

    //nft
    mapping (uint => NFT) nft;
    mapping (uint => uint) nftCollectionId;
    mapping (uint => bool) nftSellOrNot;
    mapping (address => uint) userNft;
    Sell_Nft[] sell;

    //collection
    mapping (uint => Collection) collection;
    mapping (uint => bool) collectionSellOrNot;
    mapping (uint => address) collectionOwner;
    mapping (address => uint) userCollection;    

    //action
    mapping (uint => Bet[]) bets;
    Action[] action;

    //user
    mapping (address => User) user;
    mapping (string => bool) refCodeActive;


    //проверка на владельца
    modifier OnlyOwner() {
        require(msg.sender == Owner, "you are not Owner!");
        _;
    }


    //показать все аукционы
    function getAcrion() public view returns (Action[] memory) {
        return action;
    }

    //показать все продающиеся нфт
    function getSellNft() public view returns (Sell_Nft[] memory) {
        return sell;
    }

    //показать ставки к аукциону
    function getBetToAcrion(uint id) public view returns (Bet[] memory) {
        return bets[id];
    }

    //авторизация
    function auth() public view returns (User memory u, uint b) {
        u = user[msg.sender];
        b = ERC20.balanceOf(msg.sender);
    }


    //показать нфт пользователя
    function getUserNft() public view returns (Sell_Nft[] memory) {
        Sell_Nft[] memory _nft = new Sell_Nft[](userNft[msg.sender]);
        uint push;

        for(uint i = 0; i < nft_unicue; i ++) {
            if(ERC1155.balanceOf(msg.sender, i) > 0) {
                _nft[push] = Sell_Nft(
                    0,
                    nft[i],
                    address(0),
                    collection[nftCollectionId[i]].Name,
                    collection[nftCollectionId[i]].Desc,
                    nftSellOrNot[i]
                );
                push += 1;
            }
        }

        return _nft;
    }

    //показать коллекции пользователя
    function getUserCollection() public view returns (Collection[] memory) {
        Collection[] memory _nft = new Collection[](userCollection[msg.sender]);
        uint push;

        for(uint i = 1; i < collection_unicue; i++) {
            if(collectionOwner[i] == msg.sender) {
                _nft[push] = collection[i];
                push += 1;
            }
        }

        return _nft;
    }

    //создать нфт
    //может только владелец
    //функция принимает все необходимые параметры для нфт
    //и значение - надо её стразу продавать или нет
    function setNft(
        string memory name,
        string memory desc,
        string memory image,
        uint price,
        uint amount,
        bool _sell
    ) public OnlyOwner() {
        require(amount > 0, "invalid amount");

    //создаём нфт
        ERC1155._mint(
            Owner, 
            nft_unicue,
            amount,
            ""
        );

    //записываем данные о ней
        nft[nft_unicue] = NFT(
            nft_unicue,
            name,
            desc,
            image,
            price,
            amount,
            block.timestamp
        );

    //добавили владельцу нфт
        userNft[Owner] += 1;

    //если передали true то продаём нфт
        if(_sell == true) {
            sellNft(nft_unicue, price);
        }

        nft_unicue += 1;
    }


    //продать нфт 
    //может любой пользователь
    //принимает номер и стоимость
    function sellNft(uint id, uint price) public {
        require(price > 0, "invalid price");
        require(id <= nft_unicue, "invalid id");
        require(nftSellOrNot[id] == false && ERC1155.balanceOf(msg.sender, id) > 0, "this nft already sell or you are not owner this nft");

    //если нфт в коллекции и функцию вызвал взаделец
    //функция не сработает
        if(nftCollectionId[id] != 0) {
            require(msg.sender != Owner, "you can not sell this nft");
        }

    //меняем стоимость
        nft[id].Price = price;

    //меняем статус нфт
        nftSellOrNot[id] = true;

    //добавляем в продающиеся
        sell.push(Sell_Nft(
            sell.length,
            nft[id],
            msg.sender,
            collection[nftCollectionId[id]].Name,
            collection[nftCollectionId[id]].Desc,
            true
        ));
    }

    //купить нфт
    function buyNft(uint id) public {
        require(id < sell.length, "invalid id");

        address _owner = sell[id].Owner;
        uint price = sell[id].NFT.Price;

        require(ERC20.balanceOf(msg.sender) >= price && msg.sender != _owner, "not money or you owner this nft");

    //переводим наш PROFI токег
        ERC20._transfer(msg.sender, _owner, price);

    //переводим саму нфт
        ERC1155._safeTransferFrom(
            _owner,
            msg.sender,
            sell[id].NFT.Id,
            sell[id].NFT.Amount,
            ""
        );

    //поменяли значения у пользоватлей
        userNft[msg.sender] += 1;
        userNft[_owner] -= 1;

    //меняем статус
        nftSellOrNot[sell[id].NFT.Id] = false;

    //чистим масив
        sell[sell.length - 1].Id = id;
        sell[id] = sell[sell.length - 1];
        sell.pop();
    }

    //создать коллекцию
    //доступна только владелеу
    //принимает все необходимые параменты
    function setCollection(string memory name, string memory desc) public OnlyOwner() {
        
    //создаём коллекцию
        collection[collection_unicue] = Collection(
            collection_unicue,
            name,
            desc,
            new uint[](0),
            new uint[](0)
        );

    //добавили коллекцию владельцу
        userCollection[Owner] += 1;
        collectionOwner[collection_unicue] = Owner;

        collection_unicue += 1;
    }


    ///добавить в коллекцию нфт 
    ///доступна только владельцу 
    ///принимает все нужные параметры 
    function setNftInCollection(
        uint id,
        string memory name,
        string memory desc,
        string memory image,
        uint amount
    ) public OnlyOwner {
        require(id < collection_unicue, "invalid id");
        require(collectionSellOrNot[id] == false, "this collection already sell");
        require(amount > 0, "invalid amount");

    //добавляем в коллекцию
        collection[id].Nfts.push(nft_unicue);
        collection[id].AmountNfts.push(amount);

    //говорим нфт о том, что она в коллекции
        nftCollectionId[nft_unicue] = id;
        
    //создаём нфт
        setNft(name, desc, image, 0, amount, false);
    }

    //создать аукцион
    //доступна только владельцу
    //принимает все нужные параметры
    function setAction(
        uint id,
        uint start,
        uint end,
        uint min,
        uint max 
    ) public OnlyOwner {
        require(id < collection_unicue, "invalid id");
        require(collectionSellOrNot[id] == false, "this collection already sell");

    //создали дефолтную ставку
        bets[action.length].push(Bet(address(0), 0));

    //создали аукцион
        action.push(Action(
            action.length,
            collection[id],
            start,
            end,
            min,
            max
        ));

    //сказали коллекции что она продаётся
        collectionSellOrNot[id] = true;
    }

    //создать ствку
    function setBet(uint id, uint price) public {
        require(id < action.length, "invalid id");
        require(price >= action[id].Min && price <= action[id].Max && price > bets[id][bets[id].length - 1].Price, "invalid bet");

    //создали
        bets[id].push(Bet(msg.sender, price));

    //если достигнута максимальная ставка, заканчиваем аукцион
        if(price == action[id].Max) {
            endAction(id, Owner);
        }
    }

    //закончить аукцион
    //доступна только владельцу
    //принимает номер аукциона и адрес того, что вызываеит функцию
    function endAction(uint id, address sender) public {
        require(sender == Owner, "you are not Owner");
        require(id < action.length, "invalid id");

        address _owner = bets[id][bets[id].length - 1].Owner;
        uint price = bets[id][bets[id].length - 1].Price;
        Collection memory col = action[id].Collection;

    //перевели деньги
        ERC20._transfer(_owner, Owner, price);

    //перевели нфт
        ERC1155._safeBatchTransferFrom(
            Owner,
            _owner,
            col.Nfts,
            col.AmountNfts,
            ""
        );

    //поменяли значение
        userNft[Owner] -= col.Nfts.length;
        userNft[_owner] += col.Nfts.length;

        collectionOwner[col.Id] = _owner;

    //поменяли значение
        userCollection[Owner] -= 1;
        userCollection[_owner] += 1;

    //обновляем ставки
        bets[id] = bets[action.length - 1];

    //чистим аукцион
        action[action.length - 1].Id = id;
        action[id] = action[action.length - 1];

        delete bets[action.length - 1];
        action.pop();
    }


    //отправить реферальный код другу
    function transferRefCode(address friend) public {
        require(friend != msg.sender && friend != address(0), "invalid address");
        user[friend].FriendRefCode = user[msg.sender].RefCode;
    }

    //ввести рефералдьный код
    function enterRefCode(string memory code) public {
        require(user[msg.sender].ActiveRefCode == false && refCodeActive[code] == false, "you already active ref code or this code already active");
        require(keccak256(abi.encode(code)) != keccak256(abi.encode(user[msg.sender].RefCode)), "this you ref code");
        
        user[msg.sender].ActiveRefCode = true;
        refCodeActive[code] = true;

        ERC20._mint(msg.sender, 100);
        
        if(user[Owner].Discont < 3) {
            user[Owner].Discont += 1;
        }
    }

    //перевести нфт пользователю
    function transferNftForFriend(uint id, address friend) public {
        require(id < nft_unicue, "invalid id");
        require(ERC1155.balanceOf(msg.sender, id) > 0 && nftSellOrNot[id] == false, "you are not owner this token or this token already sell");

        ERC1155._safeTransferFrom(
            msg.sender,
            friend,
            id,
            ERC1155.balanceOf(msg.sender, id),
            ""
        );

        userNft[msg.sender] -= 1;
        userNft[friend] += 1;
    }

    constructor() {
        ERC20._mint(Owner, 1000000);

        //для remix
        // user[Owner] = User("Owner", "PROFI5B382024", "", 0, false);
        // user[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = User("Tom", "PROFI5B382024", "", 0, false);
        // ERC20._transfer(Owner, 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 200000);

        // user[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = User("Max", "PROFI4B202024", "", 0, false);
        // ERC20._transfer(Owner, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 300000);

        // user[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = User("Jack", "PROFI78732024", "", 0, false);
        // ERC20._transfer(Owner, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 400000);


        user[Owner] = User("Owner", "PROFIf39F2024", "", 0, false);
        user[0x70997970C51812dc3A010C7d01b50e0d17dc79C8] = User("Tom", "PROFI70992024", "", 0, false);
        ERC20._transfer(Owner, 0x70997970C51812dc3A010C7d01b50e0d17dc79C8, 200000);

        user[0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC] = User("Max", "PROFI3C442024", "", 0, false);
        ERC20._transfer(Owner, 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC, 300000);

        user[0x90F79bf6EB2c4f870365E785982E1f101E93b906] = User("Jack", "PROFI90F72024", "", 0, false);
        ERC20._transfer(Owner, 0x90F79bf6EB2c4f870365E785982E1f101E93b906, 400000);




        setNft("Funny Cat", "This Cat is fun", "cat_nft1.png", 0, 10, false);
        setNft("Husky", "This is husky", "husky_nft1.png", 0, 50, false);
        setNft("Walker", "This is walker", "walker_nft1.png", 0, 100, false);
    }
}