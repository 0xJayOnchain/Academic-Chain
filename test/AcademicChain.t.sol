// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AcademicChain.sol";

contract AcademicChainTest is Test {
    AcademicChain college;
    address admin = address(this);
    address studentWallet = address(0x1);
    address anotherAdmin = address(0x2);

    event StudentAdded(uint256 indexed id, string name, uint8 age, address wallet);
    event CourseAdded(uint256 indexed studentId, string name, uint8 credits, uint8 grade);

    function setUp() public {
        college = new AcademicChain();
    }

    function testAdminRole() public {
        assertTrue(college.hasRole(college.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(college.hasRole(college.ADMIN_ROLE(), admin));
    }

    function testAddStudent() public {
        vm.expectEmit(true, false, false, true);
        emit StudentAdded(0, "Alice", 20, studentWallet);

        college.addStudent("Alice", 20, payable(studentWallet));
        (string memory name, uint8 age, address wallet,, bool exists) = college.getStudentData(0);

        assertEq(name, "Alice");
        assertEq(age, 20);
        assertEq(wallet, studentWallet);
        assertTrue(exists);
        assertEq(college.studentCount(), 1);
    }

    function testUpdateStudent() public {
        college.addStudent("Bob", 21, payable(studentWallet));
        college.updateStudent(0, "Bobby", 22, payable(studentWallet));

        (string memory name, uint8 age, address wallet,,) = college.getStudentData(0);
        assertEq(name, "Bobby");
        assertEq(age, 22);
        assertEq(wallet, studentWallet);
    }

    function testCourseManagement() public {
        college.addStudent("Charlie", 20, payable(studentWallet));

        vm.expectEmit(true, false, false, true);
        emit CourseAdded(0, "Math", 3, 85);
        college.addCourse(0, "Math", 3, 85);

        college.addCourse(0, "Science", 4, 90);

        (,,, AcademicChain.Course[] memory courses,) = college.getStudentData(0);
        assertEq(courses.length, 2);
        assertEq(courses[0].name, "Math");
        assertEq(courses[1].name, "Science");

        college.removeCourse(0, 0);
        (,,, courses,) = college.getStudentData(0);
        assertEq(courses.length, 1);
        assertEq(courses[0].name, "Science");
    }

    function testGPACalculation() public {
        college.addStudent("David", 20, payable(studentWallet));
        college.addCourse(0, "Math", 3, 85);
        college.addCourse(0, "Science", 4, 90);

        uint256 gpa = college.getGPA(0);
        assertEq(gpa, 8785); // (255 + 360) * 100 / 7 ≈ 8785
    }

    function testAdminManagement() public {
        college.addAdmin(anotherAdmin);
        assertTrue(college.hasRole(college.ADMIN_ROLE(), anotherAdmin));

        vm.prank(anotherAdmin);
        college.addStudent("Eve", 19, payable(address(0x3)));

        college.removeAdmin(anotherAdmin);
        assertFalse(college.hasRole(college.ADMIN_ROLE(), anotherAdmin));
    }

    // Updated failure tests
    function testRevertAddStudentInvalidAge() public {
        vm.expectRevert("Age must be between 16 and 150");
        college.addStudent("Fail", 15, payable(studentWallet));
    }

    function testRevertAddDuplicateWallet() public {
        college.addStudent("Alice", 20, payable(studentWallet));
        vm.expectRevert("Wallet already registered");
        college.addStudent("Bob", 21, payable(studentWallet));
    }

    function testRevertNonAdminAccess() public {
        vm.prank(address(0x4));
        vm.expectRevert("Caller is not an admin");
        college.addStudent("Fail", 20, payable(studentWallet));
    }

    function testRevertRemoveNonExistentCourse() public {
        college.addStudent("Frank", 20, payable(studentWallet));
        vm.expectRevert("Invalid course index");
        college.removeCourse(0, 0);
    }
}
