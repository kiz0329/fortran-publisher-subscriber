module test_pubsub
    use testdrive, only: new_unittest, unittest_type, error_type, check
    use pubsub, only: subscriber_type, publisher_type
    implicit none

    type, extends(subscriber_type) :: test_subscriber
        integer :: update_count = 0
        character(len=256) :: last_publisher = ''
        character(len=256) :: last_message = ''
    contains
        procedure :: update => test_subscriber_update
    end type test_subscriber

contains

    !> Collect all exported unit tests
    subroutine collect_pubsub(testsuite)
        !> Collection of tests
        type(unittest_type), allocatable, intent(out) :: testsuite(:)

        testsuite = [ &
            new_unittest("publisher-creation", test_publisher_creation), &
            new_unittest("subscribe", test_subscribe), &
            new_unittest("notify", test_notify), &
            new_unittest("unsubscribe", test_unsubscribe), &
            new_unittest("multiple-subscribers", test_multiple_subscribers), &
            new_unittest("duplicate-subscribe", test_duplicate_subscribe), &
            new_unittest("notify-after-unsubscribe", test_notify_after_unsubscribe) &
        ]
    end subroutine collect_pubsub


    subroutine test_subscriber_update(self, publisher_name, message)
        class(test_subscriber), intent(inout) :: self
        character(len=*), intent(in) :: publisher_name
        character(len=*), intent(in) :: message

        self%update_count = self%update_count + 1
        self%last_publisher = publisher_name
        self%last_message = message
    end subroutine test_subscriber_update


    subroutine test_publisher_creation(error)
        !> Error handling
        type(error_type), allocatable, intent(out) :: error

        type(publisher_type) :: pub

        pub = publisher_type("test-publisher")
        call check(error, pub%get_name() == "test-publisher", &
            "Publisher name should match")
        if (allocated(error)) return
        call check(error, pub%get_num_subscribers() == 0, &
            "Initial subscriber count should be 0")
    end subroutine test_publisher_creation


    subroutine test_subscribe(error)
        !> Error handling
        type(error_type), allocatable, intent(out) :: error

        type(publisher_type) :: pub
        type(test_subscriber), target :: sub

        pub = publisher_type("test-publisher")
        call pub%subscribe(sub)
        call check(error, pub%get_num_subscribers() == 1, &
            "Subscriber count should be 1 after subscribe")
    end subroutine test_subscribe


    subroutine test_notify(error)
        !> Error handling
        type(error_type), allocatable, intent(out) :: error

        type(publisher_type) :: pub
        type(test_subscriber), target :: sub

        pub = publisher_type("test-publisher")
        call pub%subscribe(sub)
        call pub%notify("hello")

        call check(error, sub%update_count == 1, &
            "Subscriber should have been notified once")
        if (allocated(error)) return
        call check(error, trim(sub%last_publisher) == "test-publisher", &
            "Publisher name should be passed to subscriber")
        if (allocated(error)) return
        call check(error, trim(sub%last_message) == "hello", &
            "Message should be passed to subscriber")
    end subroutine test_notify


    subroutine test_unsubscribe(error)
        !> Error handling
        type(error_type), allocatable, intent(out) :: error

        type(publisher_type) :: pub
        type(test_subscriber), target :: sub

        pub = publisher_type("test-publisher")
        call pub%subscribe(sub)
        call check(error, pub%get_num_subscribers() == 1, &
            "Subscriber count should be 1 after subscribe")
        if (allocated(error)) return

        call pub%unsubscribe(sub)
        call check(error, pub%get_num_subscribers() == 0, &
            "Subscriber count should be 0 after unsubscribe")
    end subroutine test_unsubscribe


    subroutine test_multiple_subscribers(error)
        !> Error handling
        type(error_type), allocatable, intent(out) :: error

        type(publisher_type) :: pub
        type(test_subscriber), target :: sub1, sub2, sub3

        pub = publisher_type("test-publisher")
        call pub%subscribe(sub1)
        call pub%subscribe(sub2)
        call pub%subscribe(sub3)

        call check(error, pub%get_num_subscribers() == 3, &
            "Subscriber count should be 3")
        if (allocated(error)) return

        call pub%notify("broadcast")

        call check(error, sub1%update_count == 1, &
            "Subscriber 1 should have been notified")
        if (allocated(error)) return
        call check(error, sub2%update_count == 1, &
            "Subscriber 2 should have been notified")
        if (allocated(error)) return
        call check(error, sub3%update_count == 1, &
            "Subscriber 3 should have been notified")
    end subroutine test_multiple_subscribers


    subroutine test_duplicate_subscribe(error)
        !> Error handling
        type(error_type), allocatable, intent(out) :: error

        type(publisher_type) :: pub
        type(test_subscriber), target :: sub

        pub = publisher_type("test-publisher")
        call pub%subscribe(sub)
        call pub%subscribe(sub) ! duplicate

        call check(error, pub%get_num_subscribers() == 1, &
            "Duplicate subscribe should be ignored")
    end subroutine test_duplicate_subscribe


    subroutine test_notify_after_unsubscribe(error)
        !> Error handling
        type(error_type), allocatable, intent(out) :: error

        type(publisher_type) :: pub
        type(test_subscriber), target :: sub1, sub2

        pub = publisher_type("test-publisher")
        call pub%subscribe(sub1)
        call pub%subscribe(sub2)
        call pub%unsubscribe(sub1)

        call pub%notify("hello")

        call check(error, sub1%update_count == 0, &
            "Unsubscribed subscriber should not be notified")
        if (allocated(error)) return
        call check(error, sub2%update_count == 1, &
            "Remaining subscriber should be notified")
    end subroutine test_notify_after_unsubscribe

end module test_pubsub


program tester
    use, intrinsic :: iso_fortran_env, only: error_unit
    use testdrive, only: run_testsuite, new_testsuite, testsuite_type
    use test_pubsub, only: collect_pubsub
    implicit none

    integer :: stat, is
    type(testsuite_type), allocatable :: testsuites(:)
    character(len=*), parameter :: fmt = '("#", *(1x, a))'

    stat = 0

    testsuites = [ &
        new_testsuite("pubsub", collect_pubsub) &
    ]

    do is = 1, size(testsuites)
        write(error_unit, fmt) "Testing:", testsuites(is)%name
        call run_testsuite(testsuites(is)%collect, error_unit, stat)
    end do

    if (stat > 0) then
        write(error_unit, '(i0, 1x, a)') stat, "test(s) failed!"
        error stop
    end if
end program tester
