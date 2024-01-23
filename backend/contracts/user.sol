// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
pragma abicoder v2;

contract Users {
    mapping (address => string) User;

    //при регистрации пользователя мы получаем это значение с фронта (а регистрации у нас не будет!!!!!)
    //но когда мы регистрируем пользователей в конмтрукторе, мы сами задаём это значение (ручками пишем первые 4 значения из адреса)
    //потом просто будем сравнивать строки (когда это потребуется)
    mapping (address => string) UserReferralCode;  

    mapping (string => bool)   MyReferralCode;     //вводился ли код пользователя кем-то
    mapping (address => bool)   FriendReferralCode; //вводил ли пользователь чей-то код
    mapping (address => uint8)  Discont; 

    function Auth() public view returns(string memory name, string memory refCode, uint discont) {
        name = User[msg.sender];
        // balance = ERC20.balanceOf(msg.sender);
        refCode = UserReferralCode[msg.sender];
        discont = Discont[msg.sender];
    }

    function EnterReferralCode(string memory code) public {
        require(keccak256(abi.encode(UserReferralCode[msg.sender])) != keccak256(abi.encode(code)), "this is you're refferal code!");
        require(FriendReferralCode[msg.sender] == false, "you actived referral code!");
        require(MyReferralCode[code] == false, "this code alreadyactived");

        MyReferralCode[code] = true;
        Discont[msg.sender] += 1;
    }

    constructor() {
        User[0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266] = "Owner";
        UserReferralCode[0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266] = "PROFI5B382024";

        User[0x70997970C51812dc3A010C7d01b50e0d17dc79C8] = "Tom";
        UserReferralCode[0x70997970C51812dc3A010C7d01b50e0d17dc79C8] = "PROFIAb842024";

        User[0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC] = "Max";
        UserReferralCode[0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC] = "PROFI4B202024";

        User[0x90F79bf6EB2c4f870365E785982E1f101E93b906] = "Jack";
        UserReferralCode[0x90F79bf6EB2c4f870365E785982E1f101E93b906] = "PROFI78732024";
    }
}



