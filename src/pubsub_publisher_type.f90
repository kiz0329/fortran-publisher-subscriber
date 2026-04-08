module pubsub_publisher_type
    !! Publisher type for the publisher-subscriber pattern.
    !!
    !! A publisher maintains a list of subscribers and notifies them
    !! when an event occurs. Implementation is separated into a submodule.
    use pubsub_subscriber_type, only: subscriber_type
    implicit none
    private

    public :: publisher_type

    type :: subscriber_ptr
        !! Wrapper for a pointer to a subscriber_type object.
        private
        class(subscriber_type), pointer :: ptr => null()
    end type subscriber_ptr

    type :: publisher_type
        !! Type implementing a publisher in the publisher-subscriber pattern.
        private
        character(len=:), allocatable :: name
        type(subscriber_ptr), allocatable :: subscribers(:)
        integer :: num_subscribers = 0
    contains
        procedure :: subscribe
        procedure :: unsubscribe
        procedure :: notify
        procedure :: get_num_subscribers
        procedure :: get_name
    end type publisher_type

    interface publisher_type
        !! Constructor for publisher_type.
        module function new_publisher(name) result(pub)
            character(len=*), intent(in) :: name
            type(publisher_type) :: pub
        end function new_publisher
    end interface

    interface

        module subroutine subscribe(self, sub)
            !! Subscribe a subscriber to this publisher.
            class(publisher_type), intent(inout) :: self
            class(subscriber_type), target, intent(inout) :: sub
        end subroutine subscribe

        module subroutine unsubscribe(self, sub)
            !! Unsubscribe a subscriber from this publisher.
            class(publisher_type), intent(inout) :: self
            class(subscriber_type), target, intent(inout) :: sub
        end subroutine unsubscribe

        module subroutine notify(self, message)
            !! Notify all subscribers with a message.
            class(publisher_type), intent(inout) :: self
            character(len=*), intent(in) :: message
        end subroutine notify

        pure module function get_num_subscribers(self) result(n)
            !! Returns the number of subscribers.
            class(publisher_type), intent(in) :: self
            integer :: n
        end function get_num_subscribers

        pure module function get_name(self) result(name)
            !! Returns the name of the publisher.
            class(publisher_type), intent(in) :: self
            character(len=:), allocatable :: name
        end function get_name

    end interface

end module pubsub_publisher_type
