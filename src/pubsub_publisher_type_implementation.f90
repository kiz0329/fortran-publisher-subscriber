submodule (pubsub_publisher_type) pubsub_publisher_type_implementation
    !! Implementation of the publisher_type procedures.
    implicit none

    integer, parameter :: INITIAL_CAPACITY = 4

contains

    module function new_publisher(name) result(pub)
        character(len=*), intent(in) :: name
        type(publisher_type) :: pub

        pub%name = name
        pub%num_subscribers = 0
        allocate(pub%subscribers(INITIAL_CAPACITY))
    end function new_publisher


    module subroutine subscribe(self, sub)
        class(publisher_type), intent(inout) :: self
        class(subscriber_type), target, intent(inout) :: sub

        type(subscriber_ptr), allocatable :: tmp(:)
        integer :: i

        ! Check if already subscribed
        do i = 1, self%num_subscribers
            if (associated(self%subscribers(i)%ptr, sub)) return
        end do

        ! Ensure capacity
        if (.not. allocated(self%subscribers)) then
            allocate(self%subscribers(INITIAL_CAPACITY))
        else if (self%num_subscribers >= size(self%subscribers)) then
            allocate(tmp(size(self%subscribers) * 2))
            do i = 1, self%num_subscribers
                tmp(i)%ptr => self%subscribers(i)%ptr
            end do
            call move_alloc(tmp, self%subscribers)
        end if

        self%num_subscribers = self%num_subscribers + 1
        self%subscribers(self%num_subscribers)%ptr => sub
    end subroutine subscribe


    module subroutine unsubscribe(self, sub)
        class(publisher_type), intent(inout) :: self
        class(subscriber_type), target, intent(inout) :: sub

        integer :: i, j

        do i = 1, self%num_subscribers
            if (associated(self%subscribers(i)%ptr, sub)) then
                ! Shift remaining subscribers
                do j = i, self%num_subscribers - 1
                    self%subscribers(j)%ptr => self%subscribers(j + 1)%ptr
                end do
                self%subscribers(self%num_subscribers)%ptr => null()
                self%num_subscribers = self%num_subscribers - 1
                return
            end if
        end do
    end subroutine unsubscribe


    module subroutine notify(self, message)
        class(publisher_type), intent(inout) :: self
        character(len=*), intent(in) :: message

        integer :: i

        do i = 1, self%num_subscribers
            if (associated(self%subscribers(i)%ptr)) then
                call self%subscribers(i)%ptr%update(self%name, message)
            end if
        end do
    end subroutine notify


    pure module function get_num_subscribers(self) result(n)
        class(publisher_type), intent(in) :: self
        integer :: n

        n = self%num_subscribers
    end function get_num_subscribers


    pure module function get_name(self) result(name)
        class(publisher_type), intent(in) :: self
        character(len=:), allocatable :: name

        name = self%name
    end function get_name

end submodule pubsub_publisher_type_implementation
