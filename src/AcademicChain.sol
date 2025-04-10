// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AcademicChain is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    struct Course {
        string name;
        uint8 credits;
        uint8 grade;
    }
    
    struct Student {
        string name;
        uint8 age;
        address payable wallet;
        Course[] courses;
        bool exists;
    }
    
    mapping(uint256 => Student) public students;
    uint256 public studentCount;
    
    event StudentAdded(uint256 indexed id, string name, uint8 age, address wallet);
    event StudentUpdated(uint256 indexed id, string name, uint8 age, address wallet);
    event StudentRemoved(uint256 indexed id);
    event CourseAdded(uint256 indexed studentId, string name, uint8 credits, uint8 grade);
    event CourseRemoved(uint256 indexed studentId, uint256 courseIndex);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }
    
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
    
    function checkIfWalletExists(address _wallet) private view returns (bool) {
        require(_wallet != address(0), "Invalid wallet address");
        for (uint256 i = 0; i < studentCount; i++) {
            if (students[i].wallet == _wallet && students[i].exists) {
                return true;
            }
        }
        return false;
    }
    
    function addStudent(
        string memory _name,
        uint8 _age,
        address payable _wallet
    ) public onlyAdmin {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_age >= 16 && _age <= 150, "Age must be between 16 and 150");
        require(_wallet != address(0), "Invalid wallet address");
        require(!checkIfWalletExists(_wallet), "Wallet already registered");
        
        uint256 id = studentCount++;
        Student storage newStudent = students[id];
        newStudent.name = _name;
        newStudent.age = _age;
        newStudent.wallet = _wallet;
        newStudent.exists = true;
        
        emit StudentAdded(id, _name, _age, _wallet);
    }
    
    function updateStudent(
        uint256 _studentId,
        string memory _name,
        uint8 _age,
        address payable _wallet
    ) public onlyAdmin {
        require(students[_studentId].exists, "Student does not exist");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_age >= 16 && _age <= 150, "Age must be between 16 and 150");
        require(_wallet != address(0), "Invalid wallet address");
        
        if (students[_studentId].wallet != _wallet) {
            require(!checkIfWalletExists(_wallet), "Wallet already registered");
        }
        
        Student storage student = students[_studentId];
        student.name = _name;
        student.age = _age;
        student.wallet = _wallet;
        
        emit StudentUpdated(_studentId, _name, _age, _wallet);
    }
    
    function removeStudent(uint256 _studentId) public onlyAdmin {
        require(students[_studentId].exists, "Student does not exist");
        
        delete students[_studentId];
        emit StudentRemoved(_studentId);
    }
    
    function addCourse(
        uint256 _studentId,
        string memory _name,
        uint8 _credits,
        uint8 _grade
    ) public onlyAdmin {
        require(students[_studentId].exists, "Student does not exist");
        require(bytes(_name).length > 0, "Course name cannot be empty");
        require(_credits > 0 && _credits <= 10, "Credits must be between 1 and 10");
        require(_grade <= 100, "Grade must be 0-100");
        
        Student storage student = students[_studentId];
        student.courses.push(Course({
            name: _name,
            credits: _credits,
            grade: _grade
        }));
        
        emit CourseAdded(_studentId, _name, _credits, _grade);
    }
    
    function removeCourse(uint256 _studentId, uint256 _courseIndex) public onlyAdmin {
        require(students[_studentId].exists, "Student does not exist");
        require(_courseIndex < students[_studentId].courses.length, "Invalid course index");
        
        Student storage student = students[_studentId];
        uint256 lastIndex = student.courses.length - 1;
        
        if (_courseIndex != lastIndex) {
            student.courses[_courseIndex] = student.courses[lastIndex];
        }
        student.courses.pop();
        
        emit CourseRemoved(_studentId, _courseIndex);
    }
    
    function getGPA(uint256 _studentId) public view returns (uint256) {
        require(students[_studentId].exists, "Student does not exist");
        
        Student storage student = students[_studentId];
        require(student.courses.length > 0, "No courses recorded");
        
        uint256 totalCredits = 0;
        uint256 totalPoints = 0;
        
        for (uint256 i = 0; i < student.courses.length; i++) {
            Course memory course = student.courses[i];
            totalCredits += course.credits;
            totalPoints += uint256(course.credits) * course.grade;
        }
        
        return (totalPoints * 100) / totalCredits;
    }
    
    function getStudentData(uint256 _studentId) public view returns (
        string memory name,
        uint8 age,
        address wallet,
        Course[] memory courses,
        bool exists
    ) {
        require(students[_studentId].exists, "Student does not exist");
        Student memory student = students[_studentId];
        return (student.name, student.age, student.wallet, student.courses, student.exists);
    }
    
    function addAdmin(address _admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(ADMIN_ROLE, _admin);
    }
    
    function removeAdmin(address _admin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_admin != msg.sender, "Cannot remove self as admin");
        revokeRole(ADMIN_ROLE, _admin);
    }
}