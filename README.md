# AcademicChain Smart Contract

A Solidity smart contract for managing academic records on the blockchain, deployed on the Base Sepolia test network.

## Contract Address

**Base Sepolia:** `0x9ADe272f23BE03f01CA9b79740094368beec372C`

## Overview

AcademicChain is a smart contract designed to store and manage student academic information on the blockchain. The contract allows administrators to add, update, and remove student records, as well as manage courses, grades, and calculate GPAs.

## Features

- **Role-Based Access Control**: Using OpenZeppelin's AccessControl for administrator management
- **Student Management**: Add, update, and remove student records
- **Course Management**: Add and remove courses for each student
- **GPA Calculation**: Automatic calculation of GPA based on course credits and grades
- **Data Integrity**: Validations to ensure data quality and prevent duplicates

## Contract Structure

### Data Structures

- **Course**
  - `name`: Course name (string)
  - `credits`: Number of credits (uint8, 1-10)
  - `grade`: Course grade (uint8, 0-100)

- **Student**
  - `name`: Student name (string)
  - `age`: Student age (uint8, must be 16-150)
  - `wallet`: Ethereum wallet address (address payable)
  - `courses`: Array of Course structures
  - `exists`: Boolean flag to track existence

### State Variables

- `students`: Mapping from student ID to Student structure
- `studentCount`: Total number of students registered
- `ADMIN_ROLE`: Access control role for administrative functions

### Events

- `StudentAdded`: Emitted when a new student is added
- `StudentUpdated`: Emitted when student information is updated
- `StudentRemoved`: Emitted when a student is removed
- `CourseAdded`: Emitted when a course is added to a student's record
- `CourseRemoved`: Emitted when a course is removed from a student's record

## Functions

### Administrative Functions

- `addAdmin(address _admin)`: Grant admin role to an address
- `removeAdmin(address _admin)`: Revoke admin role from an address

### Student Management

- `addStudent(string memory _name, uint8 _age, address payable _wallet)`: Register a new student
- `updateStudent(uint256 _studentId, string memory _name, uint8 _age, address payable _wallet)`: Update student information
- `removeStudent(uint256 _studentId)`: Remove a student record
- `getStudentData(uint256 _studentId)`: Get complete student information

### Course Management

- `addCourse(uint256 _studentId, string memory _name, uint8 _credits, uint8 _grade)`: Add a course to a student's record
- `removeCourse(uint256 _studentId, uint256 _courseIndex)`: Remove a course from a student's record
- `getGPA(uint256 _studentId)`: Calculate a student's GPA based on courses

## Security Features

- Input validation for all data fields
- Prevention of duplicate wallet addresses
- Role-based access control for administrative functions
- Checks for data existence before operations

## Deployment

The contract was deployed using Forge:

```bash
forge script script/DeployAcademicChain.s.sol --rpc-url base_sepolia --broadcast --verify --private-key $PRIVATE_KEY
```

## Integration with Frontend
This contract serves as the backend for the Student Management dApp, providing secure on-chain storage of academic records. Connect to the contract using ethers.js or similar libraries with the following ABI functions:

```javascript
[
  "function addStudent(string memory _name, uint8 _age, address payable _wallet) public",
  "function updateStudent(uint256 _studentId, string memory _name, uint8 _age, address payable _wallet) public",
  "function removeStudent(uint256 _studentId) public",
  "function studentCount() public view returns (uint256)",
  "function addCourse(uint256 _studentId, string memory _name, uint8 _credits, uint8 _grade) public",
  "function removeCourse(uint256 _studentId, uint256 _courseIndex) public",
  "function getStudentData(uint256 _studentId) public view returns (string memory name, uint8 age, address wallet, tuple(string name, uint8 credits, uint8 grade)[] memory courses, bool exists)",
  "function getGPA(uint256 _studentId) public view returns (uint256)"
]
```

## License
This contract is licensed under the MIT License.

## Development Dependencies 
- OpenZeppelin Contracts v4.x (for AccessControl)
- Solidity ^0.8.20