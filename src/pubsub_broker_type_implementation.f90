submodule (pubsub_broker_type) pubsub_broker_type_implementation
    !! Implementation of the broker_type procedures.
    implicit none

    integer, parameter :: INITIAL_TOPIC_CAPACITY = 4
    integer, parameter :: INITIAL_SUB_CAPACITY = 4

contains

    module function new_broker() result(broker)
        type(broker_type) :: broker

        broker%num_topics = 0
        allocate(broker%topics(INITIAL_TOPIC_CAPACITY))
    end function new_broker


    pure function find_topic(self, topic_name) result(idx)
        !! Find topic index by name. Returns 0 if not found.
        type(broker_type), intent(in) :: self
        character(len=*), intent(in) :: topic_name
        integer :: idx

        integer :: i

        idx = 0
        do i = 1, self%num_topics
            if (self%topics(i)%name == topic_name) then
                idx = i
                return
            end if
        end do
    end function find_topic


    function ensure_topic(self, topic_name) result(idx)
        !! Find or create a topic, returning its index.
        type(broker_type), intent(inout) :: self
        character(len=*), intent(in) :: topic_name
        integer :: idx

        integer :: i
        type(topic_entry), allocatable :: tmp(:)

        idx = find_topic(self, topic_name)
        if (idx > 0) return

        ! Grow topics array if needed
        if (.not. allocated(self%topics)) then
            allocate(self%topics(INITIAL_TOPIC_CAPACITY))
        else if (self%num_topics >= size(self%topics)) then
            allocate(tmp(size(self%topics) * 2))
            do i = 1, self%num_topics
                tmp(i) = self%topics(i)
            end do
            call move_alloc(tmp, self%topics)
        end if

        self%num_topics = self%num_topics + 1
        idx = self%num_topics
        self%topics(idx)%name = topic_name
        self%topics(idx)%num_subscribers = 0
        allocate(self%topics(idx)%subscribers(INITIAL_SUB_CAPACITY))
    end function ensure_topic


    module subroutine subscribe(self, topic_name, sub)
        class(broker_type), intent(inout) :: self
        character(len=*), intent(in) :: topic_name
        class(subscriber_type), target, intent(inout) :: sub

        type(subscriber_ptr), allocatable :: tmp(:)
        integer :: tidx, i

        tidx = ensure_topic(self, topic_name)

        ! Check if already subscribed
        do i = 1, self%topics(tidx)%num_subscribers
            if (associated(self%topics(tidx)%subscribers(i)%ptr, sub)) return
        end do

        ! Grow subscribers array if needed
        if (self%topics(tidx)%num_subscribers >= size(self%topics(tidx)%subscribers)) then
            allocate(tmp(size(self%topics(tidx)%subscribers) * 2))
            do i = 1, self%topics(tidx)%num_subscribers
                tmp(i)%ptr => self%topics(tidx)%subscribers(i)%ptr
            end do
            call move_alloc(tmp, self%topics(tidx)%subscribers)
        end if

        self%topics(tidx)%num_subscribers = self%topics(tidx)%num_subscribers + 1
        self%topics(tidx)%subscribers(self%topics(tidx)%num_subscribers)%ptr => sub
    end subroutine subscribe


    module subroutine unsubscribe(self, topic_name, sub)
        class(broker_type), intent(inout) :: self
        character(len=*), intent(in) :: topic_name
        class(subscriber_type), target, intent(inout) :: sub

        integer :: tidx, i, j

        tidx = find_topic(self, topic_name)
        if (tidx == 0) return

        do i = 1, self%topics(tidx)%num_subscribers
            if (associated(self%topics(tidx)%subscribers(i)%ptr, sub)) then
                do j = i, self%topics(tidx)%num_subscribers - 1
                    self%topics(tidx)%subscribers(j)%ptr => self%topics(tidx)%subscribers(j + 1)%ptr
                end do
                self%topics(tidx)%subscribers(self%topics(tidx)%num_subscribers)%ptr => null()
                self%topics(tidx)%num_subscribers = self%topics(tidx)%num_subscribers - 1
                return
            end if
        end do
    end subroutine unsubscribe


    module subroutine publish(self, topic_name, publisher_name, message)
        class(broker_type), intent(inout) :: self
        character(len=*), intent(in) :: topic_name
        character(len=*), intent(in) :: publisher_name
        character(len=*), intent(in) :: message

        integer :: tidx, i

        tidx = find_topic(self, topic_name)
        if (tidx == 0) return

        do i = 1, self%topics(tidx)%num_subscribers
            if (associated(self%topics(tidx)%subscribers(i)%ptr)) then
                call self%topics(tidx)%subscribers(i)%ptr%update(publisher_name, message)
            end if
        end do
    end subroutine publish


    pure module function get_num_subscribers(self, topic_name) result(n)
        class(broker_type), intent(in) :: self
        character(len=*), intent(in) :: topic_name
        integer :: n

        integer :: tidx

        tidx = find_topic(self, topic_name)
        if (tidx == 0) then
            n = 0
        else
            n = self%topics(tidx)%num_subscribers
        end if
    end function get_num_subscribers

end submodule pubsub_broker_type_implementation
