pragma solidity ^0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract TNStoken is Ownable {

    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping(address => uint256) locked;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 totalSupply_;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Locked(address indexed owner, uint256 indexed amount);

    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() public {
        name = "The Neverending Story Token";
        symbol = "TNS";
        decimals = 18;
        totalSupply_ = 100 * 10**6 * 10**18;
        balances[msg.sender] = totalSupply_;
    }

    function increaseLockedAmount(address _owner, uint256 _amount) onlyOwner public returns (uint256) {
        uint256 lockingAmount = locked[_owner].add(_amount);
        require(balanceOf(_owner) >= lockingAmount, "Locking amount must not exceed balance");
        locked[_owner] = lockingAmount;
        emit Locked(_owner, lockingAmount);
        return lockingAmount;
    }

    function decreaseLockedAmount(address _owner, uint256 _amount) onlyOwner public returns (uint256) {
        require(locked[_owner] > 0, "Cannot go negative. Already at 0 locked tokens.");
        uint256 lockingAmount = locked[_owner].sub(_amount);
        locked[_owner] = lockingAmount;
        emit Locked(_owner, lockingAmount);
        return lockingAmount;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender] - locked[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from] - locked[_from]);
        require(_value <= allowed[_from][msg.sender] - locked[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
        require(_spender != address(this));
        this.approve(_spender, _value);
        // solium-disable-next-line security/no-call-value
        require(_spender.call.value(msg.value)(_data));
        return true;
    }

    function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
        require(_to != address(this));
        this.transfer(_to, _value);
        // solium-disable-next-line security/no-call-value
        require(_to.call.value(msg.value)(_data));
        return true;
    }

    function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data ) public payable returns (bool) {
        require(_to != address(this));
        this.transferFrom(_from, _to, _value);
        // solium-disable-next-line security/no-call-value
        require(_to.call.value(msg.value)(_data));
        return true;
    }

    function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
        require(_spender != address(this));
        this.increaseApproval(_spender, _addedValue);
        // solium-disable-next-line security/no-call-value
        require(_spender.call.value(msg.value)(_data));
        return true;
    }

    function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
        require(_spender != address(this));
        this.decreaseApproval(_spender, _subtractedValue);
        // solium-disable-next-line security/no-call-value
        require(_spender.call.value(msg.value)(_data));
        return true;
    }
}
