//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
/**
* @title Payroll Smart contract
*  @author Owusu Nelson Osei Tutu
*  @notice A smart contract for paying employees worldwide handled by chainlink functions
*/ 


contract Payroll {
    //employee details
    struct Employee {
        string employeeName;
        uint256 hourlyRate;
        uint256 hoursWorked;
        uint256 lastPaymentTime;
    }

    /*
       Events
    */

    //mapping of employee payment address to employee details
    mapping(address => Employee) public employees;
    address public owner;

    //interval set for emloyees to be paid
    uint256 public paymentInterval = 30 days;


   /*
     Modifiers   
   */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

   /*
     Functions
   */

   //register employee
    function registerEmployee(string memory emp_name,address _employee, uint256 _hourlyRate) public onlyOwner {
        employees[_employee] = Employee(emp_name,_hourlyRate, 0, block.timestamp);
    }

    /*
      functions to be handled by automation
    */
    function updateHours(address _employee, uint256 _hoursWorked) public onlyOwner {
        employees[_employee].hoursWorked += _hoursWorked;
    }

    function calculatePayment(address _employee) public view returns (uint256) {
        Employee memory emp = employees[_employee];
        return emp.hourlyRate * emp.hoursWorked;
    }

    function payEmployee(address _employee) public onlyOwner {
        Employee storage emp = employees[_employee];
        uint256 payment = calculatePayment(_employee);
        require(address(this).balance >= payment, "Insufficient funds");
        payable(_employee).transfer(payment);
        emp.hoursWorked = 0;
        emp.lastPaymentTime = block.timestamp;
    }
   
   //fund contract
    function fundContract() public payable onlyOwner {}

    //withdraw funds
    function withdrawFunds(uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient funds");
        payable(owner).transfer(_amount);
    }
}
